extends Node
class_name UIConnectorComponent

@export var interaction_component: InteractionComponent
@export var ui_panel: Control

func _ready() -> void:
	if ui_panel:
		ui_panel.visible = false
		
	if interaction_component:
		interaction_component.interacted.connect(_on_interacted)
		interaction_component.player_exited.connect(_on_player_exited)

func _on_interacted(_player: CharacterBody2D) -> void:
	if ui_panel:
		ui_panel.visible = not ui_panel.visible

func _on_player_exited() -> void:
	if ui_panel:
		ui_panel.visible = false
