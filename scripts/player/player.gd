extends CharacterBody2D

const SPEED = 160.0

@onready var animated_sprite: AnimatedSprite2D = $Body
var current_interactables: Array[Node2D] = []

func _ready() -> void:
	animated_sprite.play("idle")
	
func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * SPEED
	
func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not current_interactables.is_empty():
		var target = current_interactables[0]
		if target.has_method("ui_accept"):
			target.ui_accept(self)


func _on_interaction_zone_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent.has_method("ui_accept"):
		current_interactables.append(parent)

func _on_interaction_zone_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent in current_interactables:
		current_interactables.erase(parent)
