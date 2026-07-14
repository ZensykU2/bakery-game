extends Node2D

@export var interaction_component: InteractionComponent

func _ready() -> void:
	if interaction_component:
		interaction_component.interacted.connect(_on_interacted)

func _on_interacted(_player: CharacterBody2D) -> void:
	Hud.show_confirm_dialog(
		"Rest",
		"Would you like to go to sleep?",
		func(): SceneManager.sleep_to_next_day()
	)
