extends Node

# Player Configurations
class Player:
	const SPEED: float = 160.0

# Inventory Configurations
class Inventory:
	const TRASHBIN_IDX: int = 999
	const CONTAINER_IDX: int = 100
	const MAX_HOTBAR_IDX: int = 9
	const MAX_DROPPED_ITEMS: int = 50
	const MAX_FRESHNESS: float = 1.0
	const FRESH_THRESHOLD: float = 0.6
	const STALE_THRESHOLD: float = 0.25
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
	
# Audio Configurations
class Audio:
	const POOL_SIZE: int = 8
