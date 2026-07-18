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

	if failures.is_empty():
		print("TESTS PASSED: 8 deterministic test groups completed.")
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
