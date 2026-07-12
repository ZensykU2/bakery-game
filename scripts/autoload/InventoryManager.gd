extends Node

signal inventory_changed

var state: GameState:
	get: return GameManager.state

var held_item: InventoryItem = null
var last_interacted_slot_index: int = -1

var pressed_slot_index: int = -1
var is_paint_mode_active: bool = false

func _get_container_ui() -> CanvasLayer:
	return SceneManager.get_container_ui()

func _get_hud() -> CanvasLayer:
	return SceneManager.get_hud()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if pressed_slot_index != -1 and not is_paint_mode_active:
			_execute_left_click_swap(pressed_slot_index)
			
		pressed_slot_index = -1
		last_interacted_slot_index = -1
		is_paint_mode_active = false

func get_item_count(item_id: String) -> int:
	var total = 0
	for item in state.inventory_slots:
		if item != null and item.item_id == item_id:
			total += item.amount
	return total

func can_craft(recipe_name: String) -> bool:
	if not ItemDB.has_recipe(recipe_name):
		return false
	var recipe = ItemDB.get_recipe(recipe_name)
	var ingredients: Dictionary = recipe.get("ingredients", {})
	for item in ingredients.keys():
		if get_item_count(item) < ingredients[item]:
			return false
	return true

func add_item(item_name: String, amount: int) -> bool:
	var new_item = InventoryItem.new()
	new_item.item_id = item_name
	new_item.amount = amount
	new_item.freshness = 1.0
	
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

func _resolve_slot(slot_index: int) -> Dictionary:
	var container_ui = _get_container_ui()
	var array = state.inventory_slots
	var idx = slot_index
	
	if slot_index >= 100 and container_ui and container_ui.visible:
		array = container_ui.active_container_array
		idx = slot_index - 100
		
	return {
		"array": array,
		"index": idx,
		"item": array[idx]
	}

func _set_slot_item(slot: Dictionary, item: InventoryItem) -> void:
	slot.array[slot.index] = item


func handle_slot_click(slot_index: int, is_shift: bool, is_pressed: bool) -> void:
	if slot_index == 999 and is_pressed:
		if held_item != null:
			held_item = null
			inventory_changed.emit()
			GameManager.save_game()
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
			if _can_stack(slot.item, held_item):
				slot.item.amount += held_item.amount
				held_item = null
			else:
				var temp = slot.item
				_set_slot_item(slot, held_item)
				held_item = temp
				
	inventory_changed.emit()

func handle_slot_right_click(slot_index: int) -> void:
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
		
	inventory_changed.emit()

func _drop_single_item_to_slot(slot: Dictionary) -> void:
	if held_item == null or held_item.amount <= 0:
		return
		
	if slot.item == null:
		_set_slot_item(slot, held_item.clone(1))
	elif _can_stack(slot.item, held_item):
		slot.item.amount += 1
	else:
		return
		
	held_item.amount -= 1
	if held_item.amount <= 0:
		held_item = null
	inventory_changed.emit()

func paint_slot(slot_index: int) -> void:
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

func handle_slot_double_click(_slot_index: int) -> void:
	if held_item == null:
		return
		
	var target_item_id = held_item.item_id
	var target_freshness = held_item.freshness
	
	if not ItemDB.is_stackable(target_item_id):
		return
		
	var container_ui = _get_container_ui()
	
	for i in range(state.inventory_slots.size()):
		var item = state.inventory_slots[i]
		if item != null and item.item_id == target_item_id and abs(item.freshness - target_freshness) < 0.05:
			held_item.amount += item.amount
			state.inventory_slots[i] = null
			
	if container_ui and container_ui.visible:
		for i in range(container_ui.active_container_array.size()):
			var item = container_ui.active_container_array[i]
			if item != null and item.item_id == target_item_id and abs(item.freshness - target_freshness) < 0.05:
				held_item.amount += item.amount
				container_ui.active_container_array[i] = null
				
	inventory_changed.emit()

func _handle_shift_click(slot_index: int) -> void:
	var container_ui = _get_container_ui()
	var is_container_open = container_ui and container_ui.visible
	
	var from_slot = _resolve_slot(slot_index)
	var from_array = from_slot.array
	var from_local_index = from_slot.index
	
	if is_container_open:
		if slot_index >= 100:
			var success = _transfer_to_range(from_array, from_local_index, state.inventory_slots, 0, 9)
			if not success:
				_transfer_to_range(from_array, from_local_index, state.inventory_slots, 9, state.inventory_slots.size())
		else:
			var to_array = container_ui.active_container_array
			_transfer_to_range(from_array, from_local_index, to_array, 0, to_array.size())
	else:
		var hud = _get_hud()
		if hud and hud.backdrop.visible:
			var start = 9 if slot_index < 9 else 0
			var end = state.inventory_slots.size() if slot_index < 9 else 9
			_transfer_to_range(from_array, from_local_index, state.inventory_slots, start, end)

func _transfer_to_range(from_array: Array[InventoryItem], from_idx: int, to_array: Array[InventoryItem], start_idx: int, end_idx: int) -> bool:
	var item = from_array[from_idx]
	if item == null:
		return false
		
	if ItemDB.is_stackable(item.item_id):
		for i in range(start_idx, end_idx):
			var target = to_array[i]
			if target != null and target.item_id == item.item_id:
				target.amount += item.amount
				from_array[from_idx] = null
				inventory_changed.emit()
				return true
				
	for i in range(start_idx, end_idx):
		if to_array[i] == null:
			to_array[i] = item
			from_array[from_idx] = null
			inventory_changed.emit()
			return true
			
	return false

func _can_stack(item_a: InventoryItem, item_b: InventoryItem) -> bool:
	if item_a == null or item_b == null:
		return false
	
	return item_a.item_id == item_b.item_id and ItemDB.is_stackable(item_a.item_id)

func add_inventory_item_resource(new_item: InventoryItem) -> bool:
	var slots = state.inventory_slots
	if ItemDB.is_stackable(new_item.item_id):
		for item in slots:
			if item != null and item.item_id == new_item.item_id:
				item.amount += new_item.amount
				return true
				
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = new_item
			return true
	return false

func drop_held_item_to_world() -> void:
	if held_item == null:
		return
		
	var player = SceneManager.get_player()
	var active_level = SceneManager.get_active_level()
	
	if player and active_level:
		var drop_pos = player.global_position + Vector2(0, 16)

		if state.dropped_items.size() >= 50:
			state.dropped_items.remove_at(0)

		var drop_scene = load("res://scenes/world/DroppedItem.tscn")
		var instance = drop_scene.instantiate()
		instance.global_position = drop_pos
		instance.item = held_item 
		active_level.add_child(instance)

		held_item = null
		inventory_changed.emit()
		GameManager.save_game()
