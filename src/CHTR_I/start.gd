extends Node3D

func _ready():
	var global_bg = get_node_or_null("/root/Global")
	if global_bg:
		global_bg.hide()
		global_bg.process_mode = Node.PROCESS_MODE_DISABLED

func _exit_tree():
	# Этот код выполнится ровно в тот момент, когда сцена Chapter_I закрывается
	var global_bg = get_node_or_null("/root/Global")
	if global_bg:
		global_bg.show()
		global_bg.process_mode = Node.PROCESS_MODE_INHERIT 
