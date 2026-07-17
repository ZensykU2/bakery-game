extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var oven_id: String = ""
@export var interaction_component: InteractionComponent
@export var ui_panel: Control
@export var completion_sfx: SfxPlayerComponent

var is_showing_complete: bool = false

enum OvenState { IDLE, BAKING, COMPLETE }

func _ready() -> void:
	if oven_id.strip_edges() == "":
		oven_id = name.to_lower()
		
	if interaction_component:
		interaction_component.interacted.connect(_on_interacted)
		interaction_component.player_exited.connect(_on_player_exited)
	
	BakingManager.baking_updated.connect(update_animation)
	update_animation()

func _on_interacted(_player: CharacterBody2D) -> void:
	if ui_panel:
		var should_open := not ui_panel.visible
		if should_open:
			UIOverlayManager.close_all_overlays(ui_panel)
			if ui_panel.has_method("open_for_oven"):
				ui_panel.call("open_for_oven", oven_id)
			else:
				ui_panel.visible = true
		else:
			ui_panel.visible = false

func _on_player_exited() -> void:
	if ui_panel:
		var cur_id = ui_panel.get("current_oven_id")
		if cur_id == oven_id:
			ui_panel.visible = false

func update_animation() -> void:
	var bake = BakingManager.get_bake_for_oven(oven_id)
	
	var current_state: OvenState = OvenState.IDLE
	if bake != null:
		if bake.is_finished:
			current_state = OvenState.COMPLETE
		else:
			current_state = OvenState.BAKING
	
	match current_state:
		OvenState.IDLE:
			is_showing_complete = false
			for child in get_children():
				if child.has_signal("harvest_requested"):
					child.queue_free()
					
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		OvenState.BAKING:
			if animated_sprite.animation != "running":
				animated_sprite.play("running")
		OvenState.COMPLETE:
			if animated_sprite.animation != "complete":
				animated_sprite.play("complete")
			if not is_showing_complete:
				is_showing_complete = true
				_spawn_floaty_icon(bake.recipe_id)
				if completion_sfx:
					completion_sfx.play_sound()

func _spawn_floaty_icon(recipe_id: String) -> void:
	var recipe := ItemDB.get_recipe_resource(recipe_id)
	var output_item := ItemDB.get_item_resource(recipe.output_item_id) if recipe else null
	var icon_texture := output_item.icon_fresh if output_item else null
	
	if icon_texture:
		var floaty_scene = load(GameConstants.Paths.FLOATY_ICON_SCENE_PATH)
		var floaty = floaty_scene.instantiate()
		floaty.position = Vector2(0, -24)
		add_child(floaty)
		floaty.start(recipe_id, icon_texture)
		
		floaty.harvest_requested.connect(func():
			var player = SceneManager.get_player()
			if player:
				var distance = floaty.global_position.distance_to(player.global_position)
				print("Floaty click: distance to player = ", distance, " (Max allowed: ", GameConstants.World.HARVEST_DISTANCE, ")")
				if distance > GameConstants.World.HARVEST_DISTANCE:
					print("Too far away to harvest!")
					return

			if BakingManager.try_harvest(oven_id):
				print("Harvested item into slots: ", recipe_id)
				floaty.play_harvest_animation()
		)
