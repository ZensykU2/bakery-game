extends Node

signal state_changed
signal money_changed(new_money: int)
signal day_changed(new_day: int)

var state: GameState = GameState.new()
var current_slot_index: int = 1

func _ready() -> void:
	Services.game = self
	# Avoid loading save files during autoload initialization (handled by title screen)
	pass

func new_game(slot_index: int) -> void:
	current_slot_index = slot_index
	state = GameState.new()
	TimeManager.is_active = true
	save_game()
	_emit_all_signals()

var _is_save_queued: bool = false

func save_game() -> void:
	if _is_save_queued:
		return
	_is_save_queued = true
	call_deferred("_deferred_save_game")

func _deferred_save_game() -> void:
	_is_save_queued = false
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager and scene_manager.has_method("_serialize_active_dropped_items"):
		scene_manager._serialize_active_dropped_items()
	var data = state.to_dict()
	
	data["metadata"] = {
		"saved_at": Time.get_datetime_dict_from_system(),
		"day": state.day,
		"money": state.money
	}
	
	SaveManager.save_game(data, current_slot_index)


func load_game(slot_index: int) -> void:
	current_slot_index = slot_index
	var data = SaveManager.load_game(slot_index)
	if data.is_empty():
		state = GameState.new()
	else:
		state = GameState.new()
		state.from_dict(data)

	TimeManager.is_active = true
	_emit_all_signals()

func next_day() -> void:
	state.day += 1
	state.dropped_items.clear()
	state.dropped_items_timer = -1.0
	var current_level = SceneManager.get_active_level()
	if current_level:
		var active_drops = current_level.find_children("*", "DroppedItem", true, false)
		for drop in active_drops:
			drop.queue_free()
			
	day_changed.emit(state.day)
	state_changed.emit()
	save_game()

func give_daily_allowance() -> void:
	InventoryManager.add_item("berries", 1)
	InventoryManager.add_item("eggs", 1)

func add_money(amount: int) -> void:
	state.money += amount
	money_changed.emit(state.money)
	state_changed.emit()
	save_game()

func get_day() -> int:
	return state.day

func get_money() -> int:
	return state.money

func get_inventory() -> Dictionary:
	var summary := {}
	for item in state.inventory_slots:
		if item != null:
			summary[item.item_id] = summary.get(item.item_id, 0) + item.amount
	return summary

func _emit_all_signals() -> void:
	day_changed.emit(state.day)
	money_changed.emit(state.money)
	InventoryManager.inventory_changed.emit()
	state_changed.emit()
