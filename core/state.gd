# state.md
class_name State
extends RefCounted

var name := &''
var enter_cb := func(): return
var exit_cb := func(): return
var illegal_from: Array[StringName] = []
var illegal_to: Array[StringName] = []


@warning_ignore('shadowed_variable')
func _init(
		name := self.name,
		enter_cb := self.enter_cb,
		exit_cb := self.exit_cb,
		illegal_from := self.illegal_from,
		illegal_to := self.illegal_to,
) -> void:
	self.name = name
	self.enter_cb = enter_cb
	self.exit_cb = exit_cb
	self.illegal_from = illegal_from
	self.illegal_to = illegal_to


func enter(from: State) -> bool:
	if illegal_from.has(from.name):
		return false
	enter_cb.call()
	return true


func exit(to: State) -> bool:
	if illegal_to.has(to.name):
		return false
	exit_cb.call()
	return true
