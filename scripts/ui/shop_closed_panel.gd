extends CanvasLayer

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var details_label: Label = $PanelContainer/VBoxContainer/DetailsLabel
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

func _ready() -> void:
	close_button.pressed.connect(queue_free)

func setup(shop_name: String, open_hour: int, close_hour: int, closed_weekdays: Array[String]) -> void:
	title_label.text = "%s is Closed" % shop_name
	
	var open_days: Array[String] = []
	for day_name in GameConstants.TimeManage.WEEKDAYS:
		if not day_name in closed_weekdays:
			open_days.append(day_name.substr(0, 3))
		
		var open_days_str = ", ".join(open_days)
		
		details_label.text = "Open Days:\n%s\nBusiness Hours:\n%02d:00 - %02d:00" % [
			open_days_str,
			open_hour,
			close_hour,
		]
