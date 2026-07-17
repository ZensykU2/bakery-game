extends RefCounted
class_name InventorySlotAddress

enum Storage {
	INVENTORY,
	ACTIVE_CONTAINER,
	TRASH,
}

var storage: Storage
var index: int


static func inventory(slot_index: int) -> InventorySlotAddress:
	return _create(Storage.INVENTORY, slot_index)


static func active_container(slot_index: int) -> InventorySlotAddress:
	return _create(Storage.ACTIVE_CONTAINER, slot_index)


static func trash() -> InventorySlotAddress:
	return _create(Storage.TRASH, -1)


func matches(other: InventorySlotAddress) -> bool:
	return other != null and storage == other.storage and index == other.index


static func _create(
	new_storage: Storage,
	new_index: int
) -> InventorySlotAddress:
	var address := InventorySlotAddress.new()
	address.storage = new_storage
	address.index = new_index
	return address
