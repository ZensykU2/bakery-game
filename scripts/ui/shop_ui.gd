extends CanvasLayer
class_name ShopUI

@onready var title_label: Label = $PanelContainer/VBoxContainer/Header/TitleLabel
@onready var close_button: Button = $PanelContainer/VBoxContainer/Header/CloseButton

@onready var items_container: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/ItemsContainer
@onready var backdrop = $Backdrop

var active_shop_type: String = ""
var shop_items: Array[ShopItem] = []

func _ready() -> void:
	close_button.pressed.connect(close)
	
	if backdrop:
		backdrop.backdrop_clicked.connect(close)
	
	InventoryManager.inventory_changed.connect(refresh_items)
	GameManager.money_changed.connect(func(_new_money): refresh_items())
	visible = false

func open(shop_name: String, shop_type: String, catalog: Array[String]) -> void:
	title_label.text = shop_name
	active_shop_type = shop_type
	visible = true
	_load_shop_items_from_catalog(catalog)
	refresh_items()

func close() -> void:
	visible = false

func _load_shop_items_from_catalog(catalog: Array[String]) -> void:
	shop_items.clear()
	
	var custom_items := {}
	var dir_path = GameConstants.Paths.SHOP_ITEMS_DIR
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var item = load(dir_path + file_name)
				if item is ShopItem:
					custom_items[item.item_id] = item
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		DirAccess.make_dir_absolute(dir_path)
	
	for item_id in catalog:
		if custom_items.has(item_id):
			shop_items.append(custom_items[item_id])
			var res = ItemDB.item_resources.get(item_id, null)
			if res and res.buy_price > 0:
				var shop_item = ShopItem.new()
				shop_item.item_id = item_id
				shop_item.shop_types = [active_shop_type]
				
				var cost = MoneyRequirement.new()
				cost.amount = res.buy_price
				shop_item.costs = [cost]
				
				shop_items.append(shop_item)
				

func refresh_items() -> void:
	if not visible:
		return
	
	# Clear old rows
	for child in items_container.get_children():
		child.queue_free()
	
	# Spawn a row for each item
	for item in shop_items:
		# Skip locked items so they don't clutter the UI
		if not item.is_unlocked():
			continue
		
		var row = _create_item_row(item)
		items_container.add_child(row)

func _create_locked_row(item: ShopItem) -> Control:
	var row_hbox = HBoxContainer.new()
	row_hbox.custom_minimum_size = Vector2(0, 64)
	
	# Locked Icon Placeholder
	var icon_rect = ColorRect.new()
	icon_rect.color = Color(0.2, 0.2, 0.2, 0.5)
	icon_rect.custom_minimum_size = Vector2(48, 48)
	row_hbox.add_child(icon_rect)
	
	# Locked Label
	var lock_label = Label.new()
	var lock_desc = ""
	for condition in item.unlock_conditions:
		if condition and not condition.is_unlocked():
			lock_desc += condition.get_lock_description() + " "
	lock_label.text = "[LOCKED] " + lock_desc.strip_edges()
	lock_label.modulate = Color(0.6, 0.6, 0.6)
	lock_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_hbox.add_child(lock_label)
	
	return row_hbox

func _create_item_row(item: ShopItem) -> Control:
	var item_data = ItemDB.get_item_data(item.item_id)
	var icon = item_data.get("icon_fresh", null)
	var display_name = item.item_id.capitalize()
	
	var row_hbox = HBoxContainer.new()
	row_hbox.custom_minimum_size = Vector2(0, 64)
	
	# Icon
	var icon_rect = TextureRect.new()
	icon_rect.texture = icon
	icon_rect.custom_minimum_size = Vector2(48, 48)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row_hbox.add_child(icon_rect)
	
	# Name Label
	var name_label = Label.new()
	name_label.text = display_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_hbox.add_child(name_label)
	
	# Costs VBox
	var costs_vbox = VBoxContainer.new()
	costs_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_hbox.add_child(costs_vbox)
	
	var can_afford_all = true
	for cost in item.costs:
		if cost is Requirement:
			var cost_label = Label.new()
			cost_label.text = cost.get_description()
			
			if cost.is_met():
				cost_label.modulate = Color(0.6, 1.0, 0.6)
			else:
				cost_label.modulate = Color(1.0, 0.6, 0.6)
				can_afford_all = false
			costs_vbox.add_child(cost_label)
			
	# Buy Button
	var buy_button = Button.new()
	buy_button.text = "Buy"
	buy_button.disabled = not can_afford_all
	buy_button.pressed.connect(func(): _buy_item(item))
	row_hbox.add_child(buy_button)
	
	return row_hbox

func _buy_item(item: ShopItem) -> void: 
	var can_afford_all = true
	for cost in item.costs:
		if cost is Requirement and not cost.is_met():
			can_afford_all = false
			break
	
	if not can_afford_all:
		return
	
	if InventoryManager.add_item(item.item_id, 1):
		for cost in item.costs:
			if cost is Requirement:
				cost.consume()
		refresh_items()
