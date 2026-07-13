extends Node2D
class_name Interactable


func _ready() -> void:
	var area = find_child("Area2D", true, false)
	if area:
		area.body_exited.connect(_on_body_exited)
	_on_ready()

func _on_ready() -> void:
	pass

func ui_accept(player: CharacterBody2D) -> void:
	pass

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		_close_ui()

func _close_ui() -> void:
	pass
