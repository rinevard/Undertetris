extends Level
# level2

const PLAYER_I_4 = preload("res://scenes/player/player_i_4.tscn")
var player_exists: bool = false
@onready var spawn_marker: Marker2D = $SpawnMarker

func _ready():
	super()
	var player: Player = PLAYER_I_4.instantiate()
	player.global_position = spawn_marker.global_position
	player.player_updated.connect(_on_player_updated)
	moving_tetris.add_child(player)

func _on_exit_area_body_entered(body):
	start_next_level.emit(self, next_level)
	print("next")

func check_tiles():
	update_movable_tetris_tiles()
	# 从下往上遍历每一行
	for grid_y in range(grid_down, grid_up - 1, -1):
		if check_line(grid_y):
			RemoveSfxPlayer.play_remove()
			return
