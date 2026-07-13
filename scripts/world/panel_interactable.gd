extends Interactable
class_name PanelInteractable

@export var ui_panel: Control

func _on_ready() -> void:
	if ui_panel:
		ui_panel.visible = false

func ui_accept(player: CharacterBody2D) -> void:
	if ui_panel:
		ui_panel.visible = not ui_panel.visible

func _close_ui() -> void:
	if ui_panel:
		ui_panel.visible = false
