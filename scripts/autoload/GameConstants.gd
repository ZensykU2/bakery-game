extends Node

# Player Configurations
class Player:
	const SPEED: float = 160.0

# Inventory Configurations
class Inventory:
	const MAX_HOTBAR_IDX: int = 9
	const SOFT_MAX_DROPPED_ITEMS: int = 50
	const HARD_MAX_DROPPED_ITEMS: int = 200
	const DESPAWN_TIMER_MINUTES: int = 60 # Time in in game-minutes before items start despawning
	const DESPAWN_INTERVAL_MINUTES: int = 1 # Tick speed of despawning after timer expires
	const MAX_FRESHNESS: float = 1.0
	const FRESH_THRESHOLD: float = 0.5
	const STALE_THRESHOLD: float = 0.15
	const FRESH_PRICE_MULTIPLIER: float = 1.0
	const STALE_PRICE_MULTIPLIER: float = 0.6
	const SPOILED_PRICE_MULTIPLIER: float = 0.2
	const FRIDGE_DECAY_MODIFIER: float = 0.25
	const DEFAULT_DECAY_MODIFIER: float = 1.0
	const STACKING_FRESHNESS_TOLERANCE: float = 0.05
	const DROP_OFFSET := Vector2(0, 16)
	
	const DEFAULT_START_MONEY: int = 100
	const DEFAULT_INVENTORY_SLOTS: int = 18
	const DEFAULT_FRIDGE_SLOTS: int = 9
	const DEFAULT_COUNTER_SLOTS: int = 3
	
	const STARTING_ITEMS := {
		"flour": 5,
		"eggs": 4,
		"butter": 2,
		"sugar": 3,
		"berries": 3,
	}

# Time & Season Configurations
class TimeManage:
	const MINUTES_IN_DAY: float = 1440.0
	const DAYS_IN_SEASON: int = 21
	const SEASONS_IN_YEAR: int = 4
	const DAYS_IN_YEAR: int = 84
	const PASSOUT_HOUR: int = 2
	const PASSOUT_MINUTE: int = 0
	const PASSOUT_PENALTY: int = 20
	const DEFAULT_START_DAY: int = 1
	const DEFAULT_START_TIME: float = 360 # 6:00 AM in minutes (6.0 * 60)
	const WAKEUP_HOUR: float = 6.0
	const SLEEP_HOUR: float = 20.0
	const MIN_TIME_SPEED: float = 0.1
	const MAX_TIME_SPEED: float = 240.0
	const WEEKDAYS := ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	const SEASONS := ["Spring", "Summer", "Fall", "Winter"]
	
	# Window & Orbit Time Constants (in minutes)
	const SUNRISE_START_MINUTES: float = 300.0 # 5:00 AM
	const SUNRISE_END_MINUTES: float = 360.0   # 6:00 AM
	const SUNRISE_DURATION: float = 60.0
	
	const SUNSET_START_MINUTES: float = 1080.0 # 6:00 PM
	const SUNSET_END_MINUTES: float = 1200.0   # 8:00 PM
	const SUNSET_DURATION: float = 120.0
	
	const DAY_ORBIT_DURATION: float = 840.0    # 14 hours (6 AM to 8 PM)
	const NIGHT_ORBIT_DURATION: float = 600.0  # 10 hours (8 PM to 6 AM)
	
	const HOUR_MORNING_START: int = 6
	const HOUR_DAY_START: int = 12
	const HOUR_EVENING_START: int = 17
	const HOUR_NIGHT_START: int = 20

class World:
	const HARVEST_DISTANCE: float = 512.0
	const DROPPED_ITEM_PICKUP_DELAY: float = 1.2
	const DROPPED_ITEM_SCALE: float = 0.15

class Scene:
	const TRANSITION_DURATION: float = 0.4
	const SLEEP_FADE_DURATION: float = 0.8
	const SLEEP_DELAY_TIMER: float = 0.5

class UI:
	const CURSOR_GRABBER_SIZE := Vector2(40, 40)
	const HUD_BOTTOM_MARGIN: float = 12.0
	
class Paths:
	const SAVE_PATH: String = "user://savegame.json"

	const FLOATY_ICON_SCENE_PATH: String = "res://scenes/world/FloatyIcon.tscn"
	const SLOT_UI_SCENE_PATH: String = "res://scenes/ui/InventorySlotUI.tscn"
	const SHOP_CLOSED_PANEL_PATH: String = "res://scenes/ui/ShopClosedPanel.tscn"
	const DROPPED_ITEM_SCENE_PATH: String = "res://scenes/world/DroppedItem.tscn"
	const SHOP_ITEMS_DIR: String = "res://resources/shop_items/"
	const SHOP_UI_SCENE_PATH: String = "res://scenes/ui/ShopUI.tscn"
	
# Audio Configurations
class Audio:
	const POOL_SIZE: int = 8
	const BUS_SFX: String = "SFX"
	const BUS_MUSIC: String = "Music"
	const BUS_MASTER: String = "Master"
	
	const TIME_ANY: String = "Any"
	const TIME_MORNING: String = "Morning"
	const TIME_DAY: String = "Day"
	const TIME_EVENING: String = "Evening"
	const TIME_NIGHT: String = "Night"
	
	const FADE_VOL: float = 80.0
	const FADE_DUR: float = 2.0
	
	# Music weighting scores
	const TR_SC_SCORE: int = 10
	const TR_DY_SCORE: int = 2
	const TR_SE_SCORE: int = 2
	const TR_WD_SCORE: int = 2
	const TR_WE_SCORE: int = 2

class Persistence:
	const AUTOSAVE_INTERVAL_SECONDS: float = 60.0
