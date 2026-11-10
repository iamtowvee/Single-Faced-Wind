extends CanvasLayer

# Подключаем кнопки
@onready var btn_save = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonSave
@onready var btn_settings = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonSettings
@onready var btn_exit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonExit
@onready var btn_resume = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonResume

func _ready():
	hide()
	
	btn_save.pressed.connect(_on_save_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	btn_resume.pressed.connect(_on_resume_pressed)
	
	for btn in [btn_save, btn_settings, btn_exit, btn_resume]:
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
	# ВАЖНО: Этот узел должен продолжать работать, даже когда игра на паузе!
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	# Ловим ESC только здесь
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume_pressed()
		else:
			_open_menu()
		get_viewport().set_input_as_handled() # Съедаем событие

func _open_menu():
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Glob.current_save_id == "":
		btn_save.disabled = true
	else:
		btn_save.disabled = false

func _on_resume_pressed():
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_save_pressed():
	print("Сохранение и выход...")
	
	# 1. Снимаем паузу (чтобы игра не осталась замороженной)
	get_tree().paused = false
	
	# 2. ВАЖНО: Показываем мышку для главного меню!
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# 3. Переходим в меню
	get_tree().change_scene_to_file("res://pages/menu.tscn")

func _on_settings_pressed():
	print("Открываем настройки...")
	# Тут будет открытие настроек

func _on_exit_pressed():
	print("Выход в меню...")
	
	# 1. Снимаем паузу
	get_tree().paused = false
	
	# 2. ВАЖНО: Показываем мышку для главного меню!
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# 3. Переходим в меню
	get_tree().change_scene_to_file("res://pages/menu.tscn")
