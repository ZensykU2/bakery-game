extends RefCounted
class_name CustomerVisitPlan

var browse_destination_ids: Array[StringName] = []
var order_destination_id: StringName


func get_indoor_route() -> Array[StringName]:
	var route := browse_destination_ids.duplicate()
	route.append(order_destination_id)
	return route
