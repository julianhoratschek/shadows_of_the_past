@tool

extends Area2D

class_name TransmutationCircle

## Stack of transmutable elements
static var property_stack: Array[TransmutableProperties] = []

## Associated Stack of circles for each element
static var affected_circles: Array[TransmutationCircle] = []

## Exchanges property static_transmute_property in both elements in property_stack
func _transmute():
	if property_stack.size() < 2:
		return

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

## Property this circle will exchange
@export var transmute_property := TransmutableProperties.PropertyName.COLOR:
	get:
		return transmute_property
		
	set(value):
		transmute_property = value
		$Indicator.frame = int(value)

@onready var circle := $Circle
@onready var indicator := $Indicator
@onready var smoke := $Smoke


func _ready():
	smoke.animation_finished.connect(smoke.hide)
	_adjust_modulate(0.2)


## Set modulate of the circle sprite to value if this circle can be used in the
## next transmutation
func _adjust_modulate(value: float):
	# If this circle is currently unused, set low alpha
	if not self in affected_circles.slice(-2):
		circle.modulate.a = 1.0 - 2 * ModulateModifier
		return
	
	# Otherwise set alpha to value
	circle.modulate.a = value


## Reset visual circle to standard values
func _reset_circle():
	circle.stop()
	circle.frame = 0
	circle.animation = &"idle"


## Add a property to the stack, as well as self to the stack of circles
func _add_properties(props: TransmutableProperties):
	property_stack.push_back(props)
	affected_circles.push_back(self)

	# TODO Here only the last two could be called?
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
	
	# Abort all animations if there aren't enough properties
	if property_stack.size() < 2:
		get_tree().call_group(
			&"transmutation_circles",
			&"abort_transmutation")


## Should be called on group. Starts load-up animation
func start_transmutation():
	# Only affects last two circles
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
	if _aborted or affected_circles.size() < 2 or circle.animation != &"transmute":
		_reset_circle()
		return
	
	# Display smoke effect
	smoke.show()
	smoke.play(&"idle")
	$AudioStreamPlayer2D.play()
	
	_reset_circle()

	# Set _transmute to be called before next frame
	var process_signal := get_tree().process_frame
	
	# Add another call, if both circles use different properties
	var other_circle := affected_circles[-1] if affected_circles[-2] == self else affected_circles[-2]
	if (other_circle.transmute_property != transmute_property 
		or not process_signal.is_connected(other_circle._transmute)):
			process_signal.connect(_transmute, Object.CONNECT_ONE_SHOT)
	
