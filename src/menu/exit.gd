extends Button

func _ready():
	add_theme_constant_override("icon_max_width", 64)
	icon = load("res://addons/at-icons/node/doorway_exit.svg")
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().quit()
