extends CanvasLayer

func _ready() -> void:
	$VBoxContainer/AddMoneyButton.pressed.connect(_on_add_money)
	$VBoxContainer/AddFlourButton.pressed.connect(func(): InventoryManager.add_item("flour", 1))
	$VBoxContainer/AddSugarButton.pressed.connect(func(): InventoryManager.add_item("sugar", 1))
	$VBoxContainer/AddButterButton.pressed.connect(func(): InventoryManager.add_item("butter", 1))
	$VBoxContainer/AddEggsButton.pressed.connect(func(): InventoryManager.add_item("eggs", 1))
	$VBoxContainer/AddBerriesButton.pressed.connect(func(): InventoryManager.add_item("berries", 1))
	$VBoxContainer/AddChocolateButton.pressed.connect(func(): InventoryManager.add_item("chocolate", 1))
	$VBoxContainer/AddMilkButton.pressed.connect(func(): InventoryManager.add_item("milk", 1))
	$VBoxContainer/AddStrawberryButton.pressed.connect(func(): InventoryManager.add_item("strawberry", 1))
	$VBoxContainer/NextDayButton.pressed.connect(func(): GameManager.next_day())
	$VBoxContainer/SaveButton.pressed.connect(func(): GameManager.save_game())
	$VBoxContainer/LoadButton.pressed.connect(func(): GameManager.load_game())
	$VBoxContainer/SpeedUpTimeButton.pressed.connect(func(): TimeManager.increase_speed())
	$VBoxContainer/SlowDownTimeButton.pressed.connect(func(): TimeManager.decrease_speed())

func _process(_delta: float) -> void:
	$VBoxContainer/TimeLabel.text = "Time: %02d:%02d\nSpeed: %.1fx" % [
		TimeManager.hour,
		TimeManager.minute,
		TimeManager.time_speed
	]

func _on_add_money() -> void:
	GameManager.add_money(100)
