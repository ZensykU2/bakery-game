extends Node2D
class_name WindowLightController

@export var light_node: Light2D
@export var max_energy: float = 1.0
@export var min_energy_night: float = 0.4

func _ready() -> void:
	TimeManager.ambient_color_changed.connect(_on_ambient_color_changed)
	_on_ambient_color_changed(TimeManager.get_ambient_color())

func _on_ambient_color_changed(color: Color) -> void:
	if light_node:
		light_node.color = color
		var mins = TimeManager.time_in_minutes
		var is_daytime = (mins >= GameConstants.TimeManage.SUNRISE_END_MINUTES and mins < GameConstants.TimeManage.SUNSET_END_MINUTES)
		light_node.energy = max_energy if is_daytime else min_energy_night
