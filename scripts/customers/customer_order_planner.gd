extends RefCounted
class_name CustomerOrderPlanner


func create_intent(
		available_item_ids: Array[String],
		rng: RandomNumberGenerator
	) -> CustomerOrderIntent:
	if available_item_ids.is_empty():
		return null
	var item_id := available_item_ids[rng.randi_range(0, available_item_ids.size() - 1)]
	return CustomerOrderIntent.new(item_id)
