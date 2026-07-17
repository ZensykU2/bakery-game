extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $Body
var current_interactables: Array[InteractionComponent] = []

func _ready() -> void:
	animated_sprite.play("idle")
	var zone = find_child("InteractionZone", true, false)
	if zone:
		zone.input_pickable = false
	
func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * GameConstants.Player.SPEED
	
func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var target := _get_best_interactable()
		if target:
			target.interact(self)
			get_viewport().set_input_as_handled()


func _get_best_interactable() -> InteractionComponent:
	var best: InteractionComponent = null

	for candidate in current_interactables:
		if not is_instance_valid(candidate) or not candidate.is_player_in_range:
			continue

		if best == null or _is_better_interaction_candidate(candidate, best):
			best = candidate

	return best


func _is_better_interaction_candidate(
	candidate: InteractionComponent,
	current_best: InteractionComponent
) -> bool:
	if candidate.interaction_priority != current_best.interaction_priority:
		return candidate.interaction_priority > current_best.interaction_priority

	return global_position.distance_squared_to(candidate.global_position) \
		< global_position.distance_squared_to(current_best.global_position)


func _on_interaction_zone_area_entered(area: Area2D) -> void:
	if area is InteractionComponent:
		var interaction := area as InteractionComponent
		if not current_interactables.has(interaction):
			current_interactables.append(interaction)

func _on_interaction_zone_area_exited(area: Area2D) -> void:
	if area is InteractionComponent:
		current_interactables.erase(area as InteractionComponent)
