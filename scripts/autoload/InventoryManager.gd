extends Node

signal inventory_changed
signal item_dropped(item: InventoryItem, global_position: Vector2)

var state: GameState:
	get: return GameManager.state

var show_freshness_bars: bool = false
var active_container_slots: Array[InventoryItem] = []
var is_backpack_open: bool = false

# Sub-services (SRP)
var slot_interaction_service: SlotInteractionService
var decay_service: ItemDecayService
var dropped_item_manager: DroppedItemManager

# Facade properties mapping to the UI Slot Interaction Service
var held_item: InventoryItem:
	get: return slot_interaction_service.held_item if slot_interaction_service else null
	set(val): if slot_interaction_service: slot_interaction_service.held_item = val

var last_interacted_slot_index: int:
	get: return slot_interaction_service.last_interacted_slot_index if slot_interaction_service else -1
	set(val): if slot_interaction_service: slot_interaction_service.last_interacted_slot_index = val

var pressed_slot_index: int:
	get: return slot_interaction_service.pressed_slot_index if slot_interaction_service else -1
	set(val): if slot_interaction_service: slot_interaction_service.pressed_slot_index = val

var is_paint_mode_active: bool:
	get: return slot_interaction_service.is_paint_mode_active if slot_interaction_service else false
	set(val): if slot_interaction_service: slot_interaction_service.is_paint_mode_active = val

func _ready() -> void:
	Services.inventory = self
	
	# Instantiate and register child services
	decay_service = ItemDecayService.new()
	add_child(decay_service)
	
	dropped_item_manager = DroppedItemManager.new()
	add_child(dropped_item_manager)
	
	slot_interaction_service = SlotInteractionService.new()
	add_child(slot_interaction_service)

# --- Facade API delegation ---

func handle_slot_click(slot_index: int, is_shift: bool, is_pressed: bool) -> void:
	if slot_interaction_service:
		slot_interaction_service.handle_slot_click(slot_index, is_shift, is_pressed)

func handle_slot_right_click(slot_index: int) -> void:
	if slot_interaction_service:
		slot_interaction_service.handle_slot_right_click(slot_index)

func handle_slot_double_click(slot_index: int) -> void:
	if slot_interaction_service:
		slot_interaction_service.handle_slot_double_click(slot_index)

func paint_slot(slot_index: int) -> void:
	if slot_interaction_service:
		slot_interaction_service.paint_slot(slot_index)

func drop_held_item_to_world() -> void:
	if dropped_item_manager:
		dropped_item_manager.drop_held_item_to_world()

func enforce_hard_limit() -> void:
	if dropped_item_manager:
		dropped_item_manager.enforce_hard_limit()

# --- Core Data Store Responsibilities ---

func is_trash_slot(slot_index: int) -> bool:
	return slot_index == GameConstants.Inventory.TRASHBIN_IDX

func get_item_count(item_id: String) -> int:
	var total = 0
	for item in state.inventory_slots:
		if item != null and item.item_id == item_id:
			total += item.amount
	return total

func add_item(item_name: String, amount: int, freshness: float = GameConstants.Inventory.MAX_FRESHNESS) -> bool:
	var new_item = InventoryItem.new()
	new_item.item_id = item_name
	new_item.amount = amount
	new_item.freshness = freshness
	
	var success = add_inventory_item_resource(new_item)
	if success:
		inventory_changed.emit()
		GameManager.save_game()
	return success

func deduct_item(item_id: String, amount: int) -> void:
	var remaining = amount
	var slots_size = state.inventory_slots.size()
	for i in range(slots_size):
		var item = state.inventory_slots[i]
		if item != null and item.item_id == item_id:
			if item.amount >= remaining:
				item.amount -= remaining
				remaining = 0
			else:
				remaining -= item.amount
				item.amount = 0
			if item.amount == 0:
				state.inventory_slots[i] = null
			if remaining == 0:
				break

	inventory_changed.emit()
	GameManager.save_game()

func add_inventory_item_resource(new_item: InventoryItem) -> bool:
	var slots = state.inventory_slots
	if ItemDB.is_stackable(new_item.item_id):
		for item in slots:
			if item != null and _can_stack(item, new_item):
				item.merge_with(new_item)
				return true
				
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = new_item
			return true
	return false

func _can_stack(item_a: InventoryItem, item_b: InventoryItem) -> bool:
	if item_a == null or item_b == null:
		return false
	
	return (item_a.item_id == item_b.item_id 
		and ItemDB.is_stackable(item_a.item_id)
		and item_a.get_freshness_state() == item_b.get_freshness_state())
