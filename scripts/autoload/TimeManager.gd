extends Node

signal time_changed(hour: int, minute: int)
signal ambient_color_changed(color: Color)

var time_in_minutes = GameConstants.TimeManage.DEFAULT_START_TIME
var time_speed: float = 1.0

var day: int:
	get: return GameManager.state.day
var hour: int = 6
var minute: int = 0

var last_tracked_minute: int = -1

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
	if time_in_minutes >= GameConstants.TimeManage.MINUTES_IN_DAY:
		time_in_minutes -= GameConstants.TimeManage.MINUTES_IN_DAY
		GameManager.next_day()
	
	var new_hour = int(time_in_minutes / 60.0)
	var new_minute = int(time_in_minutes) % 60
	
	if new_hour != hour or new_minute != minute:
		hour = new_hour
		minute = new_minute
		time_changed.emit(hour, minute)
		
		var current_total_minutes = int(time_in_minutes) + (GameManager.get_day() * GameConstants.TimeManage.MINUTES_IN_DAY)
		
		if last_tracked_minute == -1:
			last_tracked_minute = current_total_minutes
		elif current_total_minutes > last_tracked_minute:
			var elapsed = current_total_minutes - last_tracked_minute
			_tick_inventory_decay(elapsed)
			last_tracked_minute = current_total_minutes
		
		if hour == GameConstants.TimeManage.PASSOUT_HOUR and minute == GameConstants.TimeManage.PASSOUT_MINUTE:
			pass_out()

	ambient_color_changed.emit(get_ambient_color())

func _decay_array(slots: Array, minutes: int, modifier: float) -> bool:
	var changed = false
	for item in slots:
		if item == null:
			continue

		var item_id = item.item_id if "item_id" in item else item.get("item_id", "")
		var rate = ItemDB.get_decay_rate(item_id)
		
		if rate > 0.0:
			var freshness = item.freshness if "freshness" in item else item.get("freshness", 1.0)
			var new_fresh = clamp(freshness - (rate * minutes * modifier), 0.0, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER)

			if "freshness" in item:
				item.freshness = new_fresh
			else:
				item["freshness"] = new_fresh
			changed = true
	return changed

func _tick_inventory_decay(minutes: int) -> void:
	var changed = false

	if _decay_array(GameManager.state.inventory_slots, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true

	if _decay_array(GameManager.state.fridge_slots, minutes, GameConstants.Inventory.FRIDGE_DECAY_MODIFIER): changed = true

	if _decay_array(GameManager.state.counter_slots, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true
	
	var active_level = SceneManager.get_active_level()
	if active_level:
		var active_drops = active_level.find_children("*", "DroppedItem", true, false)
		var drop_items: Array[InventoryItem] = []
		for d in active_drops:
			if d.item: drop_items.append(d.item)
		if _decay_array(drop_items, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true
	
	var cur_path = SceneManager.current_scene_path
	var offline_drops = []
	for drop in GameManager.state.dropped_items:
		if drop.scene_path != cur_path:
			offline_drops.append(drop)
			
	if _decay_array(offline_drops, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true

	for casing_id in GameManager.state.casing_slots.keys():
		var slots = GameManager.state.casing_slots[casing_id]
		if _decay_array(slots, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true

	if changed:
		InventoryManager.inventory_changed.emit()

func pass_out() -> void:
	print("It's 2:00 AM! Player passed out!")
	time_speed = 1.0
	SceneManager.sleep_to_next_day()
	GameManager.add_money(-GameConstants.TimeManage.PASSOUT_PENALTY)

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
	return GameConstants.TimeManage.WEEKDAYS[(day - 1) % 7]

func get_season_name() -> String:
	var season_index = int((day - 1) / GameConstants.TimeManage.DAYS_IN_SEASON) % GameConstants.TimeManage.SEASONS_IN_YEAR
	return GameConstants.TimeManage.SEASONS[season_index]

func get_day_of_season() -> int:
	return ((day - 1) % GameConstants.TimeManage.DAYS_IN_SEASON) + 1

func get_year() -> int:
	return int((day - 1) / GameConstants.TimeManage.DAYS_IN_YEAR) + 1

func increase_speed() -> void:
	time_speed = clamp(time_speed * 2.0, GameConstants.TimeManage.MIN_TIME_SPEED, GameConstants.TimeManage.MAX_TIME_SPEED)

func decrease_speed() -> void:
	time_speed = clamp(time_speed / 2.0, GameConstants.TimeManage.MIN_TIME_SPEED, GameConstants.TimeManage.MAX_TIME_SPEED)

func force_process_time_update() -> void:
	var current_total_minutes = int(time_in_minutes) + (GameManager.get_day() * GameConstants.TimeManage.MINUTES_IN_DAY)
	if last_tracked_minute != -1 and current_total_minutes > last_tracked_minute:
		var elapsed = current_total_minutes - last_tracked_minute
		_tick_inventory_decay(elapsed)
	last_tracked_minute = current_total_minutes
	
	hour = int(time_in_minutes / 60.0)
	minute = int(time_in_minutes) % 60
	time_changed.emit(hour, minute)
