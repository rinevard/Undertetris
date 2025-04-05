class_name Player
extends CharacterBody2D
@onready var sprite_2d = $Sprite2D

@export var SPEED: float = 80.0
@export var MAX_Y_SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -200.0
@export var push_force: float = 15.0

var last_direction = 1 # 移动对齐

# tetris
@export var height: int = 4
@export var remove_0: PackedScene
@export var remove_1: PackedScene
@export var remove_2: PackedScene
@export var remove_3: PackedScene

var is_rotated: bool = false
@onready var center_marker: Marker2D = $CenterMarker
@onready var tetris_markers: Node2D = $TetrisMarkers

var changable: bool = false # remove or rotate
var cooldown_to_change: float = 0.7 # after this time, we can rotate or remove line

func _input(event):
	if event.is_action_released("tmp"):
		remove_line(0)
		print(height)
	elif event.is_action_released("rotate"):
		rotate_player()

func _ready():
	get_tree().create_timer(cooldown_to_change).timeout.connect(_set_changable_true)

func _set_changable_true():
	changable = true

func remove_line(line: int) -> void:
	if not changable:
		return
	if height == 1 or is_rotated:
		call_deferred("queue_free")
		return
	
	var head_global_pos = global_position
	if (line == 0): # 移除最底部方块, 置顶
		head_global_pos = global_position
	elif (line == height - 1): # 移除最顶部方块, 置底
		head_global_pos = global_position + Vector2(0, Globals.GRID_SIZE)
	else: # 移除其他则置顶
		head_global_pos = global_position
	
	var rest_player: Player = remove_0.instantiate()
	get_parent().add_child(rest_player)
	rest_player.global_position = head_global_pos
	rest_player.velocity = velocity

	call_deferred("queue_free")

func rotate_player() -> void:
	if not changable:
		return
	is_rotated = !is_rotated
	
	var center = center_marker.global_position
	var offset = global_position - center
	var target_angle = deg_to_rad(90) if is_rotated else 0	
	offset = offset.rotated(target_angle - rotation)
	global_position = center + offset
	rotation = target_angle

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("left", "right")
	if direction:
		sprite_2d.flip_h = (direction < 0)
		velocity.x = direction * SPEED
		last_direction = sign(velocity.x)  # 获取最后移动方向（1 或 -1）
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
				velocity.x /= 2
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	velocity.y = MAX_Y_SPEED if velocity.y > MAX_Y_SPEED else velocity.y
	if velocity == Vector2.ZERO:
		Globals.player_still_time += delta
	else:
		Globals.player_still_time = 0
	move_and_slide()

func get_tetris_global_pos() -> Array:
	var pos = []
	var children: Array[Node] = tetris_markers.get_children()
	for child in children:
		pos.append(child.global_position)
	return pos
