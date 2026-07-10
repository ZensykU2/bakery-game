extends Node2D

var is_indoor: bool = true

func _ready() -> void:
	print("Money: ", GameManager.get_money())
	print("Inventory: ", GameManager.get_inventory())
