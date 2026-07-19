extends CustomerActivity
class_name MoveToDestinationActivity

var destination_id: StringName
var _movement_activity: MoveToPointActivity
var _is_finished: bool = false

func _init(target_destination_id: StringName) -> void:
	destination_id = target_destination_id

func enter(customer: Customer) -> void:
	var destination := CustomerDestinationRegistry.get_destination(destination_id)
	
	if destination == null:
		push_error(
			"MoveToDestinationActivity could not find destination '%s'." % destination_id
		)
		_is_finished = true
		return
	
	_movement_activity = MoveToPointActivity.new(destination.global_position)
	_movement_activity.enter(customer)

func tick(customer: Customer, delta: float) -> void:
	if _movement_activity != null:
		_movement_activity.tick(customer, delta)

func exit(customer: Customer) -> void:
	if _movement_activity != null:
		_movement_activity.exit(customer)

func is_finished(customer: Customer) -> bool:
	return _is_finished or (
		_movement_activity != null
		and _movement_activity.is_finished(customer)
	)
