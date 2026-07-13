extends PanelContainer

@onready var master_slider: HSlider = $VBoxContainer/GridContainer/MasterSlider
@onready var music_slider: HSlider = $VBoxContainer/GridContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/GridContainer/SfxSlider
@onready var window_mode_option: OptionButton = $VBoxContainer/GridContainer/WindowModeOption
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready() -> void:
	window_mode_option.add_item("Windowed", 0)
	window_mode_option.add_item("Fullscreen", 1)
	
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	window_mode_option.selected = SettingsManager.window_mode
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	window_mode_option.item_selected.connect(_on_window_mode_selected)
	close_button.pressed.connect(_on_close_pressed)

func _on_master_changed(value: float) -> void:
	SettingsManager.master_volume = value
	SettingsManager.apply_settings()

func _on_music_changed(value: float) -> void:
	SettingsManager.music_volume = value
	SettingsManager.apply_settings()
	
func _on_sfx_changed(value: float) -> void:
	SettingsManager.sfx_volume = value
	SettingsManager.apply_settings()
	
func _on_window_mode_selected(index: int) -> void:
	SettingsManager.window_mode = index
	SettingsManager.apply_settings()
	
func _on_close_pressed() -> void:
	SettingsManager.save_settings()
	queue_free()
