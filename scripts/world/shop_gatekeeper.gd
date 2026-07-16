extends Gatekeeper
class_name ShopGatekeeper

@export var shop_name: String = "Shop"
@export var time_requirement: TimeRequirement

func can_pass(_player: Node2D) -> bool:
	if _is_shop_open():
		return true
		
	# Show the popup
	var closed_panel_scene = load(GameConstants.Paths.SHOP_CLOSED_PANEL_PATH)
	var popup = closed_panel_scene.instantiate()
	Engine.get_main_loop().current_scene.add_child(popup)
	
	var start = time_requirement.start_hour if time_requirement else 9
	var end = time_requirement.end_hour if time_requirement else 17
	var closed = time_requirement.closed_days if time_requirement else []
	popup.setup(shop_name, start, end, closed)
	return false

func _is_shop_open() -> bool:
	if time_requirement:
		return time_requirement.is_met()
	return true
