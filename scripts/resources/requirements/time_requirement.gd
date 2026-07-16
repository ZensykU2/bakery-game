extends Requirement
class_name TimeRequirement

@export var start_hour: int = 8
@export var end_hour: int = 20
@export var closed_days: Array[String] = []

func is_met() -> bool:
	# Check active business hour range
	if TimeManager.hour < start_hour or TimeManager.hour >= end_hour:
		return false
	
	# Check closed days (Monday-Sunday)
	var active_day_name = TimeManager.get_weekday_name()
	if active_day_name in closed_days:
		return false
		
	return true

func consume() -> void:
	# Time check is static, nothing to deduct from player inventory
	pass

func get_description() -> String:
	var day_str = ""
	if not closed_days.is_empty():
		day_str = " (Closed: " + ", ".join(closed_days) + ")"
	return "Hours: %02d:00 - %02d:00%s" % [start_hour, end_hour, day_str]
