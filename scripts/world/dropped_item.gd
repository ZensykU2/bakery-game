extends Area2D
class_name DroppedItem

@onready var sprite: Sprite2D = $Sprite2D
var item: InventoryItem

func _ready() -> void:
	
	monitoring = false
	monitorable = false
	
	sprite.scale = Vector2(GameConstants.World.DROPPED_ITEM_SCALE, GameConstants.World.DROPPED_ITEM_SCALE)
	
	get_tree().create_timer(GameConstants.World.DROPPED_ITEM_PICKUP_DELAY).timeout.connect(func(): 
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
