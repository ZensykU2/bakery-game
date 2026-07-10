extends Node2D

@export_file("*.tscn") var target_scene: String

@export var target_spawn_name: String = "DefaultSpawn"

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if target_scene != "":
			SceneManager.transition_to(target_scene, target_spawn_name)
