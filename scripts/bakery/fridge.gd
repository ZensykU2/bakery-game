extends Interactable

func ui_accept(_player: CharacterBody2D) -> void:
	var container_ui = SceneManager.get_container_ui()
	if container_ui:
		container_ui.open(GameManager.state.fridge_slots)

func _close_ui() -> void:
	var container_ui = SceneManager.get_container_ui()
	if container_ui and container_ui.visible:
		if container_ui.active_container_array == GameManager.state.fridge_slots:
			container_ui.close()
