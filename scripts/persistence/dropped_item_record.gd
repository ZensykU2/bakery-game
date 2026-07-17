extends RefCounted
class_name DroppedItemRecord

var scene_path: String = ""
var item: InventoryItem
var position: Vector2 = Vector2.ZERO


static func from_world_item(
	world_scene_path: String,
	world_item: InventoryItem,
	world_position: Vector2
) -> DroppedItemRecord:
	var record := DroppedItemRecord.new()
	record.scene_path = world_scene_path
	record.item = world_item.clone()
	record.position = world_position
	return record


static func from_dict(data: Dictionary) -> DroppedItemRecord:
	var record := DroppedItemRecord.new()
	record.scene_path = String(data.get("scene_path", ""))
	record.item = InventoryItem.from_dict(data)
	record.position = Vector2(
		float(data.get("pos_x", 0.0)),
		float(data.get("pos_y", 0.0))
	)
	return record


func to_dict() -> Dictionary:
	return {
		"scene_path": scene_path,
		"item_id": item.item_id if item else "",
		"amount": item.amount if item else 0,
		"freshness": item.freshness if item else 1.0,
		"pos_x": position.x,
		"pos_y": position.y
	}
