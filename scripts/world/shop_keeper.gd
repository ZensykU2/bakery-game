extends Node2D
class_name ShopKeeper

@export var shop_name: String = "Cozy Shop"
@export var shop_type: String = "general"
@export var item_catalog: Array[String] = []
@export var interaction_component: InteractionComponent

func _ready() -> void:
		
	if interaction_component:
		interaction_component.interacted.connect(_on_interacted)

func _on_interacted(_player: CharacterBody2D) -> void:
	var shop_ui := SceneManager.get_shop_ui()
	
	if shop_ui:
		shop_ui.open(shop_name, shop_type, item_catalog)
