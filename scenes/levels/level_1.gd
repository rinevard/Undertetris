extends Level
# level1

const PLAYER_I_4 = preload("res://scenes/player/player_i_4.tscn")
var player_exists: bool = false
@onready var spawn_marker: Marker2D = $SpawnMarker

func _ready():
	super()
	var player = PLAYER_I_4.instantiate()
	player.global_position = spawn_marker.global_position
	moving_tetris.add_child(player)

func _on_exit_area_body_entered(body):
	start_next_level.emit()
	print(1)
