extends Control

# Пути к сценам
const NEW_SCENE = "res://pages/new.tscn"
const LOAD_SCENE = "res://pages/sessions.tscn"
const DELETE_SCENE = "res://pages/sessions.tscn"

func _ready():
	# Подключаем сигналы кнопок
	$New.pressed.connect(_on_new_pressed)
	$Load.pressed.connect(_on_load_pressed)
	
	# Настраиваем курсор для этих трех кнопок
	_setup_cursor($New)
	_setup_cursor($Load)
	_setup_cursor($Delete)

# --- НАСТРОЙКА КУРСОРА ---
func _setup_cursor(btn: Button):
	# В Godot при наведении на Control курсор меняется на указатель автоматически,
	# НО только если этот Control не disabled. 
	# Поэтому мы просто задаем базовую форму курсора для кнопки.
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# А чтобы при выходе из выключенной кнопки курсор сбрасывался, 
	# используем сигнал mouse_exited. (При наведении на disabled кнопку 
	# Godot сам не меняет курсор, так что дополнительный код не нужен).
	btn.mouse_exited.connect(func(): Input.set_default_cursor_shape(Input.CURSOR_ARROW))

# --- ДЕЙСТВИЯ КНОПОК ---
func _on_new_pressed():
	_start_transition_animation(NEW_SCENE)

func _on_load_pressed():
	_start_transition_animation(LOAD_SCENE)

# --- АНИМАЦИЯ ПЕРЕХОДА ---
func _start_transition_animation(target_scene_path: String):
	# 1. Отключаем кнопки, чтобы не нажали дважды
	for child in get_children():
		if child is Button:
			child.disabled = true
			# Принудительно возвращаем стрелку, если мышь была над кнопкой
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE 
			
	var tween = create_tween()
	tween.set_parallel(true)
	
	var delay = 0.0
	for child in get_children():
		if child is Button:
			# Этап 1: Сдвиг вправо
			tween.tween_property(child, "position:x", child.position.x + 50, 0.5)\
				.set_delay(delay)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				
			# Этап 2: Улетают влево за экран
			tween.tween_property(child, "position:x", -1000, 0.3)\
				.set_delay(delay + 0.5)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				
			delay += 0.15
			
	# 3. Ждем и меняем сцену
	await get_tree().create_timer(delay + 0.8).timeout
	get_tree().change_scene_to_file(target_scene_path)
