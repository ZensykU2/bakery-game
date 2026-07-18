extends Node
class_name CustomerActivityController

signal activity_changed(previous_activity: CustomerActivity, next_activity: CustomerActivity)

var customer: Customer
var current_activity: CustomerActivity


func _ready() -> void:
	initialize(get_parent() as Customer)
	set_physics_process(false)


func initialize(owner_customer: Customer) -> void:
	customer = owner_customer


func set_activity(next_activity: CustomerActivity) -> bool:
	if customer == null or next_activity == current_activity:
		return false

	var previous_activity := current_activity
	if previous_activity != null:
		previous_activity.exit(customer)

	current_activity = next_activity
	current_activity.enter(customer)
	set_physics_process(true)
	activity_changed.emit(previous_activity, current_activity)
	return true


func clear_activity() -> void:
	if current_activity == null:
		return

	var previous_activity := current_activity
	previous_activity.exit(customer)
	current_activity = null
	set_physics_process(false)
	activity_changed.emit(previous_activity, null)


func _physics_process(delta: float) -> void:
	if current_activity == null:
		return

	current_activity.tick(customer, delta)

	if current_activity.is_finished(customer):
		clear_activity()
