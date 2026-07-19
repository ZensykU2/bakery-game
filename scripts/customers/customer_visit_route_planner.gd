extends RefCounted
class_name CustomerVisitRoutePlanner


func create_plan(
		available_browse_destination_ids: Array[StringName],
		order_destination_ids: Array[StringName],
		max_browse_stops: int,
		rng: RandomNumberGenerator
	) -> CustomerVisitPlan:
	if order_destination_ids.is_empty():
		return null

	var plan := CustomerVisitPlan.new()
	var remaining_browse_ids := available_browse_destination_ids.duplicate()
	var browse_stop_count := rng.randi_range(
		0,
		mini(max_browse_stops, remaining_browse_ids.size())
	)

	for stop_index in range(browse_stop_count):
		var selected_index := rng.randi_range(0, remaining_browse_ids.size() - 1)
		plan.browse_destination_ids.append(remaining_browse_ids[selected_index])
		remaining_browse_ids.remove_at(selected_index)

	plan.order_destination_id = order_destination_ids[
		rng.randi_range(0, order_destination_ids.size() - 1)
	]
	return plan
