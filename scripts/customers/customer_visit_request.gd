extends RefCounted
class_name CustomerVisitRequest

var profile: CustomerProfile
var day: int
var minute_of_day: int
var order_intent: CustomerOrderIntent


func _init(
		initial_profile: CustomerProfile = null,
		initial_day: int = 1,
		initial_minute_of_day: int = 0
	) -> void:
	profile = initial_profile
	day = initial_day
	minute_of_day = initial_minute_of_day
