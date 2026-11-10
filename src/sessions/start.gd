extends Control

# Ссылки на узлы (подгони пути под свою сцену)
@onready var grid = $ScrollContainer/VBoxContainer/GridContainer
@onready var btn_new = $Control/New # Кнопка New
@onready var btn_load = $Control/Load # Кнопка Load
@onready var btn_delete = $Control/Delete # Кнопка Delete (или как они у тебя называются)

var selected_save_id: String = "" # Храним ID выбранного сохранения
var save_buttons: Array[Button] = [] # Массив кнопок для управления выделением

# Функция для сброса курсора на стандартную стрелку
func _set_cursor_arrow():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

# Функция для установки курсора-указателя (руки)
func _set_cursor_hand():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _ready():
	# 1. Подключаем кнопки управления
	btn_new.pressed.connect(_on_new_pressed)
	btn_load.pressed.connect(_on_load_pressed)
	btn_delete.pressed.connect(_on_delete_pressed)
	
	# 2. Отключаем Load и Delete, пока ничего не выбрано
	btn_load.disabled = true
	btn_delete.disabled = true
	
	# 3. Запускаем анимацию появления и загружаем сохранения
	_play_intro_animation()
	load_saves()

# --- АНИМАЦИЯ ---
func _play_intro_animation():
	var screen_width = get_viewport_rect().size.x
	var tween = create_tween()
	tween.set_parallel(true)
	var nodes_to_animate = get_tree().get_nodes_in_group("content")
	
	for node in nodes_to_animate:
		node.position.x += screen_width
	for node in nodes_to_animate:
		var target_x = node.position.x - screen_width
		tween.tween_property(node, "position:x", target_x, 0.6)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

# --- ЧТЕНИЕ СОХРАНЕНИЙ ---
func load_saves():
	# Очищаем старые карточки и массив
	for child in grid.get_children():
		child.queue_free()
	save_buttons.clear()
	
	# Сбрасываем выбор
	selected_save_id = ""
	btn_load.disabled = true
	btn_delete.disabled = true
	
	var saves_found = false
	var saves_dir = "user://saves/"
	
	if DirAccess.dir_exists_absolute(saves_dir):
		var dir = DirAccess.open(saves_dir)
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		
		while folder_name != "":
			if dir.current_is_dir() and folder_name != "." and folder_name != "..":
				var meta_path = saves_dir + folder_name + "/meta.json"
				if FileAccess.file_exists(meta_path):
					var file = FileAccess.open(meta_path, FileAccess.READ)
					var meta_data = JSON.parse_string(file.get_as_text())
					_create_save_card(folder_name, meta_data)
					saves_found = true
			folder_name = dir.get_next()
			
	if not saves_found:
		var empty_label = Label.new()
		empty_label.text = "Sessions not found :("
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(empty_label)

func _create_save_card(save_id: String, data: Dictionary):
	var card = Button.new()
	card.custom_minimum_size = Vector2(0, 100) 
	card.toggle_mode = true
	card.button_group = ButtonGroup.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Контейнер для текста
	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	# ВАЖНО: выравниваем контейнер по левому краю и центрируем по вертикали
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER 
	
	# Отступы слева, чтобы текст не прилипал к краю карточки
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20) # Отступ слева
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(margin)
	
	# Вложенный VBox для самих текстов (внутри отступов)
	var text_vbox = VBoxContainer.new()
	text_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(text_vbox)
	
	# Имя сессии
	var title = Label.new()
	title.text = data.get("session_name", "Unknown Session")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT # Прижимаем влево
	title.add_theme_font_size_override("font_size", 36)   # Делаем шрифт больше
	text_vbox.add_child(title)
	
	# Глава и дата
	var info = Label.new()
	info.text = data.get("chapter", "Chapter I") + " | " + data.get("date", "")
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT # Прижимаем влево
	info.add_theme_font_size_override("font_size", 24)    # Шрифт поменьше, но читаемый
	info.modulate = Color(0.8, 0.8, 0.8)                  # Немного тусклый цвет для второстепенной инфы
	text_vbox.add_child(info)
	
	card.add_child(vbox)
	grid.add_child(card)
	save_buttons.append(card)
	
	card.pressed.connect(func(): 
		selected_save_id = save_id
		btn_load.disabled = false
		btn_delete.disabled = false
	)

# --- ДЕЙСТВИЯ С КНОПКАМИ ---

func _on_new_pressed():
	pass
	# Твой переход на сцену настроек мира
	# get_tree().change_scene_to_file("res://pages/new.tscn")

func _on_load_pressed():
	if selected_save_id == "": return
	print("Загрузка сессии: ", selected_save_id)
	
	# Сохраняем ID в глобальную переменную (Autoload), чтобы Chapter_I знал, что грузить
	Glob.current_save_id = selected_save_id
	
	# Переходим в игру
	get_tree().change_scene_to_file("res://pages/Chapter_I.res")

func _on_delete_pressed():
	if selected_save_id == "": return
	
	# Удаляем папку со всем содержимым
	var save_dir = "user://saves/" + selected_save_id
	_delete_folder_recursive(save_dir)
	
	print("Сессия удалена: ", selected_save_id)
	# Перезагружаем список
	load_saves()

# Вспомогательная функция для удаления папки со всем содержимым
func _delete_folder_recursive(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(file_name) # Удаляем файлы внутри
			file_name = dir.get_next()
		dir.list_dir_end()
		DirAccess.remove_absolute(path) # Удаляем саму папку
