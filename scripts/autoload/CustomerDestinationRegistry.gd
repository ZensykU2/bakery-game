extends Node

signal destinations_rebuilt

var _destinations: Dictionary[StringName, CustomerDestination] = {}

func _ready() -> void:
	call_deferred("_connect_scene_manager")

func _connect_scene_manager() -> void:
	if not SceneManager.scene_changed.is_connected(_on_scene_changed):
		SceneManager.scene_changed.connect(_on_scene_changed)
	_rebuild_destinations()

func _on_scene_changed(_scene_path: String) -> void:
	_rebuild_destinations()

func _rebuild_destinations() -> void:
	_destinations.clear()
	
	var active_level := SceneManager.get_active_level()
	if active_level == null:
		active_level = get_tree().current_scene

	if active_level == null:
		destinations_rebuilt.emit()
		return
	
	for node in get_tree().get_nodes_in_group(
		CustomerDestination.DESTINATION_GROUP
	):
		var destination := node as CustomerDestination
		
		if destination == null or not active_level.is_ancestor_of(destination):
			continue
		
		if _destinations.has(destination.destination_id):
			push_error(
				"Duplicate customer destination ID: %s" % destination.destination_id
			)
			continue
		
		_destinations[destination.destination_id] = destination
	
	destinations_rebuilt.emit()

func has_destination(destination_id: StringName) -> bool:
	return _destinations.has(destination_id)

func get_destination(destination_id: StringName) -> CustomerDestination:
	return _destinations.get(destination_id) as CustomerDestination


func get_destinations_by_purpose(
		purpose: CustomerDestination.Purpose
	) -> Array[CustomerDestination]:
	var matching_destinations: Array[CustomerDestination] = []
	for destination in _destinations.values():
		if destination.purpose == purpose:
			matching_destinations.append(destination)
	return matching_destinations
