extends Node2D

@export var counter_ui: Control

func _ready() -> void:
	if counter_ui:
		counter_ui.visible = false

func ui_accept(_player: CharacterBody2D) -> void:
	if counter_ui:
		counter_ui.visible = not counter_ui.visible
		if counter_ui.visible:
			counter_ui.update_stock_list()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player" and counter_ui:
		counter_ui.visible = false
