# util.gd
class_name Util
extends Object


static func standard_hour(military_hour: int) -> int:
	return ((military_hour + 11) % 12) + 1


static func enum_string(from_enum: Dictionary, value: int) -> String:
	return from_enum.keys()[value]
