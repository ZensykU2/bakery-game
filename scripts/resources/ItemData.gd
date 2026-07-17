extends Resource
class_name ItemData

@export var item_id: String = ""
@export var buy_price: int = 0
@export var sell_price: int = 0
@export_range(0.0, 1.0, 0.00001, "or_greater") var decay_rate: float = 0.0
@export var stackable: bool = true

@export_group("Icons")
@export var icon_fresh: Texture2D
@export var icon_stale: Texture2D
@export var icon_spoiled: Texture2D
