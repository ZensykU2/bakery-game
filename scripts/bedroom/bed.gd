extends Node2D


func ui_accept(_player: CharacterBody2D) -> void:
	
	var dialog := ConfirmationDialog.new()
	dialog.title = "Rest"
	dialog.dialog_text = "Would you like to go to sleep?"
	dialog.ok_button_text = "Yes"
	dialog.cancel_button_text = "No"
	
	dialog.confirmed.connect(func():
		SceneManager.sleep_to_next_day()
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()
