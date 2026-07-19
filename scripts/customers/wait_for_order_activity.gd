extends CustomerActivity
class_name WaitForOrderActivity

signal order_completed(customer: Customer, result: CustomerOrderResult)

var order_intent: CustomerOrderIntent
var duration_minutes: int
var _wait_activity: WaitForGameMinutesActivity
var _indicator: Node
var _fulfillment_service: CustomerOrderFulfillmentService
var _completion_handled: bool = false


func _init(
		initial_order_intent: CustomerOrderIntent,
		initial_duration_minutes: int,
		fulfillment_service: CustomerOrderFulfillmentService
	) -> void:
	order_intent = initial_order_intent
	duration_minutes = initial_duration_minutes
	_fulfillment_service = fulfillment_service


func enter(customer: Customer) -> void:
	_wait_activity = WaitForGameMinutesActivity.new(duration_minutes)
	_wait_activity.enter(customer)
	_spawn_indicator(customer)


func tick(customer: Customer, delta: float) -> void:
	_wait_activity.tick(customer, delta)
	if _wait_activity.is_finished(customer) and not _completion_handled:
		_completion_handled = true
		var result := _fulfillment_service.fulfill(
			order_intent,
			GameManager.state.casing_slots
		)
		order_completed.emit(customer, result)


func exit(customer: Customer) -> void:
	_wait_activity.exit(customer)
	if is_instance_valid(_indicator):
		_indicator.queue_free()
	_indicator = null


func is_finished(customer: Customer) -> bool:
	return _wait_activity != null and _wait_activity.is_finished(customer)


func _spawn_indicator(customer: Customer) -> void:
	if order_intent == null or order_intent.item_id.is_empty():
		return

	var icon := ItemDB.get_item_icon(order_intent.item_id, 1.0)
	if icon == null:
		return

	var indicator_scene := load(GameConstants.Paths.FLOATY_ICON_SCENE_PATH) as PackedScene
	if indicator_scene == null:
		return

	_indicator = indicator_scene.instantiate()
	customer.add_child(_indicator)
	_indicator.position = Vector2(0, -24)
	_indicator.start(order_intent.item_id, icon)
	var click_area := _indicator.get_node_or_null("ClickArea") as Area2D
	if click_area != null:
		click_area.input_pickable = false
