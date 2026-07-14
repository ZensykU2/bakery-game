extends Gatekeeper
class_name ShopGatekeeper

@export var shop_name: String = "Shop"
@export var open_hour: int = 9
@export var close_hour: int = 17
@export var closed_weekdays: Array[String] = ["Saturday", "Sunday"]

func can_pass(_player: Node2D) -> bool:
	if _is_shop_open():
		return true
		
	# Show the popup
	var closed_panel_scene = load(GameConstants.Paths.SHOP_CLOSED_PANEL_PATH)
	var popup = closed_panel_scene.instantiate()
	Engine.get_main_loop().current_scene.add_child(popup)
	popup.setup(shop_name, open_hour, close_hour, closed_weekdays)
	return false

func _is_shop_open() -> bool:
	var current_day = TimeManager.get_weekday_name()
	if current_day in closed_weekdays:
		return false
	var current_hour = TimeManager.hour
	return current_hour >= open_hour and current_hour < close_hour
