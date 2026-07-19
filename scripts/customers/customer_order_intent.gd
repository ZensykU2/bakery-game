extends RefCounted
class_name CustomerOrderIntent

var item_id: String


func _init(initial_item_id: String = "") -> void:
	item_id = initial_item_id
