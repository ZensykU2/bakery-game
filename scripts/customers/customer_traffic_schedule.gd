extends Resource
class_name CustomerTrafficSchedule

@export_range(0.0, 10.0, 0.01) var default_arrival_weight: float = 0.0
@export var windows: Array[CustomerTrafficWindow] = []

func get_arrival_weight(minute_of_day: int) -> float:
	var total_weight := default_arrival_weight
	
	for window in windows:
		if window != null and window.contains_minute(minute_of_day):
			total_weight += window.arrival_weight
	
	return total_weight
