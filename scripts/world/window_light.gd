extends Node2D

@export var max_energy: float = 1.0
@export var min_energy_night: float = 0.8

func _ready() -> void:
	TimeManager.ambient_color_changed.connect(_on_ambient_color_changed)
	_on_ambient_color_changed(TimeManager.get_ambient_color())

func _on_ambient_color_changed(color: Color) -> void:
	if "color" in self:
		self.color = color
	elif "modulate" in self:
		self.modulate = color
		
	if "energy" in self:
		var time_factor: float = TimeManager.time_in_minutes / 60.0

		if time_factor >= 6.0 and time_factor < 20.0:
			self.energy = max_energy
		else:
			self.energy = min_energy_night
