extends Node2D

func _ready() -> void:
	print("Money: ", GameManager.get_money())
	print("Inventory: ", GameManager.get_inventory())
