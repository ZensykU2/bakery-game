extends Node

var fade_rect: ColorRect
var is_transitioning: bool = false
var _next_spawn_point_name: String = "DefaultSpawn"

func _ready() -> void:
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(fade_rect)
	
	await get_tree().process_frame
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		var level_container = main.get_node_or_null("CurrentLevel")
		if level_container and level_container.get_child_count() == 0:
			load_level_direct("res://scenes/bakery/Bakery.tscn", "CoreSpawn")

func load_level_direct(scene_path: String, spawn_point_name: String) -> void:
	_next_spawn_point_name = spawn_point_name
	var main = get_tree().root.get_node("Main")
	var level_container = main.get_node("CurrentLevel")
	
	var level_scene = load(scene_path)
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)
	
	_position_player(level_instance)
	_update_global_lighting(level_instance)

func transition_to(target_scene_path: String, spawn_point_name: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	_next_spawn_point_name = spawn_point_name
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.4)
	await tween.finished
	
	var main = get_tree().root.get_node("Main")
	var level_container = main.get_node("CurrentLevel")
	
	for child in level_container.get_children():
		level_container.remove_child(child)
		child.queue_free()
	
	var level_scene = load(target_scene_path)
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)
	
	while get_tree().current_scene == null:
		await get_tree().process_frame
	
	_position_player(level_instance)
	
	_update_global_lighting(level_instance)
	
	var tween_in = create_tween()
	tween_in.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.4)
	await tween_in.finished
	
	is_transitioning = false

func _position_player(current_level: Node) -> void:
	var main = get_tree().root.get_node("Main")
	var player = main.get_node("Player")
	
	var spawn_points = current_level.find_child("SpawnPoints", true, false)
	if not spawn_points:
		spawn_points = current_level.find_child("SpawnPoint", true, false)
	
	if player and spawn_points:
		var spawn_marker = spawn_points.find_child(_next_spawn_point_name, true, false)
		
		if spawn_marker:
			player.global_position = spawn_marker.global_position

func _update_global_lighting(level_instance: Node) -> void:
	var main = get_tree().root.get_node("Main")
	var global_light = main.get_node_or_null("CanvasModulate")
	
	if global_light and global_light.has_method("_on_ambient_color_changed"):
		var is_indoor = false
		if "is_indoor" in level_instance:
			is_indoor = level_instance.is_indoor
		
		global_light.is_indoor = is_indoor
		global_light._on_ambient_color_changed(TimeManager.get_ambient_color())

func sleep_to_next_day() -> void: 
	if is_transitioning:
		return
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.8)
	await tween.finished
	
	if TimeManager.hour >= 6:
		GameManager.next_day()
	
	var main = get_tree().root.get_node("Main")
	var level_container = main.get_node("CurrentLevel")
	var current_level = level_container.get_child(0)
	
	if current_level.name != "Bedroom":
		for child in level_container.get_children():
			level_container.remove_child(child)
			child.queue_free()
	
		var level_scene = load("res://scenes/bedroom/Bedroom.tscn")
		var level_instance = level_scene.instantiate()
		level_container.add_child(level_instance)
	
		while get_tree().current_scene == null:
			await get_tree().process_frame
		_next_spawn_point_name = "PassOut"
		_position_player(level_instance)
		_update_global_lighting(level_instance)
	else:
		_next_spawn_point_name = "PassOut"
		_position_player(current_level)
	
	TimeManager.time_in_minutes = 6.0 * 60
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_in = create_tween()
	tween_in.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.8)
	await tween_in.finished
	
	is_transitioning = false
