extends HSlider

@onready var fps_label: Label = %FPS

func _ready():
	min_value = 15
	max_value = 360
	step = 5

	# Берём сохранённое значение из конфига (или дефолт 60)
	var saved_fps: int = int(Init.config.get("graphics", {}).get("fps", 60))
	value = saved_fps  # это вызовет value_changed, но сигнал ещё не подключён — ок

	value_changed.connect(_on_value_changed)
	_apply_fps(saved_fps)

func _on_value_changed(new_value: float) -> void:
	_apply_fps(int(new_value))
	# Сохраняем в конфиг
	Init.config["graphics"]["fps"] = int(new_value)
	Init.save_config(Init.config)

func _apply_fps(fps: int) -> void:
	Engine.max_fps = fps
	fps_label.text = "FPS: %d" % fps
