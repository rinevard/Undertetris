class_name Player
extends CharacterBody2D


@export var SPEED: float = 100.0
@export var JUMP_VELOCITY: float = -200.0
@export var push_force: float = 10.0

# tetris
@export var height: int = 4
@export var remove_0: PackedScene
@export var remove_1: PackedScene
@export var remove_2: PackedScene
@export var remove_3: PackedScene

var is_rotated: bool = false
@onready var marker_2d = $Marker2D

var changable: bool = false # remove or rotate
var cooldown_to_change: float = 0.7 # after this time, we can rotate or remove line

func _input(event):
	if event.is_action_released("tmp"):
		remove_line(0)
		print(height)
	elif event.is_action_released("rotate"):
		rotate_player()

func _ready():
	await get_tree().create_timer(cooldown_to_change).timeout
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
	
	var center = marker_2d.global_position
	var offset = global_position - center
	var target_angle = deg_to_rad(90) if is_rotated else 0	
	offset = offset.rotated(target_angle - rotation)
	global_position = center + offset
	rotation = target_angle

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
				velocity.x /= 2
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
