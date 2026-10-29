# state_machine.gd
class_name StateMachine
extends RefCounted


var states: Dictionary[StringName, State] = {}
var from := State.new()


@warning_ignore("shadowed_variable")
func _init(states := self.states, from := self.from) -> void:
	self.states = states
	self.from = from


func add_state(state: State) -> void:
	states[state.name] = state


func current_state() -> StringName:
	return from.name


func change(name: StringName) -> void:
	var to := states[name]
	if to:
		if from.exit(to) and to.enter(from):
			from = to
