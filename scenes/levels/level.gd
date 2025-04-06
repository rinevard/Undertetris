class_name Level
extends Node2D

@onready var baker = $Baker
@onready var moving_tetris: Node2D = $MovingTetris
@onready var level_tile_map_layer: TileMapLayer = $LevelTileMapLayer
const EXPLODE_JUICE = preload("res://scenes/juicy/explode_juice.tscn")

## 可以移动的 tetris 的所在格, tile -> tetris
var movable_tetris_tiles: Dictionary = {} 
## tetris -> down_grid_y
var tetris_down_grid_y: Dictionary = {}

## 网格边界
const grid_bias = 3.0 # 偏移这个值来保证落在 grid 内
@export var left_bound: float = 0.0
@export var right_bound: float = 486.0
@export var up_bound: float = 0.0
@export var down_bound: float = 1080.0
var grid_left: int
var grid_right: int  
var grid_up: int
var grid_down: int

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioPlayer.play_music_start()
	# 偏移 grid_bias 来保证落在 grid 内
	left_bound += grid_bias
	right_bound -= grid_bias
	up_bound += grid_bias
	down_bound -= grid_bias
	
	var local_left_up_bound = level_tile_map_layer.to_local(Vector2(left_bound, up_bound))
	var grid_left_up_bound = level_tile_map_layer.local_to_map(local_left_up_bound)
	var local_right_down_bound = level_tile_map_layer.to_local(Vector2(right_bound, down_bound))
	var grid_right_down_bound = level_tile_map_layer.local_to_map(local_right_down_bound)
	
	grid_left = grid_left_up_bound[0]
	grid_right = grid_right_down_bound[0]
	grid_up = grid_left_up_bound[1]
	grid_down = grid_right_down_bound[1]
	print(grid_left, "\n", grid_right, "\n", grid_up, "\n", grid_down)
	# 设置碰撞
	baker.run_code()

var check_gap: float = 2.0
func _process(delta):
	if Globals.player_still_time > check_gap:
		check_tiles()
		Globals.player_still_time = 0.0

func update_movable_tetris_tiles():
	movable_tetris_tiles.clear()
	var children: Array[Node] = moving_tetris.get_children()
	for tetris in children:
		tetris_down_grid_y[tetris] = -1
		var global_positions = tetris.get_tetris_global_pos()
		for global_pos in global_positions:
			var local_pos = level_tile_map_layer.to_local(global_pos)
			var map_pos = level_tile_map_layer.local_to_map(local_pos)
			movable_tetris_tiles[map_pos] = tetris
			tetris_down_grid_y[tetris] = max(map_pos.y, tetris_down_grid_y[tetris])
	

## 本函数在玩家静止 1s 后被调用
## 从 down_bound 往上逐行检查, 消除任一行后结束
func check_tiles():
	update_movable_tetris_tiles()
	# 从下往上遍历每一行
	for grid_y in range(grid_down, grid_up - 1, -1):
		if check_line(grid_y):
			SfxPlayer.play_remove()
			return

## 检查 grid_y 那一行是否可以消除
## 从左到右遍历该行的每个格子,检查是否都被填充
## 如果都被填充则消除该行并返回true,否则返回false
func check_line(grid_y: int) -> bool:
	var tetris_to_removeline: Dictionary = {}
	for grid_x in range(grid_left, grid_right + 1):
		if Vector2i(grid_x, grid_y) in movable_tetris_tiles:
			tetris_to_removeline[movable_tetris_tiles[Vector2i(grid_x, grid_y)]] = null
		elif level_tile_map_layer.get_cell_tile_data(Vector2i(grid_x, grid_y)):
			continue
		else: # 如果有空格, 返回 false, 不必 remove_line
			return false
	
	# 更新 tile, 删掉这一行的所有 tile
	for grid_x in range(grid_left, grid_right + 1):
		var explode_juice = EXPLODE_JUICE.instantiate()
		add_child(explode_juice)
		var rel_pos = level_tile_map_layer.map_to_local(Vector2i(grid_x, grid_y))
		var global_pos = level_tile_map_layer.to_global(rel_pos)
		explode_juice.global_position = global_pos
	
	for grid_x in range(grid_left, grid_right + 1):
		level_tile_map_layer.erase_cell(Vector2i(grid_x, grid_y))
	
	# 反查表, 调用 remove_line. 这里需要找到 grid_y 在其所有 grid 中的 line 位置
	# 由于每个 tetris 必然是连续的, 我们 remove_line(grid_y - down_grid_y) 即可. 
	for tetris in tetris_to_removeline:
		var down_grid_y = tetris_down_grid_y[tetris]
		tetris.remove_line(grid_y - down_grid_y)
		
	# 更新碰撞
	baker.run_code()
	return true
