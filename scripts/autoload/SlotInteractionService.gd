extends Node
class_name SlotInteractionService

var held_item: InventoryItem = null
var last_interacted_slot_index: int = -1
var pressed_slot_index: int = -1
var is_paint_mode_active: bool = false

var inv: Node:
	get: return Services.inventory

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if pressed_slot_index != -1 and not is_paint_mode_active:
			_execute_left_click_swap(pressed_slot_index)
			
		pressed_slot_index = -1
		last_interacted_slot_index = -1
		is_paint_mode_active = false

func _resolve_slot(slot_index: int) -> Dictionary:
	var array = inv.state.inventory_slots
	var idx = slot_index
	
	if slot_index >= GameConstants.Inventory.CONTAINER_IDX and not inv.active_container_slots.is_empty():
		array = inv.active_container_slots
		idx = slot_index - GameConstants.Inventory.CONTAINER_IDX
		
	return {
		"array": array,
		"index": idx,
		"item": array[idx]
	}

func _set_slot_item(slot: Dictionary, item: InventoryItem) -> void:
	slot.array[slot.index] = item

func handle_slot_click(slot_index: int, is_shift: bool, is_pressed: bool) -> void:
	if inv.is_trash_slot(slot_index) and is_pressed:
		if held_item != null:
			held_item = null
			inv.inventory_changed.emit()
			Services.game.save_game()
		return
	
	if is_shift and is_pressed:
		_handle_shift_click(slot_index)
		return
	
	if is_pressed:
		if held_item == null:
			_execute_left_click_swap(slot_index)
		else:
			pressed_slot_index = slot_index
			is_paint_mode_active = false
			
			var timer = get_tree().create_timer(0.2)
			timer.timeout.connect(func(): 
				if pressed_slot_index == slot_index and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_paint_mode_active:
					is_paint_mode_active = true
					paint_slot(slot_index) 
				)

func _execute_left_click_swap(slot_index: int) -> void:
	var slot = _resolve_slot(slot_index)
	
	if held_item == null:
		if slot.item != null:
			held_item = slot.item
			_set_slot_item(slot, null)
	else:
		if slot.item == null:
			_set_slot_item(slot, held_item)
			held_item = null
		else:
			if inv._can_stack(slot.item, held_item):
				slot.item.merge_with(held_item)
				held_item = null
			else:
				var temp = slot.item
				_set_slot_item(slot, held_item)
				held_item = temp
				
	inv.inventory_changed.emit()

func handle_slot_right_click(slot_index: int) -> void:
	if inv.is_trash_slot(slot_index):
		if held_item != null:
			held_item.amount -= 1
			if held_item.amount <= 0:
				held_item = null
			inv.inventory_changed.emit()
			Services.game.save_game()
		return
	
	var slot = _resolve_slot(slot_index)
	
	if held_item == null:
		if slot.item != null and slot.item.amount > 1:
			var half = slot.item.amount / 2
			var remainder = slot.item.amount - half
			
			held_item = slot.item.clone(half)
			slot.item.amount = remainder
		elif slot.item != null:
			held_item = slot.item
			_set_slot_item(slot, null)
	else:
		_drop_single_item_to_slot(slot)
		
	inv.inventory_changed.emit()

func _drop_single_item_to_slot(slot: Dictionary) -> void:
	if held_item == null or held_item.amount <= 0:
		return
		
	if slot.item == null:
		_set_slot_item(slot, held_item.clone(1))
	elif inv._can_stack(slot.item, held_item):
		var single_item = held_item.clone(1)
		slot.item.merge_with(single_item)
	else:
		return
		
	held_item.amount -= 1
	if held_item.amount <= 0:
		held_item = null
	inv.inventory_changed.emit()

func paint_slot(slot_index: int) -> void:
	if inv.is_trash_slot(slot_index):
		return
		
	if held_item == null or held_item.amount <= 0 or slot_index == last_interacted_slot_index:
		return
		
	if pressed_slot_index != -1 and not is_paint_mode_active:
		is_paint_mode_active = true
		_paint_single_item(pressed_slot_index)
		
	if not is_paint_mode_active:
		return
		
	_paint_single_item(slot_index)
	last_interacted_slot_index = slot_index

func _paint_single_item(slot_index: int) -> void:
	_drop_single_item_to_slot(_resolve_slot(slot_index))

func handle_slot_double_click(slot_index: int) -> void:
	if inv.is_trash_slot(slot_index):
		return
	
	if held_item == null or not ItemDB.is_stackable(held_item.item_id):
		return
		
	var target_item = held_item
	var target_state = target_item.get_freshness_state()
	
	for i in range(inv.state.inventory_slots.size()):
		var item = inv.state.inventory_slots[i]
		if item != null and item != target_item and item.item_id == target_item.item_id and item.get_freshness_state() == target_state:
			target_item.merge_with(item)
			inv.state.inventory_slots[i] = null
			
	if not inv.active_container_slots.is_empty():
		for i in range(inv.active_container_slots.size()):
			var item = inv.active_container_slots[i]
			if item != null and item != target_item and item.item_id == target_item.item_id and item.get_freshness_state() == target_state:
				target_item.merge_with(item)
				inv.active_container_slots[i] = null
				
	inv.inventory_changed.emit()

func _handle_shift_click(slot_index: int) -> void:
	if inv.is_trash_slot(slot_index):
		return
	
	var is_container_open = not inv.active_container_slots.is_empty()
	
	var from_slot = _resolve_slot(slot_index)
	var from_array = from_slot.array
	var from_local_index = from_slot.index
	
	if is_container_open:
		if slot_index >= GameConstants.Inventory.CONTAINER_IDX:
			var success = _transfer_to_range(from_array, from_local_index, inv.state.inventory_slots, 0, GameConstants.Inventory.MAX_HOTBAR_IDX)
			if not success:
				_transfer_to_range(from_array, from_local_index, inv.state.inventory_slots, GameConstants.Inventory.MAX_HOTBAR_IDX, inv.state.inventory_slots.size())
		else:
			_transfer_to_range(from_array, from_local_index, inv.active_container_slots, 0, inv.active_container_slots.size())
	else:
		if inv.is_backpack_open:
			var start = GameConstants.Inventory.MAX_HOTBAR_IDX if slot_index < GameConstants.Inventory.MAX_HOTBAR_IDX else 0
			var end = inv.state.inventory_slots.size() if slot_index < GameConstants.Inventory.MAX_HOTBAR_IDX else GameConstants.Inventory.MAX_HOTBAR_IDX
			_transfer_to_range(from_array, from_local_index, inv.state.inventory_slots, start, end)

func _transfer_to_range(from_array: Array[InventoryItem], from_idx: int, to_array: Array[InventoryItem], start_idx: int, end_idx: int) -> bool:
	var item = from_array[from_idx]
	if item == null:
		return false
		
	if ItemDB.is_stackable(item.item_id):
		for i in range(start_idx, end_idx):
			var target = to_array[i]
			if target != null and inv._can_stack(target, item):
				target.merge_with(item)
				from_array[from_idx] = null
				inv.inventory_changed.emit()
				return true
				
	for i in range(start_idx, end_idx):
		if to_array[i] == null:
			to_array[i] = item
			from_array[from_idx] = null
			inv.inventory_changed.emit()
			return true
			
	return false
