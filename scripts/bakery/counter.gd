extends Node2D

@export var interaction_component: InteractionComponent

func _ready() -> void:
	if interaction_component:
		interaction_component.interacted.connect(_on_interacted)
		interaction_component.player_exited.connect(_on_player_exited)

func _on_interacted(_player: CharacterBody2D) -> void:
	var container_ui = SceneManager.get_container_ui()
	if container_ui:
		if container_ui.visible and container_ui.active_container_array == GameManager.state.counter_slots:
			container_ui.close()
		else:
			container_ui.open(GameManager.state.counter_slots, "counter")

func _on_player_exited() -> void:
	var container_ui = SceneManager.get_container_ui()
	if container_ui and container_ui.visible:
		if container_ui.active_container_array == GameManager.state.counter_slots:
			container_ui.close()
