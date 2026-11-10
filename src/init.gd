extends Node

var config
const CONFIG_PATH = "user://config.json"
const DEFAULT_CONFIG = {
	"audio": {
		"general_volume": 50,
		"sounds_volume": 100, 	# 50 * 100 / 100 = 50%
		"music": {
			"menu_music_volume": 50,  		# 50 * 50 / 100 = 25%
			"ingame_music_volume": 50 		# 50 * 50 / 100 = 25%
		}
	},
	"graphics": {
		"fps": 60,
		"vsync": false,
		"blur": false,
		"window_mode": "windowed",
		"quality_preset": "high",     # low | medium | high | ultra | custom
		"texture_quality": "high",
		"shadow_quality": "high"
	},
	"game": {
		"show_fps": false,
		"camera_shake": 100
	},
	"controls": {
		"mouse_sense": 50,
		"mouse_invert_y": false,
		"keybinds": {
			# ...
		}
	}
}

func save_config(data: Dictionary) -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_config() -> Dictionary:
	if not FileAccess.file_exists(CONFIG_PATH):
		return {}
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data if data is Dictionary else {}
	return {}

func _ready():
	var pointer_image = load("res://assets/pointer.png")
	var grabbing_image = load("res://assets/grabbing.png")
	Input.set_custom_mouse_cursor(pointer_image, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(grabbing_image, Input.CURSOR_DRAG)
	config = load_config()
	if config == {}:
		config = DEFAULT_CONFIG.duplicate(true)
