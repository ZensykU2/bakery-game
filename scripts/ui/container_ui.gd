extends CanvasLayer

@onready var player_grid: GridContainer = $PanelContainer/HBoxContainer/PlayerSide/PlayerGrid
@onready var container_grid: GridContainer = $PanelContainer/HBoxContainer/ContainerSide/ContainerGrid
@onready var close_button: Button = $CloseButton
@onready var backdrop = $Backdrop

@onready var price_label: Label = $PanelContainer/HBoxContainer/ContainerSide/PriceLabel
@onready var sell_button: Button = $PanelContainer/HBoxContainer/ContainerSide/SellButton

var player_slots: Array[Control] = []
var container_slots: Array[Control] = []
var active_container_array: Array[InventoryItem]

var is_counter_mode: bool = false

func _ready() -> void:
	backdrop.backdrop_clicked.connect(func(): close())
	close_button.pressed.connect(close)
	sell_button.pressed.connect(_on_sell_pressed)
	InventoryManager.inventory_changed.connect(refresh)

func open(container_array: Array[InventoryItem], mode: String = "storage") -> void:
	active_container_array = container_array
	is_counter_mode = (mode == "counter")
	visible = true
	
	price_label.visible = is_counter_mode
	sell_button.visible = is_counter_mode
	
	for child in player_grid.get_children(): child.queue_free()
	for child in container_grid.get_children(): child.queue_free()
	
	var player_inv = InventoryManager.state.inventory_slots
	player_slots = _spawn_slots_for_grid(player_grid, player_inv, 0)
		
	container_slots = _spawn_slots_for_grid(container_grid, active_container_array, 100)
		
	refresh()

func refresh() -> void:
	if not visible:
		return
		
	_refresh_slots_data(player_slots, InventoryManager.state.inventory_slots)

	var total_value = 0.0
	_refresh_slots_data(container_slots, active_container_array)
	
	if is_counter_mode:
		for item in active_container_array:
			if item != null:
				var data = ItemDB.get_recipe(item.item_id)
				var base_price = data.get("sell_price", 0)
				total_value += base_price * item.freshness * item.amount
				
		price_label.text = "Total Value: $%d" % int(total_value)
		sell_button.text = "Confirm Sale (+$%d)" % int(total_value)
		sell_button.disabled = (total_value <= 0.0)

func _spawn_slots_for_grid(grid: GridContainer, slot_array: Array[InventoryItem], index_offset: int) -> Array[Control]:
	var spawned_nodes: Array[Control] = []
	for i in range(slot_array.size()):
		var slot_scene = load(GameConstants.Paths.SLOT_UI_SCENE_PATH)
		var slot = slot_scene.instantiate()
		slot.slot_index = index_offset + i
		grid.add_child(slot)
		spawned_nodes.append(slot)
	return spawned_nodes

func _refresh_slots_data(ui_slots: Array[Control], data_items: Array[InventoryItem]) -> void:
	for i in range(data_items.size()):
		if i < ui_slots.size():
			ui_slots[i].set_item(data_items[i])

func _on_sell_pressed() -> void:
	var total_earned = 0.0
	for i in range(active_container_array.size()):
		var item = active_container_array[i]
		if item != null:
			var base_price = ItemDB.get_recipe(item.item_id).get("sell_price", 0)
			total_earned += base_price * item.get_sell_multiplier() * item.amount
			active_container_array[i] = null
			
	if total_earned > 0.0:
		GameManager.add_money(int(total_earned))
		
		var player = get_tree().root.find_child("Player", true, false)
		if player:
			var floaty_scene = load(GameConstants.Paths.FLOATY_ICON_SCENE_PATH)
			var floaty = floaty_scene.instantiate()
			floaty.position = player.position - Vector2(0, 16)
			get_tree().current_scene.add_child(floaty)
			floaty.start_text("+$%d" % int(total_earned), Color(0.2, 0.8, 0.2))
			
	close()

func close() -> void:
	visible = false
	GameManager.save_game()

func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("toggle_inventory") or event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			close()

func _on_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if InventoryManager.held_item != null:
			InventoryManager.drop_held_item_to_world()
			get_viewport().set_input_as_handled()
		else:
			close()
