extends Node2D

const WHITE_BOX = preload("res://scenes/juicy/white_box.tscn")

# 方块数量
@export var BOX_COUNT = 100

# 方块运动参数
const MIN_VELOCITY = -17  # 最小速度
const MAX_VELOCITY = 17   # 最大速度

# 方块缩放参数
const MIN_SCALE = 0.5     # 最小尺寸
const MAX_SCALE = 1.0     # 最大尺寸
const MIN_SCALE_SPEED = 0.1  # 最小缩放速度
const MAX_SCALE_SPEED = 0.3  # 最大缩放速度

# 透明度参数
const MIN_ALPHA = 0.2     # 最小透明度
const MAX_ALPHA = 0.7     # 最大透明度

var boxes = []
@export var scene_size = Vector2(486, 280 * 4)  # 场景尺寸
var boundary = Rect2(Vector2(-20, -20), scene_size + Vector2(40, 40))  # 碰撞边界

func set_scene_size(size: Vector2):
	scene_size = size
	boundary.size = size

func set_boundary(rect: Rect2):
	boundary = rect

func _ready():
	randomize()
	for i in range(BOX_COUNT):
		spawn_box()

func get_random_scale_speed():
	return randf_range(MIN_SCALE_SPEED, MAX_SCALE_SPEED)

func spawn_box():
	var box = WHITE_BOX.instantiate()
	add_child(box)
	
	# 在边界范围内随机生成位置
	box.position = Vector2(
		randf_range(boundary.position.x, boundary.end.x),
		randf_range(boundary.position.y, boundary.end.y)
	)
	
	# 添加自定义属性
	box.set_meta("velocity", Vector2(
		randf_range(MIN_VELOCITY, MAX_VELOCITY),
		randf_range(MIN_VELOCITY, MAX_VELOCITY)
	))
	box.set_meta("growing", randf() > 0.5)
	box.set_meta("scale_speed", get_random_scale_speed())
	box.modulate.a = randf_range(MIN_ALPHA, MAX_ALPHA)
	
	boxes.append(box)

func _process(delta):
	for box in boxes:
		# 更新位置
		var velocity = box.get_meta("velocity")
		box.position += velocity * delta
		
		# 检查边界碰撞
		if box.position.x < boundary.position.x or box.position.x > boundary.end.x:
			velocity.x *= -1
			box.position.x = clamp(box.position.x, boundary.position.x, boundary.end.x)
		if box.position.y < boundary.position.y or box.position.y > boundary.end.y:
			velocity.y *= -1
			box.position.y = clamp(box.position.y, boundary.position.y, boundary.end.y)
		box.set_meta("velocity", velocity)
		
		# 更新大小和透明度
		var growing = box.get_meta("growing")
		var scale_speed = box.get_meta("scale_speed")
		var current_scale = box.scale.x
		
		if growing:
			current_scale += scale_speed * delta
			box.modulate.a = lerp(MIN_ALPHA, MAX_ALPHA, (current_scale - MIN_SCALE) / (MAX_SCALE - MIN_SCALE))
			if current_scale >= MAX_SCALE:
				growing = false
				# 到达最大尺寸时，随机设置新的缩放速度
				box.set_meta("scale_speed", get_random_scale_speed())
		else:
			current_scale -= scale_speed * delta
			box.modulate.a = lerp(MIN_ALPHA, MAX_ALPHA, (current_scale - MIN_SCALE) / (MAX_SCALE - MIN_SCALE))
			if current_scale <= MIN_SCALE:
				growing = true
				# 到达最小尺寸时，随机设置新的缩放速度
				box.set_meta("scale_speed", get_random_scale_speed())
		
		box.scale = Vector2.ONE * current_scale
		box.set_meta("growing", growing)
