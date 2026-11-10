extends Button

const CHAPTER_SCENE = "res://pages/Chapter_I.res"

func _ready():
	pressed.connect(_on_done_pressed)

func _on_done_pressed():
	disabled = true # Чтобы не нажали дважды
	
	# 1. Генерируем уникальный ID для сессии (на основе текущего времени)
	var save_id = str(Time.get_unix_time_from_system())
	var save_dir = "user://saves/" + save_id
	
	# 2. Создаем папку для сохранения
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_recursive_absolute(save_dir)
		
	# 3. Собираем мета-данные для меню сохранений
	# (Здесь ты можешь брать значения из полей ввода твоей сцены настроек мира)
	var meta_data = {
		"id": save_id,
		"session_name": "Session " + save_id, # Или возьми из LineEdit
		"chapter": "Chapter I",
		"date": Time.get_datetime_string_from_system(),
		"playtime": 0
	}
	
	# Сохраняем meta.json
	var file = FileAccess.open(save_dir + "/meta.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(meta_data, "\t"))
	file.close()
	
	# 4. Сохраняем в Глобальную переменную (Autoload), 
	# чтобы сцена игры (Chapter_I) знала, куда сохранять прогресс
	Glob.current_save_id = save_id 
	
	# 5. Переходим в игру (без анимации, просто меняем сцену)
	get_tree().change_scene_to_file(CHAPTER_SCENE)
