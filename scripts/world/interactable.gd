extends Node2D
class_name Interactable

@export var ui_panel: Control

func _ready() -> void:
	if ui_panel:
		ui_panel.visible = false
		
	var area = find_child("Area2D", true, false)
	if area:
		area.body_exited.connect(_on_body_exited)
	
	_on_ready()

func _on_ready() -> void:
	pass

func ui_accept(_player: CharacterBody2D) -> void:
	if ui_panel:
		ui_panel.visible = not ui_panel.visible
		if ui_panel.visible:
			_on_ui_opened()

func _on_ui_opened() -> void:
	pass

func _close_ui() -> void:
	if ui_panel:
		ui_panel.visible = false

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		_close_ui()
