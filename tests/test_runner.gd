extends Node

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_inventory_item_value_behavior()
	_test_bake_strategy_save_compatibility()
	_test_dropped_item_record_round_trip()
	_test_game_state_round_trip()
	_test_save_migrations()
	_test_customer_profile_round_trip()
	_test_customer_lifecycle()
	_test_customer_activity_controller()
	_test_customer_traffic_schedule()
	_test_customer_roster_creates_runtime_profiles()
	_test_tourist_roster_persistence_and_replacement()
	_test_customer_visit_planner()
	_test_customer_activity_sequence()
	_test_customer_schedule_director_arrivals()
	_test_customer_destination_purpose()
	_test_customer_visit_route_planner()
	_test_customer_order_planner()
	_test_customer_order_fulfillment()
	_test_bakery_open_state_persistence()

	if failures.is_empty():
		print("TESTS PASSED: 19 deterministic test groups completed.")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error("TEST FAILED: %s" % failure)
	get_tree().quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

class RecordingCustomerActivity extends CustomerActivity:
	var entered_count: int = 0
	var exited_count: int = 0

	func enter(_customer: Customer) -> void:
		entered_count += 1

	func exit(_customer: Customer) -> void:
		exited_count += 1

class CompletedCustomerActivity extends CustomerActivity:
	var entered_count: int = 0
	var exited_count: int = 0

	func enter(_customer: Customer) -> void:
		entered_count += 1

	func exit(_customer: Customer) -> void:
		exited_count += 1

	func is_finished(_customer: Customer) -> bool:
		return true

func _test_customer_activity_controller() -> void:
	var customer := Customer.new()
	var controller := CustomerActivityController.new()
	controller.initialize(customer)

	var first_activity := RecordingCustomerActivity.new()
	var second_activity := RecordingCustomerActivity.new()

	_expect(
		controller.set_activity(first_activity),
		"Activity controller must accept an activity."
	)
	_expect(first_activity.entered_count == 1, "Activity enter must run once.")

	controller.set_activity(second_activity)
	_expect(first_activity.exited_count == 1, "Replacing an activity must exit the old one.")
	_expect(second_activity.entered_count == 1, "Replacement activity must enter once.")

	controller.clear_activity()
	_expect(second_activity.exited_count == 1, "Clearing an activity must exit it.")

	controller.free()
	customer.free()


func _test_inventory_item_value_behavior() -> void:
	var fresh_item := InventoryItem.new()
	fresh_item.item_id = "flour"
	fresh_item.amount = 2
	fresh_item.freshness = 1.0

	var copied_item := fresh_item.clone(1)
	_expect(copied_item != fresh_item, "InventoryItem.clone must create a new item.")
	_expect(copied_item.amount == 1, "InventoryItem.clone must use the requested amount.")

	var stale_item := fresh_item.clone(3)
	stale_item.freshness = 0.5
	fresh_item.merge_with(stale_item)
	_expect(fresh_item.amount == 5, "InventoryItem.merge_with must add amounts.")
	_expect(is_equal_approx(fresh_item.freshness, 0.7), "InventoryItem.merge_with must weight freshness by amount.")


func _test_bake_strategy_save_compatibility() -> void:
	var legacy_bake := BakeStrategy.create_from_dict({
		"recipe_name": "donut",
		"time_remaining": 12.0,
		"is_finished": false
	})
	_expect(legacy_bake.recipe_id == "donut", "Legacy bake saves must restore recipe_name as recipe_id.")
	_expect(legacy_bake.to_dict().has("recipe_id"), "New bake saves must write recipe_id.")


func _test_dropped_item_record_round_trip() -> void:
	var item := InventoryItem.new()
	item.item_id = "berries"
	item.amount = 2
	item.freshness = 0.8
	var record := DroppedItemRecord.from_world_item("res://scenes/bakery/Bakery.tscn", item, Vector2(20, 40))
	var restored := DroppedItemRecord.from_dict(record.to_dict())

	_expect(restored.scene_path == record.scene_path, "Dropped item scene path must persist.")
	_expect(restored.item.item_id == "berries" and restored.item.amount == 2, "Dropped item data must persist.")
	_expect(restored.position == Vector2(20, 40), "Dropped item position must persist.")


func _test_game_state_round_trip() -> void:
	var original := GameState.new()
	original.day = 4
	original.money = 125
	var saved_data := original.to_dict()
	var restored := GameState.new()
	restored.from_dict(saved_data)

	_expect(restored.day == 4 and restored.money == 125, "GameState must preserve day and money.")
	_expect(
		restored.inventory_slots.size() == original.inventory_slots.size(),
		"GameState must preserve inventory capacity."
	)

func _test_customer_profile_round_trip() -> void:
	var profile := CustomerProfile.new()
	profile.customer_id = "tourist_001"
	profile.display_name = "Mila"
	profile.origin = CustomerProfile.Origin.TOURIST
	profile.age_group = CustomerProfile.AgeGroup.OLDER_ADULT
	profile.wealth_tier = CustomerProfile.WealthTier.AFFLUENT
	profile.personality = CustomerProfile.Personality.FOODIE
	profile.visit_count = 4
	profile.last_selected_day = 12
	profile.generation_seed = 48291

	var restored := CustomerProfile.from_dict(profile.to_dict())

	_expect(restored.customer_id == "tourist_001", "Customer ID must persist.")
	_expect(restored.is_tourist(), "Customer origin must persist.")
	_expect(
		restored.personality == CustomerProfile.Personality.FOODIE,
		"Customer personality must persist."
	)
	_expect(restored.generation_seed == 48291, "Customer appearance seed must persist.")

func _test_save_migrations() -> void:
	var migrated_legacy := SaveMigrator.migrate({"day": 2, "money": 50})
	_expect(migrated_legacy.get("save_version", -1) == SaveMigrator.CURRENT_VERSION, "Legacy saves must migrate to the current version.")
	_expect(migrated_legacy.has("location"), "Legacy saves must receive location data.")

	var migrated_v1 := SaveMigrator.migrate({
		"save_version": 1,
		"game_state": {"day": 3, "money": 20},
		"clock": {"time_in_minutes": 480.0},
		"metadata": {}
	})
	_expect(migrated_v1.get("save_version", -1) == SaveMigrator.CURRENT_VERSION, "Version 1 saves must migrate to the current version.")
	_expect(migrated_v1.has("location"), "Version 1 saves must receive location data.")

func _test_customer_lifecycle() -> void:
	var customer := Customer.new()
	var profile := CustomerProfile.new()
	profile.customer_id = "resident_baker"

	customer.initialize(profile)
	customer.activate()
	customer.begin_leaving()
	customer.mark_despawned()

	_expect(customer.profile == profile, "Customer must retain its profile.")
	_expect(
		customer.lifecycle_state == Customer.LifecycleState.DESPAWNED,
		"Customer lifecycle must reach DESPAWNED."
	)

	customer.free()

func _test_customer_traffic_schedule() -> void:
	var schedule := CustomerTrafficSchedule.new()
	schedule.default_arrival_weight = 0.05

	var morning := CustomerTrafficWindow.new()
	morning.start_minute = 420
	morning.end_minute = 570
	morning.arrival_weight = 1.0

	var quiet_afternoon := CustomerTrafficWindow.new()
	quiet_afternoon.start_minute = 780
	quiet_afternoon.end_minute = 960
	quiet_afternoon.arrival_weight = 0.15

	schedule.windows = [morning, quiet_afternoon]

	_expect(
		is_equal_approx(schedule.get_arrival_weight(480), 1.05),
		"Morning rush weight must include its traffic window."
	)
	_expect(
		is_equal_approx(schedule.get_arrival_weight(840), 0.20),
		"Quiet afternoon weight must include its traffic window."
	)
	_expect(
		is_equal_approx(schedule.get_arrival_weight(600), 0.05),
		"Unscheduled time must use the default traffic weight."
	)

func _test_customer_roster_creates_runtime_profiles() -> void:
	var resident := CustomerProfile.new()
	resident.customer_id = "resident_example"
	resident.display_name = "Example"
	resident.origin = CustomerProfile.Origin.RESIDENT
	resident.generation_seed = 42

	var roster := CustomerRoster.new()
	roster.resident_profiles = [resident]

	var runtime_profile := roster.create_runtime_profile("resident_example")

	_expect(
		runtime_profile != null,
		"Roster must create a runtime resident profile."
	)
	_expect(
		runtime_profile != resident,
		"Runtime resident profiles must not reuse authored resources."
	)
	_expect(
		runtime_profile.customer_id == "resident_example",
		"Runtime resident profile must preserve its ID."
	)


func _test_tourist_roster_persistence_and_replacement() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var roster := TouristRoster.new()
	roster.ensure_population(1, rng)

	_expect(
		roster.profiles.size() == GameConstants.Customers.MAX_TOURISTS,
		"Tourist roster must maintain its configured population."
	)
	var retired_tourist_id := roster.profiles[0].customer_id
	var active_tourist_id := roster.profiles[1].customer_id
	roster.profiles[0].last_selected_day = 1
	roster.profiles[1].last_selected_day = 15

	var retired_count := roster.retire_inactive(16)
	_expect(retired_count >= 1, "Inactive tourists must be retired.")
	_expect(
		roster.profiles.any(func(profile: CustomerProfile) -> bool: return profile.customer_id == active_tourist_id),
		"Recently selected tourists must remain in the roster."
	)

	roster.ensure_population(16, rng)
	_expect(
		roster.profiles.size() == GameConstants.Customers.MAX_TOURISTS,
		"Retired tourists must be replaced."
	)
	_expect(
		not roster.profiles.any(func(profile: CustomerProfile) -> bool: return profile.customer_id == retired_tourist_id),
		"Retired tourists must not remain in the roster."
	)

	var restored_roster := TouristRoster.new()
	restored_roster.from_dict(roster.to_dict())
	_expect(
		restored_roster.profiles.size() == roster.profiles.size(),
		"Tourist roster must persist all active tourists."
	)


func _test_customer_visit_planner() -> void:
	var resident_template := CustomerProfile.new()
	resident_template.customer_id = "resident_ada"
	resident_template.origin = CustomerProfile.Origin.RESIDENT
	var resident_roster := CustomerRoster.new()
	resident_roster.resident_profiles = [resident_template]

	var rng := RandomNumberGenerator.new()
	rng.seed = 54321
	var tourist_roster := TouristRoster.new()
	tourist_roster.ensure_population(3, rng)
	var planner := CustomerVisitPlanner.new()

	var resident_request := planner.create_visit_request(
		resident_roster, tourist_roster, 3, 480, 0.0, rng
	)
	_expect(
		resident_request != null and resident_request.profile.is_resident(),
		"Planner must select a resident when tourist probability is zero."
	)
	_expect(
		resident_request.profile != resident_template,
		"Planner must create runtime resident profiles."
	)

	var tourist_request := planner.create_visit_request(
		resident_roster, tourist_roster, 3, 480, 1.0, rng
	)
	_expect(
		tourist_request != null and tourist_request.profile.is_tourist(),
		"Planner must select a tourist when tourist probability is one."
	)
	_expect(
		tourist_request.profile.visit_count == 1,
		"Selecting a tourist for a visit must update its visit history."
	)


func _test_customer_activity_sequence() -> void:
	var customer := Customer.new()
	var first_activity := CompletedCustomerActivity.new()
	var second_activity := CompletedCustomerActivity.new()
	var sequence := CustomerActivitySequence.new([first_activity, second_activity])

	sequence.enter(customer)
	sequence.tick(customer, 0.0)
	_expect(first_activity.exited_count == 1, "Sequence must exit each completed activity.")
	_expect(second_activity.entered_count == 1, "Sequence must enter the next activity.")

	sequence.tick(customer, 0.0)
	_expect(sequence.is_finished(customer), "Sequence must complete after its final activity.")
	_expect(second_activity.exited_count == 1, "Sequence must exit its final activity.")
	customer.free()


func _test_customer_schedule_director_arrivals() -> void:
	var resident := CustomerProfile.new()
	resident.customer_id = "resident_scheduler"
	var resident_roster := CustomerRoster.new()
	resident_roster.resident_profiles = [resident]

	var schedule := CustomerTrafficSchedule.new()
	schedule.default_arrival_weight = 1.0
	var director := CustomerScheduleDirector.new()
	director.traffic_schedule = schedule
	director.resident_roster = resident_roster
	director.arrivals_per_weight = 1.0
	director.tourist_probability = 0.0

	var previous_open_state := GameManager.state.bakery_is_open
	GameManager.state.bakery_is_open = true
	var request := director.evaluate_arrivals(1, 480)
	GameManager.state.bakery_is_open = previous_open_state
	_expect(
		request != null and request.profile.is_resident(),
		"Schedule director must produce a visit once enough arrival progress is accumulated."
	)


func _test_customer_destination_purpose() -> void:
	var destination := CustomerDestination.new()
	destination.purpose = CustomerDestination.Purpose.BROWSE
	_expect(
		destination.purpose == CustomerDestination.Purpose.BROWSE,
		"Customer destinations must retain their assigned purpose."
	)
	destination.free()


func _test_customer_visit_route_planner() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 98765
	var planner := CustomerVisitRoutePlanner.new()
	var plan := planner.create_plan(
		[&"browse_a", &"browse_b", &"browse_c"],
		[&"order_counter"],
		2,
		rng
	)

	_expect(plan != null, "Visit route planner must create a plan with an order point.")
	_expect(
		plan.order_destination_id == &"order_counter",
		"Visit route planner must end at an order destination."
	)
	_expect(
		plan.browse_destination_ids.size() <= 2,
		"Visit route planner must respect its browse-stop limit."
	)


func _test_customer_order_planner() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 222
	var planner := CustomerOrderPlanner.new()
	var intent := planner.create_intent(["donut", "pie"], rng)
	_expect(intent != null, "Order planner must create an intent from displayed items.")
	_expect(
		intent.item_id == "donut" or intent.item_id == "pie",
		"Order planner must select a displayed item."
	)
	_expect(
		planner.create_intent([], rng) == null,
		"Order planner must not create an intent without displayed items."
	)


func _test_customer_order_fulfillment() -> void:
	var displayed_item := InventoryItem.new()
	displayed_item.item_id = "donut"
	displayed_item.amount = 2
	displayed_item.freshness = 1.0
	var casing_slots := {"test_casing": [displayed_item]}
	var fulfillment_service := CustomerOrderFulfillmentService.new()
	var result := fulfillment_service.fulfill(
		CustomerOrderIntent.new("donut"),
		casing_slots
	)

	_expect(result.fulfilled, "Fulfillment must succeed for a displayed requested item.")
	_expect(result.earned_money > 0, "Fulfillment must calculate the sale value.")
	_expect(displayed_item.amount == 1, "Fulfillment must remove exactly one displayed item.")


func _test_bakery_open_state_persistence() -> void:
	var original := GameState.new()
	original.bakery_is_open = true
	original.bakery_opened_day = 3
	original.bakery_opened_minute = 720
	original.bakery_open_minutes_today = 90
	var restored := GameState.new()
	restored.from_dict(original.to_dict())

	_expect(restored.bakery_is_open, "Bakery open state must persist.")
	_expect(
		restored.bakery_opened_day == 3 and restored.bakery_open_minutes_today == 90,
		"Bakery opening timing must persist."
	)
