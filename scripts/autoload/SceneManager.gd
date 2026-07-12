extends Node

var fade_rect: ColorRect
var is_transitioning: bool = false
var _next_spawn_point_name: String = "DefaultSpawn"

var current_scene_path: String = ""

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
	current_scene_path = scene_path
	
	var level_container = get_tree().root.get_node_or_null("Main/CurrentLevel")
	if not level_container:
		return
		
	var level_scene = load(scene_path)
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)
	
	_position_player(level_instance)
	_update_global_lighting(level_instance)
	_spawn_dropped_items_for_scene(level_instance)

func transition_to(target_scene_path: String, spawn_point_name: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	_next_spawn_point_name = spawn_point_name
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), GameConstants.Scene.TRANSITION_DURATION)
	await tween.finished
	
	_serialize_active_dropped_items()
	current_scene_path = target_scene_path
	
	var level_container = get_tree().root.get_node_or_null("Main/CurrentLevel")
	if level_container:
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
		_spawn_dropped_items_for_scene(level_instance)
	
	var tween_in = create_tween()
	tween_in.tween_property(fade_rect, "color", Color(0, 0, 0, 0), GameConstants.Scene.TRANSITION_DURATION)
	await tween_in.finished
	
	is_transitioning = false

func sleep_to_next_day() -> void: 
	if is_transitioning:
		return
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), GameConstants.Scene.SLEEP_FADE_DURATION)
	await tween.finished
	
	_serialize_active_dropped_items()
	
	if TimeManager.hour >= GameConstants.TimeManage.WAKEUP_HOUR:
		GameManager.next_day()
		
	current_scene_path = "res://scenes/bedroom/Bedroom.tscn"
	
	var level_container = get_tree().root.get_node_or_null("Main/CurrentLevel")
	if level_container and level_container.get_child_count() > 0:
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
			_spawn_dropped_items_for_scene(level_instance)
		else:
			_next_spawn_point_name = "PassOut"
			_position_player(current_level)
	
	# 1 Minute IRL = 1 Second ingame
	TimeManager.time_in_minutes = GameConstants.TimeManage.DEFAULT_START_TIME
	TimeManager.force_process_time_update()
	GameManager.give_daily_allowance()
	
	await get_tree().create_timer(GameConstants.Scene.SLEEP_DELAY_TIMER).timeout
	
	var tween_in = create_tween()
	tween_in.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.8)
	await tween_in.finished
	
	is_transitioning = false

func _position_player(current_level: Node) -> void:
	var player = get_player()
	var spawn_points = current_level.find_child("SpawnPoints", true, false)
	if not spawn_points:
		spawn_points = current_level.find_child("SpawnPoint", true, false)
		
	if player and spawn_points:
		var spawn_marker = spawn_points.find_child(_next_spawn_point_name, true, false)
		if spawn_marker:
			player.global_position = spawn_marker.global_position

func _update_global_lighting(level_instance: Node) -> void:
	var global_light = get_tree().root.get_node_or_null("Main/CanvasModulate")
	if global_light and global_light.has_method("_on_ambient_color_changed"):
		var is_indoor = false
		if "is_indoor" in level_instance:
			is_indoor = level_instance.is_indoor
		global_light.is_indoor = is_indoor
		global_light._on_ambient_color_changed(TimeManager.get_ambient_color())

func _serialize_active_dropped_items() -> void:
	var keep_drops = []
	for drop in GameManager.state.dropped_items:
		if drop.scene_path != current_scene_path:
			keep_drops.append(drop)
	GameManager.state.dropped_items = keep_drops
	
	var active_level = get_active_level()
	if active_level:
		var active_drops = active_level.find_children("*", "DroppedItem", true, false)
		for drop_node in active_drops:
			if drop_node.is_queued_for_deletion():
				continue
				
			if GameManager.state.dropped_items.size() >= GameConstants.Inventory.MAX_DROPPED_ITEMS:
				break
			GameManager.state.dropped_items.append({
				"scene_path": current_scene_path,
				"item_id": drop_node.item.item_id,
				"amount": drop_node.item.amount,
				"freshness": drop_node.item.freshness,
				"position": drop_node.global_position
			})

func _spawn_dropped_items_for_scene(level_node: Node) -> void:
	var drops = GameManager.state.dropped_items
	for drop in drops:
		if drop.scene_path == current_scene_path:
			var drop_scene = load(GameConstants.Paths.DROPPED_ITEM_SCENE_PATH)
			var instance = drop_scene.instantiate()
			instance.global_position = drop.position
			instance.item = InventoryItem.from_dict(drop) 
			level_node.add_child(instance)

func get_player() -> CharacterBody2D:
	return get_tree().root.get_node_or_null("Main/Player")

func get_active_level() -> Node:
	var container = get_tree().root.get_node_or_null("Main/CurrentLevel")
	return container.get_child(0) if container and container.get_child_count() > 0 else null

func get_container_ui() -> CanvasLayer:
	return get_tree().root.get_node_or_null("Main/ContainerUI")

func get_hud() -> CanvasLayer:
	return get_node_or_null("/root/Hud")
