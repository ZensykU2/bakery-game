extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var oven_ui: Control

func _ready() -> void:
	animated_sprite.play("idle")
	if oven_ui:
		oven_ui.visible = false
	
func ui_accept(_player: CharacterBody2D) -> void:
	if oven_ui:
		oven_ui.visible = not oven_ui.visible
		if oven_ui.visible:
			oven_ui.update_buttons()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player" and oven_ui:
			oven_ui.visible = false
