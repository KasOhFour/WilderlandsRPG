class_name DualGrid
extends Node

const ATLAS := [
	Vector2i(0, 3), # 0  = ..
	Vector2i(3, 3), # 1  = NW
	Vector2i(0, 2), # 2  = NE
	Vector2i(1, 2), # 3  = NW, NE
	Vector2i(0, 0), # 4  = SW
	Vector2i(3, 2), # 5  = NW, SW
	Vector2i(2, 3), # 6  = NE, SW
	Vector2i(3, 1), # 7  = NW, NE, SW
	Vector2i(1, 3), # 8  = SE
	Vector2i(0, 1), # 9  = NW, SE
	Vector2i(1, 0), # 10 = NE, SE
	Vector2i(2, 2), # 11 = NW, NE, SE
	Vector2i(3, 0), # 12 = SW, SE
	Vector2i(2, 0), # 13 = NW, SW, SE
	Vector2i(1, 1), # 14 = NE, SW, SE
	Vector2i(2, 1), # 15 = NW, NE, SW, SE
]
