extends Control

func _ready():
	var screen_width = get_viewport_rect().size.x
	var nodes_to_animate = get_tree().get_nodes_in_group("content")
	
	# 1. Мгновенно сдвигаем вправо (ДО анимации)
	for node in nodes_to_animate:
		if node is Control:
			node.position.x += screen_width
			
	# ВАЖНО: Ждем один кадр, чтобы Godot применил новые позиции и отрисовал сцену
	await get_tree().process_frame
	
	# 2. Теперь запускаем анимацию
	var tween = create_tween()
	tween.set_parallel(true)
	
	for node in nodes_to_animate:
		if node is Control:
			var target_x = node.position.x - screen_width
			tween.tween_property(node, "position:x", target_x, 0.6)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
