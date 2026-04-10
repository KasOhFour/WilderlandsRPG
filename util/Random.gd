class_name Random
extends Node


static func seeded_randf(
		input_seed: int,
		salt: Variant,
		min_value: float = -INF,
		max_value: float = +INF,
) -> float:
	var derived_seed := derive_seed(input_seed, salt)
	seed(derived_seed)
	return randf_range(min_value, max_value)


static func seeded_randi(
		input_seed: int,
		salt: Variant,
		min_value: float = -INF,
		max_value: float = +INF,
) -> int:
	var derived_seed := derive_seed(input_seed, salt)
	seed(derived_seed)
	return randi_range(int(min_value), int(max_value))


static func shuffle(input_seed: int, salt: Variant, array: Array) -> void:
	var derived_seed := derive_seed(input_seed, salt)
	seed(derived_seed)
	array.shuffle()


static func derive_seed(input_seed: int, salt: Variant) -> int:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)

	ctx.update(var_to_bytes(input_seed))
	ctx.update(var_to_bytes(salt))

	var digest := ctx.finish()

	var derived_seed := 0
	for i in range(8):
		derived_seed = (derived_seed << 8) | digest[i]

	return derived_seed
