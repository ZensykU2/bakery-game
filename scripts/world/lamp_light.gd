extends Node2D

@export var max_energy: float = 0.8

@export var turn_on_hour: int = 17
@export var turn_off_hour: int = 6

func _ready() -> void:
	TimeManager.time_changed.connect(_on_time_changed)
	_update_lamp_state(TimeManager.hour)

func _on_time_changed(hour: int, _minute: int) -> void:
	_update_lamp_state(hour)

func _update_lamp_state(current_hour: int) -> void:
	var should_be_on = false
	
	if turn_on_hour > turn_off_hour:
		should_be_on = current_hour >= turn_on_hour or current_hour < turn_off_hour
	else:
		should_be_on = current_hour >= turn_on_hour and current_hour < turn_off_hour
	
	if "energy" in self:
		self.energy = max_energy if should_be_on else 0.0
	elif "visible" in self:
		self.visible = should_be_on
