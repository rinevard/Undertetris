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
var removable: bool = false

func _input(event):
	if event.is_action_released("tmp"):
		remove_line(0)
		print(height)

func _ready():
	await get_tree().create_timer(1.0).timeout
	removable = true	

func remove_line(line: int) -> void:
	if not removable:
		return
	if height == 1:
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
	print("old pos: ", global_position)
	print("new pos: ", rest_player.global_position)
	rest_player.velocity = velocity

	call_deferred("queue_free")

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
