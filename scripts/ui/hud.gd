extends CanvasLayer

@onready var day_label: Label = $TopBarMargin/TopBar/DayLabel
@onready var money_label: Label = $TopBarMargin/TopBar/MoneyLabel

@onready var inventory_overlay: Control = $InventoryOverlay
@onready var item_list: VBoxContainer = $InventoryOverlay/CenterContainer/InventoryPanel/ItemList

func _ready() -> void:

	GameManager.day_changed.connect(_update_day)
	GameManager.money_changed.connect(_update_money)
	GameManager.inventory_changed.connect(_rebuild_inventory)

	_update_day(GameManager.get_day())
	_update_money(GameManager.get_money())
	_rebuild_inventory()

	inventory_overlay.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		inventory_overlay.visible = not inventory_overlay.visible

func _update_day(_new_day: int) -> void:
	day_label.text = "Yr %d, %s - Day %d (%s)" % [
		TimeManager.get_year(),
		TimeManager.get_season_name(),
		TimeManager.get_day_of_season(),
		TimeManager.get_weekday_name(),
	]

func _update_money(new_money: int) -> void:
	money_label.text = "Money: %d" % new_money

func _rebuild_inventory() -> void:
	for child in item_list.get_children():
		child.queue_free()

	var inventory = GameManager.get_inventory()
	for item_name in inventory.keys():
		var label := Label.new()
		label.text = "%s: %d" % [item_name.capitalize(), inventory[item_name]]
		item_list.add_child(label)
