extends Area2D
class_name PortalComponent

@export_file("*.tscn") var target_scene: String
@export var target_spawn_name: String = "DefaultSpawn"

func _ready() -> void:
	# Ensure trigger is not pickable by mouse
	input_pickable = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Check for key/lock gatekeepers in the parent hierarchy
		var parent = get_parent()
		if parent:
			for child in parent.get_children():
				if child.has_method("can_pass") and not child.can_pass(body):
					return
					
		if target_scene != "":
			Services.scene.transition_to(target_scene, target_spawn_name)
