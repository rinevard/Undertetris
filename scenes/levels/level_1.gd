extends Level
# level1

const PLAYER_I_4 = preload("res://scenes/player/player_i_4.tscn")
var player_exists: bool = false
@onready var spawn_marker: Marker2D = $SpawnMarker
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D

func _ready():
	super()
	var player: Player = PLAYER_I_4.instantiate()
	player.global_position = spawn_marker.global_position
	player.player_updated.connect(_on_player_updated)
	phantom_camera_2d.set_follow_target(player)
	moving_tetris.add_child(player)

func _on_exit_area_body_entered(body):
	start_next_level.emit()
	print("next")

func check_tiles():
	update_movable_tetris_tiles()
	# 从下往上遍历每一行
	for grid_y in range(grid_down, grid_up - 1, -1):
		if check_line(grid_y):
			RemoveSfxPlayer.play_remove()
			return

func _on_player_updated(new_player: Player):
	new_player.player_updated.connect(_on_player_updated)
	_update_camera_target(new_player)

func _update_camera_target(player: Player):
	phantom_camera_2d.set_follow_target(player)
