extends Node2D
class_name Starfield

@export var star_count_min: int = 8
@export var star_count_max: int = 14
@export var bounds_x := Vector2(0, 32)
@export var bounds_y := Vector2(0, 22)
@export var seed_by_position: bool = true

var stars: Array[ColorRect] = []

func _ready() -> void:
	TimeManager.ambient_color_changed.connect(_on_ambient_color_changed)
	_setup_stars()
	_on_ambient_color_changed(TimeManager.get_ambient_color())

func _setup_stars() -> void:
	if seed_by_position:
		seed(int(global_position.x * 1000 + global_position.y))
		
	var star_count = randi_range(star_count_min, star_count_max)
	for i in range(star_count):
		var star = ColorRect.new()
		star.size = Vector2(1, 1)
		
		var base_opacity = randf_range(0.3, 0.9)
		star.color = Color(1, 1, 1, 0.0) # Start invisible
		star.set_meta("base_alpha", base_opacity)
		
		star.position = Vector2(randf_range(bounds_x.x, bounds_x.y), randf_range(bounds_y.x, bounds_y.y))
		
		var mat = CanvasItemMaterial.new()
		mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		star.material = mat
		
		add_child(star)
		stars.append(star)
		
	if seed_by_position:
		randomize()

func _on_ambient_color_changed(_color: Color) -> void:
	var mins = TimeManager.time_in_minutes
	var stars_alpha = 0.0
	
	if mins >= GameConstants.TimeManage.SUNSET_END_MINUTES or mins < GameConstants.TimeManage.SUNRISE_START_MINUTES:
		stars_alpha = 1.0 # Full night
	elif mins >= GameConstants.TimeManage.SUNSET_START_MINUTES and mins < GameConstants.TimeManage.SUNSET_END_MINUTES:
		stars_alpha = (mins - GameConstants.TimeManage.SUNSET_START_MINUTES) / GameConstants.TimeManage.SUNSET_DURATION
	elif mins >= GameConstants.TimeManage.SUNRISE_START_MINUTES and mins < GameConstants.TimeManage.SUNRISE_END_MINUTES:
		stars_alpha = 1.0 - ((mins - GameConstants.TimeManage.SUNRISE_START_MINUTES) / GameConstants.TimeManage.SUNRISE_DURATION)
		
	for star in stars:
		var base = star.get_meta("base_alpha", 0.8)
		star.color.a = base * stars_alpha
