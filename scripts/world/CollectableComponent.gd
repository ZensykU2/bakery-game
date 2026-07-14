extends Area2D
class_name CollectableComponent

@export var item_id: String = ""
@export var amount: int = 1
@export var freshness: float = 1.0

# Optional direct inventory item resource reference
var item_resource: InventoryItem = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var to_add: InventoryItem
		if item_resource:
			to_add = item_resource
		else:
			to_add = InventoryItem.new()
			to_add.item_id = item_id
			to_add.amount = amount
			to_add.freshness = freshness
			
		if Services.inventory.add_inventory_item_resource(to_add):
			Services.inventory.inventory_changed.emit()
			Services.game.save_game()
			
			# Free the physical item container (the parent node)
			var parent = get_parent()
			if parent:
				parent.queue_free()
			else:
				queue_free()
