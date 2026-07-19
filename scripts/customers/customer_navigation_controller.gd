extends Node2D
class_name CustomerNavigationController

signal destination_started(destination: Vector2)
signal destination_reached(destination: Vector2)
signal destination_unreachable(destination: Vector2)

@export var movement_speed: float = 40.0
@export var stopping_distance: float = 4.0

@onready var customer: Customer = get_parent() as Customer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var _destination: Vector2 = Vector2.ZERO
var _has_destination: bool = false
var _request_version: int = 0

func _ready() -> void:
	navigation_agent.path_desired_distance = stopping_distance
	navigation_agent.target_desired_distance = stopping_distance
	set_physics_process(false)

func request_move_to(destination: Vector2) -> void:
	_destination = destination
	_has_destination = true
	_request_version += 1
	call_deferred("_active_navigation_request", _request_version)

func cancel_navigation() -> void:
	_has_destination = false
	customer.velocity = Vector2.ZERO
	set_physics_process(false)

func is_moving() -> bool:
	return _has_destination

func _active_navigation_request(request_version: int) -> void:
	await _wait_for_navigation_map()

	if not _has_destination or request_version != _request_version:
		return

	navigation_agent.target_position = _destination
	set_physics_process(true)
	destination_started.emit(_destination)

func _wait_for_navigation_map() -> void:
	var navigation_map := navigation_agent.get_navigation_map()

	while NavigationServer2D.map_get_iteration_id(navigation_map) == 0:
		await get_tree().physics_frame

	# The map exists after the first synchronization; give the region one
	# additional physics frame to upload its polygon into that map.
	await get_tree().physics_frame
	
func _physics_process(_delta: float) -> void:
	if not _has_destination:
		return

	if NavigationServer2D.map_get_iteration_id(
		navigation_agent.get_navigation_map()
	) == 0:
		return

	if navigation_agent.is_navigation_finished():
		if navigation_agent.is_target_reached():
			_finish_navigation()
		else:
			_finish_unreachable()
		return

	var next_path_position := navigation_agent.get_next_path_position()

	if not navigation_agent.is_target_reachable():
		_finish_unreachable()
		return

	var direction := customer.global_position.direction_to(next_path_position)
	customer.velocity = direction * movement_speed
	customer.move_and_slide()

func _finish_navigation() -> void:
	var reached_destination := _destination
	_has_destination = false
	customer.velocity = Vector2.ZERO
	set_physics_process(false)
	destination_reached.emit(reached_destination)

func _finish_unreachable() -> void:
	var unreachable_destination := _destination
	cancel_navigation()
	destination_unreachable.emit(unreachable_destination)
