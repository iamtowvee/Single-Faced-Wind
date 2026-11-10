extends CharacterBody3D

@export_group("Movement")
@export var speed: float = 5.0
@export var ground_acceleration: float = 15.0
@export var ground_friction: float = 20.0
@export var jump_velocity: float = 4.5

@export_group("Air Control")
@export var air_control_start: float = 0.1
@export var air_control_growth: float = 0.5

@export_group("Camera")
@export var mouse_sensitivity: float = 0.002
@export var land_dip_amount: float = 0.15
@export var land_dip_speed: float = 10.0

@onready var head: Node3D = $Head
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Ссылка на наше меню паузы
var pause_menu_instance: CanvasLayer
var _head_original_y: float = 0.0
var _air_time: float = 0.0
var _was_on_floor: bool = true
var _target_head_y: float = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_head_original_y = head.position.y
	_target_head_y = _head_original_y
	
	# Создаем меню паузы
	var pause_scene = load("res://pages/pause_menu.tscn")
	var pause_menu_instance = pause_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(pause_menu_instance)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if get_tree().paused: return # Не крутим камеру на паузе
		
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	# Если игра на паузе, физика не должна работать
	if get_tree().paused:
		return

	# --- 1. ГРАВИТАЦИЯ И ПРЫЖОК ---
	if not is_on_floor():
		velocity.y -= gravity * delta
		_air_time += delta
	else:
		_air_time = 0.0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		_was_on_floor = false

	# --- 2. ДВИЖЕНИЕ (WASD) ---
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = move_toward(velocity.x, direction.x * speed, ground_acceleration * delta)
			velocity.z = move_toward(velocity.z, direction.z * speed, ground_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, ground_friction * delta)
			velocity.z = move_toward(velocity.z, 0, ground_friction * delta)
	else:
		var air_mult = clampf(air_control_start + (_air_time * air_control_growth), 0.0, 1.0)
		var accel_in_air = ground_acceleration * air_mult
		
		if direction:
			velocity.x = move_toward(velocity.x, direction.x * speed, accel_in_air * delta)
			velocity.z = move_toward(velocity.z, direction.z * speed, accel_in_air * delta)

	move_and_slide()

	# --- 3. ЭФФЕКТ ПРИЗЕМЛЕНИЯ (Camera Dip) ---
	if is_on_floor() and not _was_on_floor:
		head.position.y = _head_original_y - land_dip_amount
		
		var tween = create_tween()
		tween.tween_property(head, "position:y", _head_original_y, 0.2)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
	_was_on_floor = is_on_floor()
