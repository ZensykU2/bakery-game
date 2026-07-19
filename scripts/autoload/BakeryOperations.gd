extends Node

signal opening_changed(is_open: bool)


func is_open() -> bool:
	return GameManager.state.bakery_is_open


func open_bakery() -> bool:
	if is_open():
		return false

	GameManager.state.bakery_is_open = true
	GameManager.state.bakery_opened_day = GameManager.get_day()
	GameManager.state.bakery_opened_minute = int(TimeManager.time_in_minutes)
	opening_changed.emit(true)
	GameManager.state_changed.emit()
	GameManager.save_game()
	return true


func close_bakery() -> bool:
	if not is_open():
		return false

	GameManager.state.bakery_is_open = false
	opening_changed.emit(false)
	GameManager.state_changed.emit()
	GameManager.save_game()
	return true


func begin_new_day() -> void:
	GameManager.state.bakery_is_open = false
	GameManager.state.bakery_opened_day = 0
	GameManager.state.bakery_opened_minute = -1
	GameManager.state.bakery_open_minutes_today = 0
	opening_changed.emit(false)


func _ready() -> void:
	TimeManager.minutes_passed.connect(_on_minutes_passed)


func _on_minutes_passed(elapsed_minutes: int) -> void:
	if is_open():
		GameManager.state.bakery_open_minutes_today += elapsed_minutes
