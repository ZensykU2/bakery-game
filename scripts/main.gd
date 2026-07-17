extends Node2D

func _ready() -> void:
	# Show the gameplay HUD when entering the main game world
	Hud.visible = true
	
	# Bootstrap the default level when the Main scene is loaded
	var level_container = get_node_or_null("CurrentLevel")
	if level_container and level_container.get_child_count() == 0:
		SceneManager.load_initial_level()

func _unhandled_input(event: InputEvent) -> void:
	# Press ESCAPE to pause the game and open the Pause Menu
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE):
		if UIOverlayManager.close_active_overlay():
			get_viewport().set_input_as_handled()
			return
		_toggle_pause()

func _toggle_pause() -> void:
	var pause_menu = get_node_or_null("PauseMenu")
	if not pause_menu:
		var pause_scene = load("res://scenes/ui/PauseMenu.tscn")
		var inst = pause_scene.instantiate()
		inst.name = "PauseMenu"
		add_child(inst)
		get_tree().paused = true

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameManager.save_game_now()
		get_tree().quit()
