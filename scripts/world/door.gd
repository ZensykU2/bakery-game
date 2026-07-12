extends Node2D

@export_file("*.tscn") var target_scene: String
@export var target_spawn_name: String = "DefaultSpawn"

@export_category("Shops")
@export var shop_name: String = "Shop"
@export var is_scheduled_shop: bool = false
@export var open_hour: int = 9
@export var close_hour: int = 17
@export var closed_weekdays: Array[String] = ["Saturday", "Sunday"]

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if is_scheduled_shop:
			if not is_shop_open():
				var closed_panel_scene = load(GameConstants.Paths.SHOP_CLOSED_PANEL_PATH)
				var popup = closed_panel_scene.instantiate()
				get_tree().current_scene.add_child(popup)
				popup.setup(shop_name, open_hour, close_hour, closed_weekdays)
				return

		if target_scene != "":
			SceneManager.transition_to(target_scene, target_spawn_name)

func is_shop_open() -> bool:
	var current_day = TimeManager.get_weekday_name()
	if current_day in closed_weekdays:
		return false
	
	var current_hour = TimeManager.hour
	if current_hour < open_hour or current_hour >=  close_hour:
		return false
	
	return true
