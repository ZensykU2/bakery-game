extends Node

const WEEKDAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
const SEASONS = ["Spring", "Summer", "Fall", "Winter"]

signal time_changed(hour: int, minute: int)
signal ambient_color_changed(color: Color)

var time_in_minutes: float = 6.0 * 60.0
var time_speed: float = 1.0

var day: int:
	get: return GameManager.state.day
var hour: int = 6
var minute: int = 0

var color_keyframes := {
	0.0: Color(0.12, 0.12, 0.32),
	4.0: Color(0.12, 0.12, 0.32),
	6.0: Color(0.75, 0.5, 0.5),
	8.0: Color(0.95, 0.9, 0.8),
	12.0: Color(1.0, 1.0, 1.0),
	17.0: Color(0.95, 0.85, 0.75),
	19.0: Color(0.8, 0.45, 0.35),
	21.0: Color(0.3, 0.25, 0.45),
	22.0: Color(0.12, 0.12, 0.32)
}

func _process(delta: float) -> void:
	time_in_minutes += delta * time_speed
	if time_in_minutes >= 1440.0:
		time_in_minutes -= 1440.0
		GameManager.next_day()
	
	var new_hour = int(time_in_minutes / 60.0)
	var new_minute = int(time_in_minutes) % 60
	
	if new_hour != hour or new_minute != minute:
		hour = new_hour
		minute = new_minute
		time_changed.emit(hour, minute)
		
		if hour == 2 and minute == 0:
			pass_out()

	ambient_color_changed.emit(get_ambient_color())

func pass_out() -> void:
	print("It's 2:00 AM! Player passed out!")
	time_speed = 1.0
	SceneManager.sleep_to_next_day()
	GameManager.add_money(-20)

func get_ambient_color() -> Color:
	var current_hour = time_in_minutes / 60.0
	var keys = color_keyframes.keys()
	keys.sort()
	
	var prev_key = keys[0]
	var next_key = keys[0]
	
	if current_hour >= keys[keys.size() -1]:
		prev_key = keys[keys.size() -1]
		next_key = keys[0]
		var t = (current_hour - prev_key) / (24 - prev_key)
		return color_keyframes[prev_key].lerp(color_keyframes[next_key], t)
	
	for i in range(keys.size()):
		if keys[i] <= current_hour:
			prev_key = keys[i]
		if keys[i] > current_hour:
			next_key = keys[i]
			break
	
	var t2 = (current_hour - prev_key) / (next_key - prev_key)
	return color_keyframes[prev_key].lerp(color_keyframes[next_key], t2)

func get_weekday_name() -> String:
	return WEEKDAYS[(day - 1) % 7]

func get_season_name() -> String:
	var season_index = int((day - 1) / 21) % 4
	return SEASONS[season_index]

func get_day_of_season() -> int:
	return ((day - 1) % 21) + 1

func get_year() -> int:
	return int((day - 1) / 84) + 1


func increase_speed() -> void:
	time_speed = clamp(time_speed * 2.0, 0.1, 240.0)

func decrease_speed() -> void:
	time_speed = clamp(time_speed / 2.0, 0.1, 240.0)
