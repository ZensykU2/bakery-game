extends Node2D

func ui_accept(_player: CharacterBody2D) -> void:
	Hud.show_confirm_dialog(
		"Rest",
		"Would you like to go to sleep?",
		func(): SceneManager.sleep_to_next_day()
	)
