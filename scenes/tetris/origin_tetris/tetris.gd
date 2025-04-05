class_name Tetris
extends RigidBody2D

@export var push_force = 20.0

# tetris
@export var height: int = 2
@export var remove_0: PackedScene
@export var remove_1: PackedScene
@export var remove_2: PackedScene
@export var remove_3: PackedScene

@onready var tetris_markers: Node2D = $TetrisMarkers

var changable: bool = false # remove or rotate
var cooldown_to_change: float = 0.7 # after this time, we can rotate or remove line
var little_gap: float = 0.1 # after this time, set collision

func _ready():
	contact_monitor = true
	get_tree().create_timer(cooldown_to_change).timeout.connect(_set_changable_true)
	get_tree().create_timer(little_gap).timeout.connect(_set_collision)

func _physics_process(delta):
	for c in get_colliding_bodies():
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

func _set_collision():
	call_deferred("set_collision_layer_value", 2, true)

func _set_changable_true():
	changable = true

func remove_line(line: int) -> void:
	if not changable:
		return
	if height == 1:
		call_deferred("queue_free")
		return
	
	var head_global_pos = global_position
	var new_scene: PackedScene = null
	if (line == 0): # 移除最底部方块, 置顶
		head_global_pos = global_position
		new_scene = remove_0
	elif (line == 1): # 移除偏顶部方块, 置底
		head_global_pos = global_position + Vector2(0, Globals.GRID_SIZE)
		new_scene = remove_1
	elif (line == 2): # 移除偏顶部方块, 置底
		head_global_pos = global_position + Vector2(0, Globals.GRID_SIZE)
		new_scene = remove_2
	elif (line == 3): # 移除偏顶部方块, 置底
		head_global_pos = global_position + Vector2(0, Globals.GRID_SIZE)
		new_scene = remove_3
	
	assert(new_scene, "new scnene doesn't exist!")
	var rest_tetris: Tetris = new_scene.instantiate()
	
	get_parent().add_child(rest_tetris)
	rest_tetris.global_position = head_global_pos
	
	call_deferred("queue_free")

func get_tetris_global_pos() -> Array:
	var pos = []
	var children: Array[Node] = tetris_markers.get_children()
	for child in children:
		pos.append(child.global_position)
	return pos
