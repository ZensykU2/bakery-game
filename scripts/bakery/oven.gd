extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var oven_ui: Control
@export var oven_id: String = ""

const FLOATY_ICON_SCENE = preload("res://scenes/world/FloatyIcon.tscn")
var is_showing_complete: bool = false

enum OvenState { IDLE, BAKING, COMPLETE }

func _ready() -> void:
	if oven_id.strip_edges() == "":
		oven_id = name.to_lower()

	if oven_ui:
		oven_ui.visible = false

	BakingManager.baking_updated.connect(update_animation)
	update_animation()

func _process(_delta: float) -> void:
	var bake = BakingManager.get_bake_for_oven(oven_id)
	if bake and not bake.is_finished:
		update_animation()
	
func ui_accept(_player: CharacterBody2D) -> void:
	if oven_ui:
		oven_ui.current_oven_id = oven_id
		oven_ui.visible = not oven_ui.visible
		if oven_ui.visible:
			oven_ui.update_buttons()

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
				_spawn_floaty_icon(bake.recipe_name)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player" and oven_ui:
		if oven_ui.current_oven_id == oven_id:
			oven_ui.visible = false

func _spawn_floaty_icon(recipe_name: String) -> void:
	var recipe = RecipeDB.get_recipe(recipe_name)
	var icon_texture = recipe.get("icon", null)
	
	if icon_texture:
		var floaty = FLOATY_ICON_SCENE.instantiate()
		floaty.position = Vector2(0, -24)
		add_child(floaty)
		floaty.start(icon_texture)
