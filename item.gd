# Item.gd
class_name Item
extends Resource

enum MaxStackCount { UNSTACKABLE = 1, SMALL = 9, NORMAL = 99, LARGE = 999 }
enum Rarity { COMMON = 0xffffff, UNCOMMON = 0x6464ff, RARE = 0x64ff64, EPIC = 0xff6464, STORY = 0xffd33d }

@export var id := -1
@export var name: String
@export var rarity := Item.Rarity.COMMON
@export var texture := default_texture()
@export var margins: int
@export var max_stack_count := Item.MaxStackCount.UNSTACKABLE

static func default_texture() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(image)


func equals(other: Item) -> bool:
	return other != null && id == other.id
