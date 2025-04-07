extends Level
# stlevel

const PLAYER_I_4 = preload("res://scenes/player/player_i_4.tscn")
var player_exists: bool = false
@onready var spawn_marker: Marker2D = $SpawnMarker
@onready var label_enter: Label = $Labels/LabelEnter
@onready var labelstgame: Label = $Labels/Labelstgame
@onready var label_score_num: Label = $Labels/LabelScoreNum

func _input(event):
	if not player_exists and event.is_action_pressed("enter"):
		var player: Player = PLAYER_I_4.instantiate()
		player.global_position = spawn_marker.global_position
		player.player_updated.connect(_on_player_updated)
		moving_tetris.add_child(player)
		player_exists = true
		label_enter.text = " AD<->"
		labelstgame.text = "Move"

func check_tiles():
	update_movable_tetris_tiles()
	# 从下往上遍历每一行
	for grid_y in range(grid_down, grid_up - 1, -1):
		if check_line(grid_y):
			RemoveSfxPlayer.play_remove()
			label_score_num.text = "000001"
			label_enter.text = "SPACE"
			labelstgame.text = "jump"
			return

func _on_exit_area_body_entered(body):
	start_next_level.emit(self, next_level)
