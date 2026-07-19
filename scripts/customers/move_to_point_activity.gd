extends CustomerActivity
class_name MoveToPointActivity

var destination: Vector2
var _is_finished: bool = false
var _navigation: CustomerNavigationController

func _init(target_position: Vector2) -> void:
	destination = target_position

func enter(customer: Customer) -> void:
	_navigation = customer.get_navigation_controller()
	
	if _navigation == null:
		push_error("MoveToPointActivity requires a CustomerNavigationController")
		_is_finished = true
		return
	
	_navigation.destination_reached.connect(_on_destination_reached, CONNECT_ONE_SHOT)
	_navigation.request_move_to(destination)

func exit(_customer: Customer) -> void:
	if _navigation != null and _navigation.is_moving():
		_navigation.cancel_navigation()

func is_finished(_customer: Customer) -> bool:
	return _is_finished

func _on_destination_reached(_reached_destination: Vector2) -> void:
	_is_finished = true
