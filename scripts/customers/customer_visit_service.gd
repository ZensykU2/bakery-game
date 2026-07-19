extends Node
class_name CustomerVisitService

@export var schedule_director: CustomerScheduleDirector
@export var spawn_destination_id: StringName = &"bakery_debug_spawn"
@export var entrance_destination_id: StringName = &"bakery_entrance_inside"
@export_range(1, 180, 1) var visit_duration_minutes: int = 20
@export_range(1, 20, 1) var max_active_customers: int = 3
@export_range(0, 5, 1) var max_browse_stops: int = 2

var _rng := RandomNumberGenerator.new()
var _reserved_browse_destinations: Dictionary = {}
var _route_planner := CustomerVisitRoutePlanner.new()
var _order_planner := CustomerOrderPlanner.new()
var _fulfillment_service := CustomerOrderFulfillmentService.new()


func _ready() -> void:
	_rng.randomize()
	if schedule_director == null:
		push_error("CustomerVisitService requires a CustomerScheduleDirector.")
		return
	schedule_director.visit_requested.connect(_on_visit_requested)


func _exit_tree() -> void:
	if schedule_director != null and schedule_director.visit_requested.is_connected(_on_visit_requested):
		schedule_director.visit_requested.disconnect(_on_visit_requested)


func start_visit(request: CustomerVisitRequest) -> Customer:
	if request == null or request.profile == null:
		return null
	if CustomerManager.get_active_customer_count() >= max_active_customers:
		return null
	if CustomerManager.get_customer(request.profile.customer_id) != null:
		return null

	var visit_plan := _create_visit_plan(request.profile.customer_id)
	if visit_plan == null:
		return null
	request.order_intent = _order_planner.create_intent(
		_get_displayed_item_ids(),
		_rng
	)

	var customer := CustomerManager.spawn_customer(request.profile, spawn_destination_id)
	if customer == null:
		return null

	var activity_controller := customer.get_node_or_null(
		"ActivityController"
	) as CustomerActivityController
	if activity_controller == null:
		push_error("CustomerVisitService: Customer is missing ActivityController.")
		CustomerManager.despawn_customer(request.profile.customer_id)
		return null

	var activities: Array[CustomerActivity] = [
		MoveToDestinationActivity.new(entrance_destination_id),
	]
	for destination_id in visit_plan.get_indoor_route():
		activities.append(MoveToDestinationActivity.new(destination_id))
	if request.order_intent != null:
		var order_wait := WaitForOrderActivity.new(
			request.order_intent,
			visit_duration_minutes,
			_fulfillment_service
		)
		order_wait.order_completed.connect(_on_order_completed)
		activities.append(order_wait)
	else:
		activities.append(WaitForGameMinutesActivity.new(visit_duration_minutes))
	activities.append(BeginLeavingActivity.new())
	activities.append(MoveToDestinationActivity.new(entrance_destination_id))
	activities.append(MoveToDestinationActivity.new(spawn_destination_id))

	var visit_sequence := CustomerActivitySequence.new(activities)
	activity_controller.activity_changed.connect(
		_on_customer_activity_changed.bind(request.profile.customer_id, visit_sequence)
	)
	activity_controller.set_activity(visit_sequence)
	return customer


func _on_visit_requested(request: CustomerVisitRequest) -> void:
	start_visit(request)


func _on_customer_activity_changed(
		previous_activity: CustomerActivity,
		next_activity: CustomerActivity,
		customer_id: String,
		visit_sequence: CustomerActivitySequence
	) -> void:
	if previous_activity == visit_sequence and next_activity == null:
		_release_browse_destinations(customer_id)
		CustomerManager.despawn_customer(customer_id)


func _create_visit_plan(customer_id: String) -> CustomerVisitPlan:
	var available_browse_ids: Array[StringName] = []
	var reserved_ids: Array[StringName] = []
	for destination_ids in _reserved_browse_destinations.values():
		if destination_ids is Array:
			for destination_id in destination_ids:
				reserved_ids.append(StringName(destination_id))
	for destination in CustomerDestinationRegistry.get_destinations_by_purpose(
		CustomerDestination.Purpose.BROWSE
	):
		if not reserved_ids.has(destination.destination_id):
			available_browse_ids.append(destination.destination_id)

	var order_destination_ids: Array[StringName] = []
	for destination in CustomerDestinationRegistry.get_destinations_by_purpose(
		CustomerDestination.Purpose.ORDER
	):
		order_destination_ids.append(destination.destination_id)

	var plan := _route_planner.create_plan(
		available_browse_ids,
		order_destination_ids,
		max_browse_stops,
		_rng
	)
	if plan == null:
		push_error("CustomerVisitService: No bakery order destinations are available.")
		return null

	_reserved_browse_destinations[customer_id] = plan.browse_destination_ids.duplicate()
	return plan


func _release_browse_destinations(customer_id: String) -> void:
	_reserved_browse_destinations.erase(customer_id)


func _get_displayed_item_ids() -> Array[String]:
	var item_ids: Array[String] = []
	for slots in GameManager.state.casing_slots.values():
		if not slots is Array:
			continue
		for item in slots:
			if item is InventoryItem and not item.item_id.is_empty():
				item_ids.append(item.item_id)
	return item_ids


func _on_order_completed(customer: Customer, result: CustomerOrderResult) -> void:
	if not result.fulfilled:
		return

	GameManager.add_money(result.earned_money)
	InventoryManager.inventory_changed.emit()
	_spawn_sale_feedback(customer, result.earned_money)


func _spawn_sale_feedback(customer: Customer, earned_money: int) -> void:
	var floaty_scene := load(GameConstants.Paths.FLOATY_ICON_SCENE_PATH) as PackedScene
	if floaty_scene == null:
		return

	var feedback := floaty_scene.instantiate()
	customer.add_child(feedback)
	feedback.position = Vector2(0, -40)
	feedback.start_text("+$%d" % earned_money, Color(0.2, 0.8, 0.2))
