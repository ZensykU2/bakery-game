extends CustomerActivity
class_name WaitForGameMinutesActivity

var duration_minutes: int
var _remaining_minutes: int
var _is_finished: bool = false


func _init(initial_duration_minutes: int) -> void:
	duration_minutes = maxi(0, initial_duration_minutes)


func enter(_customer: Customer) -> void:
	_remaining_minutes = duration_minutes
	_is_finished = _remaining_minutes == 0
	if not _is_finished:
		TimeManager.minutes_passed.connect(_on_minutes_passed)


func exit(_customer: Customer) -> void:
	if TimeManager.minutes_passed.is_connected(_on_minutes_passed):
		TimeManager.minutes_passed.disconnect(_on_minutes_passed)


func is_finished(_customer: Customer) -> bool:
	return _is_finished


func _on_minutes_passed(elapsed_minutes: int) -> void:
	_remaining_minutes -= elapsed_minutes
	_is_finished = _remaining_minutes <= 0
