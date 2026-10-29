class_name WfcDirections
# 36028797018963966

const DIRS := [
	Vector2i(0, -1),  # 0,N
	Vector2i(1, -1),  # 1,NE
	Vector2i(1, 0),   # 2,E
	Vector2i(1, 1),   # 3,SE
	Vector2i(0, 1),   # 4,S
	Vector2i(-1, 1),  # 5,SW
	Vector2i(-1, 0),  # 6,W
	Vector2i(-1, -1), # 7,NW
]

const OPPOSITE := [4, 5, 6, 7, 0, 1, 2, 3]
