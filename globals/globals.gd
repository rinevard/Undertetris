extends Node

const GRID_SIZE = 8


# 用于节点间通信
## 在玩家静止 2s 后, check一次, 把它置零
var player_still_time: float = 0.0
