extends Node2D

@export var cur_packed_lecel: PackedScene
@export var cur_level: Level
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var black_mask = $CanvasLayer/BlackMask
@onready var menu: MainMenu = $CanvasLayer/Menu
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	black_mask.visible = false
	menu.visible = false
	cur_level.start_next_level.connect(_on_st_level_start_next_level)
	cur_level.player_updated.connect(_on_player_updated)

func _on_player_updated(new_player: Player):
	phantom_camera_2d.erase_follow_target()
	phantom_camera_2d.set_follow_target(new_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_st_level_start_next_level(old_level: Level, new_level: PackedScene):
	black_mask.visible = true
	animation_player.play("black_fade_in")
	await animation_player.animation_finished
	
	var new_level_scene: Level = new_level.instantiate()
	old_level.call_deferred("queue_free")
	new_level_scene.start_next_level.connect(_on_st_level_start_next_level)
	new_level_scene.player_updated.connect(_on_player_updated)
	call_deferred("add_child", new_level_scene)
	cur_packed_lecel = new_level
	cur_level = new_level_scene
	phantom_camera_2d.limit_bottom = max(new_level_scene.down_bound - 200.0, 280) # camera bias
	
	animation_player.play("black_fade_out")
	await animation_player.animation_finished
	black_mask.visible = false


func _on_menu_need_quit():
	black_mask.visible = true
	animation_player.play("black_fade_in")
	await animation_player.animation_finished
	get_tree().quit()

func _on_menu_need_restart():
	black_mask.visible = true
	animation_player.play("black_fade_in")
	await animation_player.animation_finished
	
	var reset_level: Level = cur_packed_lecel.instantiate()
	if cur_level and is_instance_valid(cur_level):
		cur_level.call_deferred("queue_free")
	reset_level.start_next_level.connect(_on_st_level_start_next_level)
	reset_level.player_updated.connect(_on_player_updated)
	call_deferred("add_child", reset_level)
	cur_level = reset_level
		
	animation_player.play("black_fade_out")
	await animation_player.animation_finished
	black_mask.visible = false
