extends Node

@export var spawn_destination_id: StringName = &"bakery_debug_spawn"
@export var destination_id: StringName = &"bakery_debug_inside"
@export var spawn_on_ready: bool = false

var spawned_customer: Customer

func _ready() -> void:
	if spawn_on_ready:
		call_deferred("spawn_test_customer")

func spawn_test_customer() -> void:
	await get_tree().process_frame

	var profile := CustomerProfile.new()
	profile.customer_id = "debug_customer"
	profile.display_name = "Navigation Tester"
	profile.origin = CustomerProfile.Origin.TOURIST
	profile.generation_seed = 1

	spawned_customer = CustomerManager.spawn_customer(
		profile,
		spawn_destination_id
	)

	if spawned_customer == null:
		return

	_add_debug_visual(spawned_customer)

	var navigation := spawned_customer.get_navigation_controller()
	if navigation == null:
		push_error("CustomerDebugSpawner: Customer has no NavigationController.")
		return

	navigation.destination_reached.connect(
		func(_position: Vector2) -> void:
			print("Customer navigation test: destination reached.")
	)
	navigation.destination_unreachable.connect(
		func(_position: Vector2) -> void:
			push_error("Customer navigation test: destination is unreachable.")
	)

	var activity_controller := spawned_customer.get_node_or_null(
		"ActivityController"
	) as CustomerActivityController

	if activity_controller == null:
		push_error("CustomerDebugSpawner: Customer has no ActivityController.")
		return
	
	activity_controller.set_activity(
		MoveToDestinationActivity.new(destination_id)
	)

func _add_debug_visual(customer: Customer) -> void:
	var marker := Polygon2D.new()
	marker.polygon = PackedVector2Array([
		Vector2(0, -16),
		Vector2(10, -6),
		Vector2(0, 4),
		Vector2(-10, -6),
	])
	marker.color = Color(0.3, 1.0, 0.5)
	marker.z_index = 50
	customer.add_child(marker)
