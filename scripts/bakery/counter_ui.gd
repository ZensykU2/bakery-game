extends Control

@onready var stock_list: VBoxContainer = $Panel/StockList

func _ready() -> void:
	GameManager.inventory_changed.connect(update_stock_list)
	update_stock_list()

func update_stock_list() -> void:
	for child in stock_list.get_children():
		child.queue_free()
	
	var stock = GameManager.get_bakery_stock()
	for item_name in stock.keys():
		var amount = stock[item_name]
		if amount > 0:
			var price = RecipeDB.get_recipe(item_name).get("sell_price", 0)
			
			var h_box := HBoxContainer.new()
			h_box.add_theme_constant_override("separation", 15)
			
			var info_label := Label.new()
			info_label.text = "%s:  %d in stock ($%d)" % [item_name.capitalize(), amount, price]
			h_box.add_child(info_label)
			
			var sell_button := Button.new()
			sell_button.text = "Sell 1"
			sell_button.pressed.connect(_on_sell_pressed.bind(item_name))
			h_box.add_child(sell_button)
			
			stock_list.add_child(h_box)
		
	if stock_list.get_child_count() == 0:
		var empty_label := Label.new()
		empty_label.text = "Stock is empty. Bake something first!"
		stock_list.add_child(empty_label)

func _on_sell_pressed(recipe_name: String) -> void:
	GameManager.sell_item(recipe_name)
