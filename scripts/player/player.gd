extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $Body
var current_interactables: Array[Node2D] = []

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
	if event.is_action_pressed("ui_accept") and not current_interactables.is_empty():
		var target = current_interactables[0]
		target.interact(self)


func _on_interaction_zone_area_entered(area: Area2D) -> void:
	if area is InteractionComponent:
		current_interactables.append(area)

func _on_interaction_zone_area_exited(area: Area2D) -> void:
	if area is InteractionComponent:
		current_interactables.erase(area)
