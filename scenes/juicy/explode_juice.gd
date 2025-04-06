extends Node2D

@onready var sprite_2d = $Sprite2D

# 闪烁次数
const BLINK_COUNT = 2
# 每个闪烁的持续时间
const BLINK_DURATION = 0.1
# 放大动画持续时间
const SCALE_DURATION = 0.15
# 最大缩放倍数
const MAX_SCALE = 1.5

func _ready():
	play_effect()

func play_effect():
	sprite_2d.modulate.a = 1.0
	sprite_2d.scale = Vector2(1, 1)
	
	var tween = create_tween()
	
	# 闪烁效果（使用线性）
	for i in range(BLINK_COUNT):
		tween.tween_property(sprite_2d, "modulate:a", 0.3, BLINK_DURATION)\
			.set_trans(Tween.TRANS_LINEAR)\
			.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(sprite_2d, "modulate:a", 1.0, BLINK_DURATION)\
			.set_trans(Tween.TRANS_LINEAR)\
			.set_ease(Tween.EASE_IN_OUT)
	
	# 放大并渐隐（使用easeOutExpo）
	tween.tween_property(sprite_2d, "scale", Vector2(MAX_SCALE, MAX_SCALE), SCALE_DURATION)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite_2d, "modulate:a", 0.0, SCALE_DURATION)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(queue_free)
