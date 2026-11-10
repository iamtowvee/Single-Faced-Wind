extends Button

const MENU_SCENE = "res://pages/sessions.tscn"

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	disabled = true # Отключаем кнопку
	
	var tween = create_tween()
	tween.set_parallel(true) # Анимируем все элементы группы одновременно
	
	# Получаем всех участников группы "content"
	var group_nodes = get_tree().get_nodes_in_group("content")
	
	# Сдвигаем их влево за экран
	var screen_width = get_viewport_rect().size.x
	for node in group_nodes:
		if node is Control: # Проверка на всякий случай
			tween.tween_property(node, "position:x", node.position.x - screen_width, 0.5)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
				
	# Ждем 0.5 сек и меняем сцену
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(MENU_SCENE)
