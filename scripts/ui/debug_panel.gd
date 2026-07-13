extends CanvasLayer

func _ready() -> void:
	$VBoxContainer/AddMoneyButton.pressed.connect(_on_add_money)
	$VBoxContainer/FreshnessOption.add_item("Fresh (100%)", 0)
	$VBoxContainer/FreshnessOption.add_item("Stale (30%)", 1)
	$VBoxContainer/FreshnessOption.add_item("Spoiled (5%)", 2)
	$VBoxContainer/FreshnessOption.selected = 0

	$VBoxContainer/AddFlourButton.pressed.connect(func(): InventoryManager.add_item("flour", 1, get_selected_freshness()))
	$VBoxContainer/AddSugarButton.pressed.connect(func(): InventoryManager.add_item("sugar", 1, get_selected_freshness()))
	$VBoxContainer/AddButterButton.pressed.connect(func(): InventoryManager.add_item("butter", 1, get_selected_freshness()))
	$VBoxContainer/AddEggsButton.pressed.connect(func(): InventoryManager.add_item("eggs", 1, get_selected_freshness()))
	$VBoxContainer/AddBerriesButton.pressed.connect(func(): InventoryManager.add_item("berries", 1, get_selected_freshness()))
	$VBoxContainer/AddChocolateButton.pressed.connect(func(): InventoryManager.add_item("chocolate", 1, get_selected_freshness()))
	$VBoxContainer/AddMilkButton.pressed.connect(func(): InventoryManager.add_item("milk", 1, get_selected_freshness()))
	$VBoxContainer/AddStrawberryButton.pressed.connect(func(): InventoryManager.add_item("strawberry", 1, get_selected_freshness()))
	$VBoxContainer/AddAppleButton.pressed.connect(func(): InventoryManager.add_item("apple", 1, get_selected_freshness()))

	$VBoxContainer/NextDayButton.pressed.connect(func(): GameManager.next_day())
	$VBoxContainer/SpeedUpTimeButton.pressed.connect(func(): TimeManager.increase_speed())
	$VBoxContainer/SlowDownTimeButton.pressed.connect(func(): TimeManager.decrease_speed())
	
	$VBoxContainer/ShowFreshnessCheckbox.toggled.connect(func(pressed: bool):
		InventoryManager.show_freshness_bars = pressed
		InventoryManager.inventory_changed.emit()
	)

func get_selected_freshness() -> float:
	match $VBoxContainer/FreshnessOption.selected:
		0: return 1.0
		1: return 0.3
		2: return 0.05
	return 1.0

func _process(_delta: float) -> void:
	$VBoxContainer/ShowFreshnessCheckbox.set_pressed_no_signal(InventoryManager.show_freshness_bars)
	$VBoxContainer/TimeLabel.text = "Time: %02d:%02d\nSpeed: %.1fx" % [
		TimeManager.hour,
		TimeManager.minute,
		TimeManager.time_speed
	]

func _on_add_money() -> void:
	GameManager.add_money(100)
