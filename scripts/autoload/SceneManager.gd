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

func transition_to(target_scene_path: String, spawn_point_name: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	_next_spawn_point_name = spawn_point_name
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.4)
	await tween.finished
	
	get_tree().change_scene_to_file(target_scene_path)
	
	while get_tree().current_scene == null:
		await get_tree().process_frame
	
	_position_player()
	
	var tween_in = create_tween()
	tween_in.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.4)
	await tween_in.finished
	
	is_transitioning = false

func _position_player() -> void:
	var root = get_tree().current_scene
	var player = root.find_child("Player", true, false)
	var spawn_points = root.find_child("SpawnPoints", true, false)
	
	if player and spawn_points:
		var spawn_marker = spawn_points.find_child(_next_spawn_point_name, true, false)
		
		if spawn_marker:
			player.global_position = spawn_marker.global_position
			print("Sppawned player at: ", _next_spawn_point_name)
		else:
			push_warning("Spawn point '%s' not found, player position unchanged." % _next_spawn_point_name)
	
	
	
	
	
