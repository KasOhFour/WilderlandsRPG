@tool
# entity_status_gauge.gd
class_name EntityStatusGauge
extends Resource

signal gauge_minimized()
signal gauge_maximized()

@export var entity_status: EntityStatus:
	set = _set_entity_status
@export var entity_status_min: EntityStatus:
	set = _set_entity_status_min
@export var entity_status_max: EntityStatus:
	set = _set_entity_status_max

var value: float:
	set = _set_value, get = _get_value
var value_changed: Signal:
	get = _get_value_changed
var value_min: float:
	set = _set_value_min, get = _get_value_min
var value_min_changed: Signal:
	get = _get_value_min_changed
var value_max: float:
	set = _set_value_max, get = _get_value_max
var value_max_changed: Signal:
	get = _get_value_max_changed
var newly_minimized := false
var newly_maximized := false


func _init(
		_name := EntityStatus.DEFAULT_NAME,
		_value := EntityStatus.DEFAULT_VALUE,
		_rounding := EntityStatus.DEFAULT_ROUNDING,
		_value_min := EntityStatus.DEFAULT_VALUE,
		_value_max := EntityStatus.DEFAULT_VALUE,
) -> void:
	if not entity_status:
		entity_status = EntityStatus.new(_name, _value, _rounding)
	if not entity_status_min:
		entity_status_min = EntityStatus.new('%s_min' % _name, _value_min, _rounding)
	if not entity_status_max:
		entity_status_max = EntityStatus.new('%s_max' % _name, _value_max, _rounding)
	_connect_once(entity_status.value_changed, _on_value_changed)
	_connect_once(entity_status_min.value_changed, _on_value_min_changed)
	_connect_once(entity_status_max.value_changed, _on_value_max_changed)

	newly_minimized = value <= value_min
	if newly_minimized:
		gauge_minimized.emit()

	newly_maximized = value >= value_max
	if newly_maximized:
		gauge_maximized.emit()


func _set_value(_value: float) -> void:
	entity_status.value = clamp(_value, value_min, value_max)


func _set_value_min(_value: float) -> void:
	entity_status_min.value = _value


func _set_value_max(_value: float) -> void:
	entity_status_max.value = _value


func _get_value() -> float:
	return entity_status.value


func _get_value_changed() -> Signal:
	return entity_status.value_changed


func _get_value_min() -> float:
	return entity_status_min.value


func _get_value_min_changed() -> Signal:
	return entity_status_min.value_changed


func _get_value_max() -> float:
	return entity_status_max.value


func _get_value_max_changed() -> Signal:
	return entity_status_max.value_changed


func _compare(delta: float, who_changed: EntityStatus) -> void:
	var was_minimized := newly_minimized
	var was_maximized := newly_maximized

	newly_minimized = value <= value_min
	newly_maximized = value >= value_max

	match who_changed:
		entity_status:
			if delta < 0 and newly_minimized and not was_minimized:
				gauge_minimized.emit()
				return
			if delta > 0 and newly_maximized and not was_maximized:
				gauge_maximized.emit()
				return
		entity_status_min:
			if newly_minimized and not was_minimized:
				gauge_minimized.emit()
				return
		entity_status_max:
			if newly_maximized and not was_maximized:
				gauge_maximized.emit()
				return


func _on_value_changed(delta: float) -> void:
	_compare(delta, entity_status)


func _on_value_min_changed(delta: float) -> void:
	_compare(delta, entity_status_min)


func _on_value_max_changed(delta: float) -> void:
	_compare(delta, entity_status_max)


func _connect_once(_signal: Signal, callable: Callable) -> void:
	if not _signal.is_connected(callable):
		_signal.connect(callable)


func _replace_status(
		old_status: EntityStatus,
		new_status: EntityStatus,
		callback: Callable,
) -> EntityStatus:
	if old_status and old_status.value_changed.is_connected(callback):
		old_status.value_changed.disconnect(callback)

	if new_status:
		_connect_once(new_status.value_changed, callback)

	return new_status


func _set_entity_status(status: EntityStatus) -> void:
	entity_status = _replace_status(
		entity_status,
		status,
		_on_value_changed,
	)


func _set_entity_status_min(status: EntityStatus) -> void:
	entity_status_min = _replace_status(
		entity_status_min,
		status,
		_on_value_min_changed,
	)


func _set_entity_status_max(status: EntityStatus) -> void:
	entity_status_max = _replace_status(
		entity_status_max,
		status,
		_on_value_max_changed,
	)
