extends Node2D
class_name WindowController

@export_group("Dependencies")
@export var sky_color_node: ColorRect

@export_group("Features")
# Checkboxes you can toggle for individual window instances in the Inspector
@export var show_celestial_bodies: bool = true
@export var show_stars: bool = true
@export var show_shooting_stars: bool = true

func _ready() -> void:
	if sky_color_node:
		sky_color_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	TimeManager.ambient_color_changed.connect(_on_ambient_color_changed)
	
	# Apply feature toggles dynamically on startup:
	if not show_celestial_bodies:
		var orbit = get_node_or_null("CelestialOrbit")
		if orbit: orbit.queue_free() # Safely remove it from this instance
		
	if not show_stars:
		var starfield = find_child("Starfield", true, false)
		if starfield: starfield.queue_free()
		
	if not show_shooting_stars:
		var spawner = find_child("ShootingStarSpawner", true, false)
		if spawner: spawner.queue_free()
		
	_on_ambient_color_changed(TimeManager.get_ambient_color())

func _on_ambient_color_changed(color: Color) -> void:
	if sky_color_node:
		sky_color_node.color = color
