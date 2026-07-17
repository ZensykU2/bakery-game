extends Node
class_name SlotInteractionService

var held_item: InventoryItem = null
var last_interacted_slot: InventorySlotAddress = null
var pressed_slot: InventorySlotAddress = null
var is_paint_mode_active: bool = false

var inv: Node:
	get: return InventoryManager


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if pressed_slot != null and not is_paint_mode_active:
			_execute_left_click_swap(pressed_slot)

		pressed_slot = null
		last_interacted_slot = null
		is_paint_mode_active = false


func _resolve_slot(address: InventorySlotAddress) -> Dictionary:
	if address == null:
		return {}

	var slots: Array[InventoryItem]
	match address.storage:
		InventorySlotAddress.Storage.INVENTORY:
			slots = inv.state.inventory_slots
		InventorySlotAddress.Storage.ACTIVE_CONTAINER:
			if inv.active_container_slots.is_empty():
				return {}
			slots = inv.active_container_slots
		_:
			return {}

	if address.index < 0 or address.index >= slots.size():
		return {}

	return {
		"array": slots,
		"index": address.index,
		"item": slots[address.index]
	}


func _set_slot_item(slot: Dictionary, item: InventoryItem) -> void:
	slot["array"][slot["index"]] = item


func handle_slot_click(address: InventorySlotAddress, is_shift: bool, is_pressed: bool) -> void:
	if address == null:
		return

	if address.storage == InventorySlotAddress.Storage.TRASH and is_pressed:
		if held_item != null:
			held_item = null
			inv.inventory_changed.emit()
			GameManager.save_game()
		return

	if is_shift and is_pressed:
		_handle_shift_click(address)
		return

	if is_pressed:
		if held_item == null:
			_execute_left_click_swap(address)
		else:
			pressed_slot = address
			is_paint_mode_active = false

			var timer := get_tree().create_timer(0.2)
			timer.timeout.connect(func() -> void:
				if pressed_slot != null \
					and pressed_slot.matches(address) \
					and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
					and not is_paint_mode_active:
					is_paint_mode_active = true
					paint_slot(address)
			)


func _execute_left_click_swap(address: InventorySlotAddress) -> void:
	var slot := _resolve_slot(address)
	if slot.is_empty():
		return

	var slot_item: InventoryItem = slot["item"]
	if held_item == null:
		if slot_item != null:
			held_item = slot_item
			_set_slot_item(slot, null)
	else:
		if slot_item == null:
			_set_slot_item(slot, held_item)
			held_item = null
		elif inv._can_stack(slot_item, held_item):
			slot_item.merge_with(held_item)
			held_item = null
		else:
			_set_slot_item(slot, held_item)
			held_item = slot_item

	inv.inventory_changed.emit()


func handle_slot_right_click(address: InventorySlotAddress) -> void:
	if address == null:
		return

	if address.storage == InventorySlotAddress.Storage.TRASH:
		if held_item != null:
			held_item.amount -= 1
			if held_item.amount <= 0:
				held_item = null
			inv.inventory_changed.emit()
			GameManager.save_game()
		return

	var slot := _resolve_slot(address)
	if slot.is_empty():
		return

	var slot_item: InventoryItem = slot["item"]
	if held_item == null:
		if slot_item != null and slot_item.amount > 1:
			var held_amount := ceili(float(slot_item.amount) / 2.0)
			var remainder := slot_item.amount - held_amount

			held_item = slot_item.clone(held_amount)
			slot_item.amount = remainder
		elif slot_item != null:
			held_item = slot_item
			_set_slot_item(slot, null)
	else:
		_drop_single_item_to_slot(slot)

	inv.inventory_changed.emit()


func _drop_single_item_to_slot(slot: Dictionary) -> void:
	if held_item == null or held_item.amount <= 0 or slot.is_empty():
		return

	var slot_item: InventoryItem = slot["item"]
	if slot_item == null:
		_set_slot_item(slot, held_item.clone(1))
	elif inv._can_stack(slot_item, held_item):
		slot_item.merge_with(held_item.clone(1))
	else:
		return

	held_item.amount -= 1
	if held_item.amount <= 0:
		held_item = null

	inv.inventory_changed.emit()


func paint_slot(address: InventorySlotAddress) -> void:
	if address == null or address.storage == InventorySlotAddress.Storage.TRASH:
		return

	if held_item == null or held_item.amount <= 0:
		return

	if last_interacted_slot != null and last_interacted_slot.matches(address):
		return

	if pressed_slot != null and not is_paint_mode_active:
		is_paint_mode_active = true
		_paint_single_item(pressed_slot)

	if not is_paint_mode_active:
		return

	_paint_single_item(address)
	last_interacted_slot = address


func _paint_single_item(address: InventorySlotAddress) -> void:
	_drop_single_item_to_slot(_resolve_slot(address))


func handle_slot_double_click(address: InventorySlotAddress) -> void:
	if address == null or address.storage == InventorySlotAddress.Storage.TRASH:
		return

	if held_item == null or not ItemDB.is_stackable(held_item.item_id):
		return

	var target_item := held_item
	var target_state := target_item.get_freshness_state()

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


func _handle_shift_click(address: InventorySlotAddress) -> void:
	if address.storage == InventorySlotAddress.Storage.TRASH:
		return

	var from_slot := _resolve_slot(address)
	if from_slot.is_empty():
		return

	var from_array: Array[InventoryItem] = from_slot["array"]
	var from_index: int = from_slot["index"]

	if not inv.active_container_slots.is_empty():
		if address.storage == InventorySlotAddress.Storage.ACTIVE_CONTAINER:
			var moved := _transfer_to_range(
				from_array,
				from_index,
				inv.state.inventory_slots,
				0,
				GameConstants.Inventory.MAX_HOTBAR_IDX
			)
			if not moved:
				_transfer_to_range(
					from_array,
					from_index,
					inv.state.inventory_slots,
					GameConstants.Inventory.MAX_HOTBAR_IDX,
					inv.state.inventory_slots.size()
				)
		else:
			_transfer_to_range(
				from_array,
				from_index,
				inv.active_container_slots,
				0,
				inv.active_container_slots.size()
			)
	elif inv.is_backpack_open:
		var start := GameConstants.Inventory.MAX_HOTBAR_IDX if address.index < GameConstants.Inventory.MAX_HOTBAR_IDX else 0
		var end = inv.state.inventory_slots.size() if address.index < GameConstants.Inventory.MAX_HOTBAR_IDX else GameConstants.Inventory.MAX_HOTBAR_IDX
		_transfer_to_range(from_array, from_index, inv.state.inventory_slots, start, end)


func _transfer_to_range(
	from_array: Array[InventoryItem],
	from_index: int,
	to_array: Array[InventoryItem],
	start_index: int,
	end_index: int
) -> bool:
	var item = from_array[from_index]
	if item == null:
		return false

	if ItemDB.is_stackable(item.item_id):
		for i in range(start_index, end_index):
			var target = to_array[i]
			if target != null and inv._can_stack(target, item):
				target.merge_with(item)
				from_array[from_index] = null
				inv.inventory_changed.emit()
				return true

	for i in range(start_index, end_index):
		if to_array[i] == null:
			to_array[i] = item
			from_array[from_index] = null
			inv.inventory_changed.emit()
			return true

	return false
