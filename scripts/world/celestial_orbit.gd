extends Node2D
class_name CelestialOrbit

@export var sun_node: Node2D
@export var moon_node: Node2D

@export var orbit_radius_x: float = 24.0
@export var orbit_radius_y: float = 14.0
@export var center_offset := Vector2(0, 14)

func _ready() -> void:
	TimeManager.ambient_color_changed.connect(_on_ambient_color_changed)
	_on_ambient_color_changed(TimeManager.get_ambient_color())

func _on_ambient_color_changed(_color: Color) -> void:
	var mins = TimeManager.time_in_minutes
	var is_daytime = (mins >= GameConstants.TimeManage.SUNRISE_END_MINUTES and mins < GameConstants.TimeManage.SUNSET_END_MINUTES)

	if is_daytime:
		var day_t = (mins - GameConstants.TimeManage.SUNRISE_END_MINUTES) / GameConstants.TimeManage.DAY_ORBIT_DURATION
		var angle = PI + (day_t * PI)
		if sun_node:
			sun_node.visible = true
			sun_node.position = center_offset + Vector2(cos(angle) * orbit_radius_x, sin(angle) * orbit_radius_y)
	else:
		if sun_node:
			sun_node.visible = false
			
	if not is_daytime:
		var night_t = 0.0
		if mins >= GameConstants.TimeManage.SUNSET_END_MINUTES:
			night_t = (mins - GameConstants.TimeManage.SUNSET_END_MINUTES) / GameConstants.TimeManage.NIGHT_ORBIT_DURATION
		else:
			night_t = (mins + (GameConstants.TimeManage.MINUTES_IN_DAY - GameConstants.TimeManage.SUNSET_END_MINUTES)) / GameConstants.TimeManage.NIGHT_ORBIT_DURATION
			
		var angle = PI + (night_t * PI)
		if moon_node:
			moon_node.visible = true
			moon_node.position = center_offset + Vector2(cos(angle) * orbit_radius_x, sin(angle) * orbit_radius_y)
	else:
		if moon_node:
			moon_node.visible = false
