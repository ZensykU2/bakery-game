extends Node
class_name CustomerScheduleDirector

signal visit_requested(request: CustomerVisitRequest)

@export var traffic_schedule: CustomerTrafficSchedule
@export var resident_roster: CustomerRoster
@export_range(1, 60, 1) var evaluation_interval_minutes: int = 15
@export_range(0.0, 1.0, 0.01) var tourist_probability: float = 0.60
@export_range(0.0, 1.0, 0.01) var arrivals_per_weight: float = 0.30

var _last_evaluated_slot: int = -1
var _arrival_progress: float = 0.0
var _planner := CustomerVisitPlanner.new()
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	TimeManager.time_changed.connect(_on_time_changed)
	GameManager.day_changed.connect(_on_day_changed)


func _exit_tree() -> void:
	if TimeManager.time_changed.is_connected(_on_time_changed):
		TimeManager.time_changed.disconnect(_on_time_changed)
	if GameManager.day_changed.is_connected(_on_day_changed):
		GameManager.day_changed.disconnect(_on_day_changed)


func evaluate_arrivals(current_day: int, minute_of_day: int) -> CustomerVisitRequest:
	if traffic_schedule == null or resident_roster == null:
		return null
	if not BakeryOperations.is_open():
		return null

	var safe_minute := posmod(minute_of_day, int(GameConstants.TimeManage.MINUTES_IN_DAY))
	var total_minutes := current_day * int(GameConstants.TimeManage.MINUTES_IN_DAY) + safe_minute
	var evaluation_slot := total_minutes / evaluation_interval_minutes
	if evaluation_slot == _last_evaluated_slot:
		return null
	_last_evaluated_slot = evaluation_slot

	var arrival_weight := traffic_schedule.get_arrival_weight(safe_minute)
	_arrival_progress += arrival_weight * arrivals_per_weight
	if _arrival_progress < 1.0:
		return null
	_arrival_progress -= 1.0

	return _planner.create_visit_request(
		resident_roster,
		GameManager.state.tourist_roster,
		current_day,
		safe_minute,
		tourist_probability,
		_rng,
		CustomerManager.get_active_customer_ids()
	)


func _on_time_changed(hour: int, minute: int) -> void:
	var request := evaluate_arrivals(TimeManager.day, hour * 60 + minute)
	if request != null:
		visit_requested.emit(request)


func _on_day_changed(_new_day: int) -> void:
	_last_evaluated_slot = -1
	_arrival_progress = 0.0
