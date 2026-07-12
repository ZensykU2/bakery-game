extends Area2D
class_name DroppedItem

@onready var sprite: Sprite2D = $Sprite2D
var item: InventoryItem

func _ready() -> void:
	
	monitoring = false
	monitorable = false
	
	sprite.scale = Vector2(0.15, 0.15)
	
	get_tree().create_timer(1.2).timeout.connect(func(): 
		monitoring = true
		monitorable = true
	)
	body_entered.connect(_on_body_entered)
	if item:
		sprite.texture = ItemDB.get_item_icon(item.item_id, item.freshness)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and item:
		if InventoryManager.add_inventory_item_resource(item):
			InventoryManager.inventory_changed.emit()
			GameManager.save_game()
			queue_free()
