extends Area2D
class_name InteractionComponent

signal interacted(player: CharacterBody2D)
signal player_entered
signal player_exited

@export var interaction_priority: int = 0

var is_player_in_range: bool = false

func _ready() -> void:
	# Ensure trigger setup is not pickable by mouse
	input_pickable = false
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact(player: CharacterBody2D) -> void:
	interacted.emit(player)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		is_player_in_range = true
		player_entered.emit()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		is_player_in_range = false
		player_exited.emit()
