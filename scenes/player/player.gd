class_name Player
extends CharacterBody2D

signal player_updated(new_player: Player)

@onready var sprite_2d = $Sprite2D
@onready var walk_particle: GPUParticles2D = $Sprite2D/WalkParticle

@export var SPEED: float = 80.0
@export var MAX_Y_SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -150.0
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
	if event.is_action_released("rotate"):
		rotate_player()

func _ready():
	get_tree().create_timer(cooldown_to_change).timeout.connect(_set_changable_true)
	player_updated.emit(self)

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
	rest_player.global_position = head_global_pos
	rest_player.velocity = velocity
	get_parent().add_child(rest_player)
	player_updated.emit(rest_player)

	call_deferred("queue_free")

func rotate_player() -> void:
	if not changable:
		return
	is_rotated = !is_rotated
	RotateAudioPlayer.play_rotate_sfx()
	var center = center_marker.global_position
	var offset = global_position - center
	var target_angle = deg_to_rad(90) if is_rotated else 0	
	offset = offset.rotated(target_angle - rotation)
	global_position = center + offset
	rotation = target_angle

var wolf_jump_time: float = 0.15
var in_space_time: float = 0.0
func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		# 空中形变效果
		var jump_progress = abs(velocity.y) / abs(JUMP_VELOCITY)
		sprite_2d.scale.y = 1.0 + 0.2 * jump_progress
		sprite_2d.scale.x = 1.0 - 0.1 * jump_progress
		in_space_time += delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and (is_on_floor() or in_space_time < wolf_jump_time):
		velocity.y = JUMP_VELOCITY
		JumpAudioPlayer.play_jump_sfx()
		# 起跳时的挤压效果
		var tween = create_tween()
		tween.tween_property(sprite_2d, "scale", Vector2(1.2, 0.8), 0.1)
		tween.tween_property(sprite_2d, "scale", Vector2(0.8, 1.2), 0.1)
		tween.tween_property(sprite_2d, "scale", Vector2(1, 1), 0.1)
	
	var need_walk_sfx = false
	# 着地时恢复正常形状
	if is_on_floor():
		sprite_2d.scale = sprite_2d.scale.lerp(Vector2(1, 1), delta * 100)
		in_space_time = 0.0
	walk_particle.emitting = false
	# Get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("left", "right")
	if direction:
		sprite_2d.flip_h = (direction < 0 and not is_rotated)
		sprite_2d.flip_v = (direction < 0 and is_rotated)
		velocity.x = direction * SPEED
		last_direction = sign(velocity.x)  # 获取最后移动方向（1 或 -1）
		if is_on_floor():
			need_walk_sfx = true
			if not is_rotated:
				var new_direction = Vector3(1 if (direction < 0 and not is_rotated) else -1, 0, 0)
				walk_particle.process_material.set("direction", new_direction)
				walk_particle.emitting = true
		# 走路时的倾斜效果
		var target_rotation = direction * 0.11 if not is_rotated else abs(direction * 0.11)
		sprite_2d.rotation = lerp(sprite_2d.rotation, target_rotation, delta * 10)
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
				velocity.x /= 2
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		# 站立时恢复直立
		sprite_2d.rotation = lerp(sprite_2d.rotation, 0.0, delta * 10)

	if need_walk_sfx:
		WalkSfxPlayer.play_walk_sfx()
	else:
		WalkSfxPlayer.stop()
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
