extends Node2D

@onready var result_label = $CanvasLayer/Panel/VBoxContainer/LabelResult

func _ready() -> void:
	print("Money: ", GameManager.money)
	print("Inventory: ", GameManager.inventory)

func _on_button_bake_bread_pressed() -> void:
	print("Button wurde gedrückt")
	if GameManager.craft("bread"):
		result_label.text = "Bread baked!"
	else:
		result_label.text = "Not enough ingredients."
