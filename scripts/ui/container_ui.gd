extends CanvasLayer

@export var player_hotbar_slot_texture: Texture2D = null
@export var player_backpack_slot_texture: Texture2D = null
@export var trash_slot_texture: Texture2D = null

@export var storage_slot_texture: Texture2D = null
@export var fridge_slot_texture: Texture2D = null
@export var display_slot_texture: Texture2D = null
@export var counter_slot_texture: Texture2D = null

@onready var player_backpack_grid: GridContainer = $PanelContainer/HBoxContainer/PlayerSide/PlayerBackpackGrid
@onready var player_hotbar_grid: GridContainer = $PanelContainer/HBoxContainer/PlayerSide/PlayerHotbarGrid
@onready var container_grid: GridContainer = $PanelContainer/HBoxContainer/ContainerSide/ContainerGrid
@onready var close_button: Button = $PanelContainer/HBoxContainer/ContainerSide/CloseButton
@onready var backdrop = $Backdrop
@onready var trash_slot: TextureRect = $PanelContainer/HBoxContainer/TrashSide/TrashSlot

@onready var price_label: Label = $PanelContainer/HBoxContainer/ContainerSide/PriceLabel
@onready var sell_button: Button = $PanelContainer/HBoxContainer/ContainerSide/SellButton


var player_slots: Array[Control] = []
var container_slots: Array[Control] = []
var active_container_array: Array[InventoryItem]

var is_counter_mode: bool = false

func _ready() -> void:
	add_to_group(UIOverlayManager.OVERLAY_GROUP)
	backdrop.backdrop_clicked.connect(func(): close())
	close_button.pressed.connect(close)
	sell_button.pressed.connect(_on_sell_pressed)
	InventoryManager.inventory_changed.connect(refresh)

func open(container_array: Array[InventoryItem], mode: String = "storage") -> void:
	UIOverlayManager.close_all_overlays(self)
	active_container_array = container_array
	InventoryManager.active_container_slots = container_array
	is_counter_mode = (mode == "counter")
	visible = true
	
	price_label.visible = is_counter_mode
	sell_button.visible = is_counter_mode
	
	for child in player_backpack_grid.get_children(): child.queue_free()
	for child in player_hotbar_grid.get_children(): child.queue_free()
	for child in container_grid.get_children(): child.queue_free()
	
	var total_slots = InventoryManager.state.inventory_slots.size()
	player_slots.resize(total_slots)
	
	var slot_scene = load(GameConstants.Paths.SLOT_UI_SCENE_PATH)
	
	for i in range(GameConstants.Inventory.MAX_HOTBAR_IDX):
		var slot = slot_scene.instantiate()
		slot.configure(InventorySlotAddress.inventory(i))
		if player_hotbar_slot_texture:
			slot.set_slot_background(player_hotbar_slot_texture)
		player_hotbar_grid.add_child(slot)
		player_slots[i] = slot
	
	for i in range(GameConstants.Inventory.MAX_HOTBAR_IDX, total_slots):
		var slot = slot_scene.instantiate()
		slot.configure(InventorySlotAddress.inventory(i))
		if player_backpack_slot_texture:
			slot.set_slot_background(player_backpack_slot_texture)
		player_backpack_grid.add_child(slot)
		player_slots[i] = slot
		
	if trash_slot:
		if trash_slot_texture:
			trash_slot.set_slot_background(trash_slot_texture)
		trash_slot.configure(InventorySlotAddress.trash())
	
	var container_slot_tex: Texture2D = storage_slot_texture
	match mode:
		"fridge":
			container_slot_tex = fridge_slot_texture
		"display":
			container_slot_tex = display_slot_texture
		"counter":
			container_slot_tex = counter_slot_texture
			
	container_slots = _spawn_slots_for_grid(container_grid, active_container_array, container_slot_tex)
	
	refresh()

func refresh() -> void:
	if not visible:
		return
		
	_refresh_slots_data(player_slots, InventoryManager.state.inventory_slots)

	_refresh_slots_data(container_slots, active_container_array)
	
	if is_counter_mode:
		var total_value := SaleService.get_total_value(active_container_array)
				
		price_label.text = "Total Value: $%d" % total_value
		sell_button.text = "Confirm Sale (+$%d)" % total_value
		sell_button.disabled = total_value <= 0

func _spawn_slots_for_grid(grid: GridContainer, slot_array: Array[InventoryItem], tex: Texture2D = null) -> Array[Control]:
	var spawned_nodes: Array[Control] = []
	for i in range(slot_array.size()):
		var slot_scene = load(GameConstants.Paths.SLOT_UI_SCENE_PATH)
		var slot = slot_scene.instantiate()
		slot.configure(InventorySlotAddress.active_container(i))
		if tex:
			slot.set_slot_background(tex)
		grid.add_child(slot)
		spawned_nodes.append(slot)
	return spawned_nodes


func _refresh_slots_data(ui_slots: Array[Control], data_items: Array[InventoryItem]) -> void:
	for i in range(data_items.size()):
		if i < ui_slots.size():
			ui_slots[i].set_item(data_items[i])

func _on_sell_pressed() -> void:
	var total_earned := SaleService.sell_all(active_container_array)
			
	if total_earned > 0:
		var player := SceneManager.get_player()
		if player:
			var floaty_scene = load(GameConstants.Paths.FLOATY_ICON_SCENE_PATH)
			var floaty = floaty_scene.instantiate()
			floaty.position = player.position - Vector2(0, 16)
			get_tree().current_scene.add_child(floaty)
			floaty.start_text("+$%d" % total_earned, Color(0.2, 0.8, 0.2))
			
		close()

func close() -> void:
	visible = false
	InventoryManager.active_container_slots = []
	GameManager.save_game()


func close_overlay() -> void:
	close()


func is_overlay_open() -> bool:
	return visible

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
