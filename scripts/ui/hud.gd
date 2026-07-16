extends CanvasLayer

@export var hotbar_slot_texture: Texture2D = null
@export var backpack_slot_texture: Texture2D = null
@export var trash_slot_texture: Texture2D = null

@onready var day_label: Label = $TopBarMargin/TopBar/DayLabel
@onready var money_label: Label = $TopBarMargin/TopBar/MoneyLabel

@onready var trash_slot: TextureRect = $VBoxContainer/TrashSlot
@onready var trash_label: Label = $VBoxContainer/TrashLabel
@onready var backpack_grid: GridContainer = $InventoryContainer/BackpackGrid
@onready var hotbar_list: HBoxContainer = $InventoryContainer/HotbarList
@onready var inventory_container: VBoxContainer = $InventoryContainer
@onready var backdrop = $Backdrop

@onready var cursor_grabber: TextureRect = $CursorGrabber


var slot_nodes: Array[Control] = []

var selected_hotbar_index: int = 0

func _process(_delta: float) -> void:
	_update_cursor_grabber()

func _update_cursor_grabber() -> void:
	var held = InventoryManager.held_item
	if held == null or held.amount <= 0:
		cursor_grabber.visible = false
		return
	
	cursor_grabber.visible = true
	
	cursor_grabber.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cursor_grabber.stretch_mode = TextureRect.STRETCH_SCALE
	cursor_grabber.size = GameConstants.UI.CURSOR_GRABBER_SIZE
	
	cursor_grabber.texture = ItemDB.get_item_icon(held.item_id, held.freshness)
	var label = cursor_grabber.get_node("CountLabel")
	label.text = str(held.amount) if held.amount > 1 else ""
	
	cursor_grabber.global_position = cursor_grabber.get_global_mouse_position() - cursor_grabber.size / 2

func _ready() -> void:
	backdrop.backdrop_clicked.connect(func(): _toggle_backpack())
	GameManager.day_changed.connect(_update_day)
	GameManager.money_changed.connect(_update_money)
	InventoryManager.inventory_changed.connect(_rebuild_inventory)
	InventoryManager.active_container_changed.connect(_on_active_container_changed)

	_update_day(GameManager.get_day())
	_update_money(GameManager.get_money())
	
	if trash_slot_texture:
		trash_slot.set_slot_background(trash_slot_texture)
		
	setup_inventory_ui()
	backpack_grid.visible = false
	backdrop.visible = false
	InventoryManager.is_backpack_open = false
	trash_slot.visible = false
	trash_label.visible = false
	_align_inventory_layout(false)
	
	set_selected_hotbar_index(0)
	
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if InventoryManager.held_item != null:
			InventoryManager.drop_held_item_to_world()
			get_viewport().set_input_as_handled()
			return
	
	if event.is_action_pressed("toggle_inventory"):
		_toggle_backpack()
	
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var index = event.keycode - KEY_1
			set_selected_hotbar_index(index)
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var index = (selected_hotbar_index - 1 + GameConstants.Inventory.MAX_HOTBAR_IDX) % GameConstants.Inventory.MAX_HOTBAR_IDX
			set_selected_hotbar_index(index)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var index = (selected_hotbar_index + 1) % GameConstants.Inventory.MAX_HOTBAR_IDX
			set_selected_hotbar_index(index)

func _toggle_backpack() -> void:
	var open = not backpack_grid.visible
	backpack_grid.visible = open
	backdrop.visible = open
	InventoryManager.is_backpack_open = open
	_align_inventory_layout(open)
	trash_slot.visible = open
	trash_label.visible = open
	
	if not open:
		GameManager.save_game()

func _align_inventory_layout(open: bool) -> void:
	inventory_container.reset_size()
	
	var viewport_size = get_viewport().get_visible_rect().size
	var container_size = inventory_container.size
	
	if open:
		inventory_container.position.x = (viewport_size.x - container_size.x) / 2.0
		inventory_container.position.y = (viewport_size.y - container_size.y) / 2.0
	else:
		inventory_container.position.x = (viewport_size.x - container_size.x) / 2.0
		inventory_container.position.y = viewport_size.y - container_size.y - GameConstants.UI.HUD_BOTTOM_MARGIN


func set_selected_hotbar_index(index: int) -> void:
	selected_hotbar_index = index
	for i in range(GameConstants.Inventory.MAX_HOTBAR_IDX):
		if i < slot_nodes.size():
			slot_nodes[i].set_selected(i == selected_hotbar_index)

func setup_inventory_ui() -> void:
	slot_nodes.clear()
	var total_slots = InventoryManager.state.inventory_slots.size()
	var slot_scene = load(GameConstants.Paths.SLOT_UI_SCENE_PATH)
	
	for i in range(GameConstants.Inventory.MAX_HOTBAR_IDX):
		var slot = slot_scene.instantiate()
		slot.slot_index = i
		if hotbar_slot_texture:
			slot.set_slot_background(hotbar_slot_texture)
		hotbar_list.add_child(slot)
		slot_nodes.append(slot)
		
	for i in range(GameConstants.Inventory.MAX_HOTBAR_IDX, total_slots):
		var slot = slot_scene.instantiate()
		slot.slot_index = i
		if backpack_slot_texture:
			slot.set_slot_background(backpack_slot_texture)
		backpack_grid.add_child(slot)
		slot_nodes.append(slot)

		
	_rebuild_inventory()

func _rebuild_inventory() -> void:
	var slots = InventoryManager.state.inventory_slots
	for i in range(slots.size()):
		if i < slot_nodes.size():
			slot_nodes[i].set_item(slots[i])
			
	set_selected_hotbar_index(selected_hotbar_index)
	_align_inventory_layout(backpack_grid.visible)


func _update_day(_new_day: int) -> void:
	day_label.text = "Yr %d, %s - Day %d (%s)" % [
		TimeManager.get_year(),
		TimeManager.get_season_name(),
		TimeManager.get_day_of_season(),
		TimeManager.get_weekday_name(),
	]

func _update_money(new_money: int) -> void:
	money_label.text = "Money: %d" % new_money

func show_confirm_dialog(title: String, text: String, on_confirm: Callable) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = title
	dialog.dialog_text = text
	dialog.ok_button_text = "Yes"
	dialog.cancel_button_text = "No"
	
	dialog.confirmed.connect(func():
		on_confirm.call()
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()

func _on_active_container_changed(is_open: bool) -> void:
	inventory_container.visible = not is_open
