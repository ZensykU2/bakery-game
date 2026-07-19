extends Resource
class_name CustomerTrafficWindow

@export_range(0, 1439, 1) var start_minute: int = 0
@export_range(0, 1440, 1) var end_minute: int = 0
@export_range(0.0, 10.0, 0.01) var arrival_weight: float = 0.0

func contains_minute(minute_of_day: int) -> bool:
	if start_minute == end_minute:
		return false
	
	if start_minute < end_minute:
		return minute_of_day >= start_minute and minute_of_day < end_minute
	
	# Supports future overnight windows, for example 22:00 - 2:00
	return minute_of_day >= start_minute or minute_of_day < end_minute
