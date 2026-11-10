extends Control

# Пути к сценам
const SETTINGS_SCENE = "res://pages/settings.tscn"
const SESSIONS_SCENE = "res://pages/sessions.tscn"

func _ready():
	# Подключаем сигналы (или сделай это через редактор во вкладке "Узлы")
	$Play.pressed.connect(_on_play_pressed)
	$Settings.pressed.connect(_on_settings_pressed)
	$Exit.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	_start_transition_animation(SESSIONS_SCENE)

func _on_settings_pressed():
	_start_transition_animation(SETTINGS_SCENE)

func _on_exit_pressed():
	get_tree().quit()

# --- ОБЩАЯ ФУНКЦИЯ АНИМАЦИИ ---
func _start_transition_animation(target_scene_path: String):
	# 1. Отключаем все кнопки, чтобы игрок не нажал их повторно во время анимации
	for child in get_children():
		if child is Button:
			child.disabled = true
			
	var tween = create_tween()
	tween.set_parallel(true) # Все кнопки анимируются одновременно, но с задержкой
	
	var delay = 0.0
	# 2. Проходимся по всем дочерним кнопкам
	for child in get_children():
		if child is Button:
			# ЭТАП 1: Немного съезжают вправо (на 50 пикселей)
			tween.tween_property(child, "position:x", child.position.x + 50, 0.5)\
				.set_delay(delay)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				
			# ЭТАП 2: Улетают влево за экран
			tween.tween_property(child, "position:x", -1000, 0.3)\
				.set_delay(delay + 0.5)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				
			# Увеличиваем задержку для следующей кнопки (эффект лесенки)
			delay += 0.15 # 0.15 сек разницы. Можешь поставить 1.0, если хочешь медленно
			
	# 3. Ждем, пока пройдет вся анимация (последняя кнопка + её анимация), 
	# и меняем сцену.
	await get_tree().create_timer(delay + 0.8).timeout
	get_tree().change_scene_to_file(target_scene_path)
