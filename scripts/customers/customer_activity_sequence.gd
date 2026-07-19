extends CustomerActivity
class_name CustomerActivitySequence

var activities: Array[CustomerActivity] = []
var _current_index: int = 0
var _is_finished: bool = false


func _init(initial_activities: Array[CustomerActivity] = []) -> void:
	activities = initial_activities


func enter(customer: Customer) -> void:
	if activities.is_empty():
		_is_finished = true
		return
	activities[_current_index].enter(customer)


func tick(customer: Customer, delta: float) -> void:
	if _is_finished:
		return

	var current_activity := activities[_current_index]
	current_activity.tick(customer, delta)
	if not current_activity.is_finished(customer):
		return

	current_activity.exit(customer)
	_current_index += 1
	if _current_index >= activities.size():
		_is_finished = true
		return
	activities[_current_index].enter(customer)


func exit(customer: Customer) -> void:
	if not _is_finished and _current_index < activities.size():
		activities[_current_index].exit(customer)


func is_finished(_customer: Customer) -> bool:
	return _is_finished
