extends Level
# final-level
@onready var label_score_num = $Labels/LabelScoreNum

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

var score: int = 0
var score_arr: Array = ["999979", "999980", "999981", "999982", "999983", "999984", 
						"999985", "999986", "999987", "999988", "999989", "999990", 
						"999991", "999992", "999993", "999994", "999995", "999996", 
						"999997", "999998", "999999"]

func check_tiles():
	update_movable_tetris_tiles()
	# 从下往上遍历每一行
	for grid_y in range(grid_down, grid_up - 1, -1):
		if check_line(grid_y):
			score += 1
			RemoveSfxPlayer.play_remove()
			score = min(score, score_arr.size() - 1)
			label_score_num.text = score_arr[score]
			return
