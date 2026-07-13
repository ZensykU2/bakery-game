extends Node

signal state_changed
signal money_changed(new_money: int)
signal day_changed(new_day: int)

var state: GameState = GameState.new()
var current_slot_index: int = 1

func _ready() -> void:
	# Avoid loading save files during autoload initialization (handled by title screen)
	pass

func new_game(slot_index: int) -> void:
	current_slot_index = slot_index
	state = GameState.new()
	save_game()
	_emit_all_signals()

func save_game() -> void:
	SaveManager.save_game(state.to_dict(), current_slot_index)

func load_game(slot_index: int) -> void:
	current_slot_index = slot_index
	var data = SaveManager.load_game(slot_index)
	if data.is_empty():
		state = GameState.new()
	else:
		state = GameState.new()
		state.from_dict(data)

	_emit_all_signals()

func next_day() -> void:
	state.day += 1
	state.dropped_items.clear()
	
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
