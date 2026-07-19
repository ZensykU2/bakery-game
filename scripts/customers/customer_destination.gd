extends Marker2D
class_name CustomerDestination

const DESTINATION_GROUP := &"customer_destinations"

@export var destination_id: StringName
@export var purpose: Purpose = Purpose.GENERIC

enum Purpose {
	GENERIC,
	ENTRY,
	BROWSE,
	ORDER,
	SEAT,
}

func _ready() -> void:
	add_to_group(DESTINATION_GROUP)
	
	if destination_id.is_empty():
		push_error("CustomerDestination '%s' has no destination ID." % name)
