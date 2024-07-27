extends Area2D

class_name TransmutationCircle

## Stack of transmutable elements
static var property_stack: Array[TransmutableProperties] = []

## Associated Stack of circles for each element
static var affected_circles: Array[TransmutationCircle] = []

# TODO this is bad
static var done := false

## Exchanges property static_transmute_property in both elements in property_stack
# TODO cannot use two circles with same transmute_property. Mutex?
func _transmute():
	if property_stack.size() < 2:
		return

	if done:
		done = false
		return
	
	elif affected_circles[-1].transmute_property == affected_circles[-2].transmute_property:
		done = true

	var prop_buf = property_stack[-1].get_property(transmute_property)
	
	property_stack[-1].change_property(
		transmute_property, 
		property_stack[-2].get_property(transmute_property))
	property_stack[-2].change_property(
		transmute_property, 
		prop_buf)

## How much is subtracted/added to self.modulate.a per element in any circle?
const ModulateModifier := 0.4

## Indicated direction of circle fill animation
var _aborted := false

@export var transmute_property := TransmutableProperties.PropertyName.COLOR

@onready var circle := $Circle
@onready var smoke := $Smoke


func _ready():
	smoke.animation_finished.connect(smoke.hide)


func _adjust_modulate(value: float):
	if not self in affected_circles.slice(-2):
		modulate.a = 1.0 - 2 * ModulateModifier
		return
		
	modulate.a = value


func _reset_circle():
	circle.stop()
	circle.frame = 0
	circle.animation = &"idle"


## Add a property to the stack, as well as self to the stack of circles
func _add_properties(props: TransmutableProperties):
	property_stack.push_back(props)
	affected_circles.push_back(self)

	# TODO only last two
	get_tree().call_group(
		&"transmutation_circles", 
		&"_adjust_modulate", 
		1.0 - (clampi(2 - property_stack.size(), 0, 2) * ModulateModifier))


## Removes a property from the stack
func _remove_properties(props: TransmutableProperties):
	var prop_idx := property_stack.find(props)
	
	if prop_idx == -1:
		print("ERROR Trying to remove unregistered property from circle")
		return
	
	property_stack.pop_at(prop_idx)
	affected_circles.pop_at(prop_idx)
	
	# TODO only last two
	get_tree().call_group(
		&"transmutation_circles", 
		&"_adjust_modulate", 
		1.0 - (clampi(2 - property_stack.size(), 0, 2) * ModulateModifier))


## Should be called on group. Starts load-up animation
func start_transmutation():
	if (property_stack.size() < 2 
		or not self in affected_circles.slice(-2)):
		return

	circle.play(&"transmute")
	_aborted = false


## Shoud be called on group. Aborts load-up animation
func abort_transmutation():
	if not circle.is_playing():
		return

	circle.play_backwards()
	_aborted = true


func _on_body_entered(body: Node2D):
	print("Here")
	for child in body.get_children():
		if child is TransmutableProperties:
			_add_properties(child)
			break


func _on_body_exited(body: Node2D):
	for child in body.get_children():
		if child is TransmutableProperties:
			_remove_properties(child)
			break


## Used to determine if load-animation is finished
func _on_circle_animation_finished():
	# Don't do anything if "unloading" after aborting or any other animation is playing
	if _aborted or circle.animation != &"transmute":
		_reset_circle()
		return
	
	# Display smoke effect
	smoke.show()
	smoke.play(&"idle")
	
	_reset_circle()
	
	# Set _transmute to be called before next frame, but exactly once
	var process_signal := get_tree().process_frame
	if not process_signal.is_connected(_transmute):
		process_signal.connect(_transmute, Object.CONNECT_ONE_SHOT)
