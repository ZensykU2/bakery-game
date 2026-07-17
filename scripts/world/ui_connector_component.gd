extends Node
class_name UIConnectorComponent

@export var interaction_component: InteractionComponent
@export var ui_panel: Control

func _ready() -> void:
	if ui_panel:
		ui_panel.visible = false
		ui_panel.add_to_group(UIOverlayManager.OVERLAY_GROUP)
		
	if interaction_component:
		interaction_component.interacted.connect(_on_interacted)
		interaction_component.player_exited.connect(_on_player_exited)

func _on_interacted(_player: CharacterBody2D) -> void:
	if ui_panel:
		var should_open := not ui_panel.visible
		if should_open:
			UIOverlayManager.close_all_overlays(ui_panel)
		ui_panel.visible = should_open

func _on_player_exited() -> void:
	if ui_panel:
		ui_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if ui_panel != null and ui_panel.visible and (
		event.is_action_pressed("toggle_inventory")
		or event.is_action_pressed("ui_cancel")
		or event.is_action_pressed("ui_accept")
	):
		ui_panel.visible = false
		get_viewport().set_input_as_handled()
