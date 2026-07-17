extends Node

signal state_changed
signal money_changed(new_money: int)
signal day_changed(new_day: int)

var _is_save_queued: bool = false
var _pending_save_data: Dictionary = {}
var _pending_save_slot: int = 1
var _autosave_timer: Timer
var _state_update_depth: int = 0
var _save_requested_during_state_update: bool = false

var state: GameState = GameState.new()
var current_slot_index: int = 1

func _ready() -> void:
	
	_autosave_timer = Timer.new()
	_autosave_timer.wait_time = GameConstants.Persistence.AUTOSAVE_INTERVAL_SECONDS
	_autosave_timer.one_shot = false
	_autosave_timer.timeout.connect(_on_autosave_timeout)
	add_child(_autosave_timer)
	_autosave_timer.start()
	
	call_deferred("_connect_persistence_events")

func _connect_persistence_events() -> void:
	if not SceneManager.scene_changed.is_connected(_on_scene_changed):
		SceneManager.scene_changed.connect(_on_scene_changed)

func _on_autosave_timeout() -> void:
	if _can_autosave():
		save_game()

func _on_scene_changed(_scene_path: String) -> void:
	if _can_autosave():
		save_game()

func _can_autosave() -> bool:
	return TimeManager.is_active and SceneManager.get_active_level() != null
	
func new_game(slot_index: int) -> void:
	current_slot_index = slot_index
	state = GameState.new()
	TimeManager.reset_for_new_game()
	TimeManager.is_active = true
	save_game()
	_emit_all_signals()

func save_game() -> void:
	if _state_update_depth > 0:
		_save_requested_during_state_update = true
		return

	# Capture gameplay state now, before a scene transition can remove it.
	_pending_save_data = _build_save_data()
	_pending_save_slot = current_slot_index

	if _is_save_queued:
		return

	_is_save_queued = true
	call_deferred("_deferred_save_game")


func begin_state_update() -> void:
	_state_update_depth += 1


func end_state_update() -> void:
	if _state_update_depth <= 0:
		push_error("GameManager: end_state_update called without a matching begin.")
		return

	_state_update_depth -= 1
	if _state_update_depth == 0 and _save_requested_during_state_update:
		_save_requested_during_state_update = false
		save_game()

func save_game_now() -> bool:
	# Cancel any queued write. Its deferred callback will safely do nothing.
	_is_save_queued = false
	_pending_save_data = {}
	
	var data := _build_save_data()
	
	if not SaveManager.save_game(data, current_slot_index):
		push_error(
			"GameManager: Immediate save failed for slot %d." % current_slot_index
		)
		return false
	
	return true

func _build_save_data() -> Dictionary:
	SceneManager._serialize_active_dropped_items()

	return {
		"save_version": SaveMigrator.CURRENT_VERSION,
		"game_state": state.to_dict(),
		"clock": TimeManager.to_save_data(),
		"location": SceneManager.to_save_data(),
		"metadata": {
			"saved_at": Time.get_datetime_dict_from_system(),
			"day": state.day,
			"money": state.money
		}
	}

func _deferred_save_game() -> void:
	if not _is_save_queued:
		return
	
	_is_save_queued = false

	var data := _pending_save_data
	var slot_index := _pending_save_slot
	_pending_save_data = {}

	if not SaveManager.save_game(data, slot_index):
		push_error("GameManager: Save request failed for slot %d." % slot_index)


func load_game(slot_index: int) -> void:
	current_slot_index = slot_index

	var data := _load_migrated_save(slot_index)
	
	if data.is_empty():
		state = GameState.new()
		TimeManager.reset_for_new_game()
	else:
		state = GameState.new()
		state.from_dict(data["game_state"])
		TimeManager.load_from_save_data(data["clock"])
		SceneManager.load_from_save_data(data["location"])

	TimeManager.is_active = true
	_emit_all_signals()

func _load_migrated_save(slot_index: int) -> Dictionary:
	var primary_data := SaveManager.load_primary_game(slot_index)
	var migrated_primary := SaveMigrator.migrate(primary_data)
	
	if not migrated_primary.is_empty():
		return migrated_primary
	
	var backup_data := SaveManager.load_backup_game(slot_index)
	var migrated_backup := SaveMigrator.migrate(backup_data)
	
	if not migrated_backup.is_empty():
		SaveManager.report_backup_recovery(slot_index)
		return migrated_backup
	
	push_error("No valid primary or backup save exists for slot %d." % slot_index)
	return {}

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
