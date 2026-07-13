extends Node2D
class_name ShootingStarSpawner

@export var spawn_chance_per_second: float = 0.03
@export var bounds_x := Vector2(0, 32)
@export var bounds_y := Vector2(0, 22)

var shooting_star_active: bool = false

func _process(delta: float) -> void:
	var mins = TimeManager.time_in_minutes
	var is_night = (mins >= GameConstants.TimeManage.SUNSET_START_MINUTES or mins < GameConstants.TimeManage.SUNRISE_END_MINUTES)
	
	if is_night and not shooting_star_active and randf() < spawn_chance_per_second * delta:
		_spawn_shooting_star()

func _spawn_shooting_star() -> void:
	shooting_star_active = true
	
	var star = Line2D.new()
	var mat = CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	star.material = mat
	star.width = 1.0
	star.default_color = Color(1, 1, 1, 0.8)
	
	var start_pos = Vector2(randf_range(bounds_x.x, bounds_x.y / 2.0), randf_range(bounds_y.x, bounds_y.y / 2.0))
	var end_pos = start_pos + Vector2(randf_range(8, 16), randf_range(8, 16))
	
	star.add_point(Vector2.ZERO)
	star.add_point(Vector2.ZERO)
	star.position = start_pos
	
	add_child(star)
	
	var tween = create_tween()
	tween.tween_method(func(val):
		if is_instance_valid(star) and star.points.size() > 1:
			star.set_point_position(1, val)
	, Vector2.ZERO, end_pos - start_pos, 0.15)
	
	tween.tween_property(star, "position", end_pos, 0.25)
	tween.parallel().tween_method(func(val):
		if is_instance_valid(star) and star.points.size() > 0:
			star.set_point_position(0, val)
	, Vector2.ZERO, end_pos - start_pos, 0.25)
	
	await tween.finished
	if is_instance_valid(star):
		star.queue_free()
	shooting_star_active = false
