class_name StackDrag
extends RefCounted
## Data-only state and rules for a click-drag that splits the cursor's stack
## evenly across every slot stack the mouse passes over.

var hovered_stacks: Dictionary[ItemStack, bool] = {}
var dragging_stack := ItemStack.new(null, 0)
var pressed_stack: ItemStack
var is_complete := false


func is_active() -> bool:
	return not hovered_stacks.is_empty()


## True until the first drag frame has captured the stack being dragged.
func is_pending() -> bool:
	return dragging_stack.is_empty()


## Remembers the stack the left button went down on, so leaving it starts a drag.
func arm(stack: ItemStack) -> void:
	pressed_stack = stack


## Starts a drag from the armed stack. Returns true if the stack joined the drag.
func begin_from(stack: ItemStack) -> bool:
	if pressed_stack != stack or stack.is_empty() or not is_pending():
		return false

	mark_hovered(stack)
	return true


func has_hovered(stack: ItemStack) -> bool:
	return stack in hovered_stacks


func mark_hovered(stack: ItemStack) -> void:
	hovered_stacks[stack] = true


func can_enter(stack: ItemStack) -> bool:
	if has_hovered(stack):
		return false
	return stack.is_empty() or stack.can_stack_with(dragging_stack)


func start(cursor_stack: ItemStack) -> void:
	if not is_active() or not is_pending():
		return

	var first_stack: ItemStack = hovered_stacks.keys()[0]

	dragging_stack = first_stack.copy()
	if not cursor_stack.is_empty():
		cursor_stack.pop_to(dragging_stack, cursor_stack.count)


## Redistributes the dragged items across all hovered stacks plus `entered`.
## Returns the stack that should now be held by the cursor.
func split_into(entered: ItemStack) -> ItemStack:
	var null_stack := ItemStack.new(null, 0)
	var dragging_count := dragging_stack.count
	var previous_size := hovered_stacks.size()
	var rollback_count := int(float(dragging_count) / float(previous_size))
	var split_count := int(float(dragging_count) / float(previous_size + 1))
	var split_stack := dragging_stack.copy()

	mark_hovered(entered)

	for hovered_stack: ItemStack in hovered_stacks:
		if hovered_stack != entered:
			hovered_stack.pop_to(null_stack, rollback_count)
		split_stack.pop_to(hovered_stack, split_count)

	is_complete = previous_size == dragging_count - 1
	return split_stack


func clear() -> void:
	hovered_stacks.clear()
	dragging_stack.clear()
	pressed_stack = null
	is_complete = false
