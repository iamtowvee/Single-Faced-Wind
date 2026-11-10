extends Control

func _ready():
	var screen_width = get_viewport_rect().size.x
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Получаем всех участников группы
	var nodes_to_animate = get_tree().get_nodes_in_group("content")
	
	# Сначала сдвигаем их за экран (мгновенно)
	for node in nodes_to_animate:
		node.position.x += screen_width
		
	# Затем анимируем возврат на место (запоминаем исходную позицию)
	for node in nodes_to_animate:
		var target_x = node.position.x - screen_width
		tween.tween_property(node, "position:x", target_x, 0.6)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
