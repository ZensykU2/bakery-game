extends CanvasModulate

# If checked in the Inspector, this scene is treated as indoors
@export var is_indoor: bool = false

@export var indoor_warm_color: Color = Color(0.85, 0.8, 0.7)

# How strongly the indoor light colors override the outdoor darkness (0.0 to 1.0)
@export var indoor_blend_strength: float = 0.55


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TimeManager.ambient_color_changed.connect(_on_ambient_color_changed)
	_on_ambient_color_changed(TimeManager.get_ambient_color())

func _on_ambient_color_changed(color: Color) -> void:
	if is_indoor:
		self.color = color.lerp(indoor_warm_color, indoor_blend_strength)
	else:
		self.color = color
