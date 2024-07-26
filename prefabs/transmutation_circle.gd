extends Area2D

class_name TransmutationCircle

## Stack of transmutable elements
# TODO: reset stack on leave circle? bigger stack?
static var property_stack: Array[TransmutableProperties] = [null, null]

## Associated Stack of circles for each element
static var affected_circles: Array[TransmutationCircle] = [null, null]

## What property should be changed
static var static_transmute_property := TransmutableProperties.PropertyName.COLOR

## Exchanges property static_transmute_property in both elements in property_stack
static func _transmute():
	var prop_buf = property_stack[0].get_property(static_transmute_property)
	
	property_stack[0].change_property(
		static_transmute_property, 
		property_stack[1].get_property(static_transmute_property))
	property_stack[1].change_property(
		static_transmute_property, 
		prop_buf)

## How much is subtracted/added to self.modulate.a per element in any circle?
const ModulateModifier := 0.4

## Indicated direction of circle fill animation
var _aborted := false

@export var transmute_property: TransmutableProperties.PropertyName:
	get:
		return static_transmute_property
	set(value):
		static_transmute_property = value

@onready var circle := $Circle
@onready var smoke := $Smoke


func _ready():
	smoke.animation_finished.connect(smoke.hide)


func _adjust_modulate(value: float):
	modulate.a = value


func _reset_circle():
	circle.frame = 0
	circle.animation = &"idle"


## Add a property to the stack, as well as self to the stack of circles
func _add_properties(props: TransmutableProperties):
	if property_stack[0]:
		property_stack[1] = property_stack[0]
		affected_circles[1] = affected_circles[0]
		
	property_stack[0] = props
	affected_circles[0] = self
	
	get_tree().call_group(
		&"transmutation_circles", 
		&"_adjust_modulate", 
		1.0 - (property_stack.count(null) * ModulateModifier))


## Removes a property from the stack
func _remove_properties(props: TransmutableProperties):	
	if property_stack[0] == props:
		property_stack[0] = property_stack[1]
		affected_circles[0] = affected_circles[1]
		property_stack[1] = null
		affected_circles[1] = null
		
	elif property_stack[1] == props:
		property_stack[1] = null
		affected_circles[1] = null
	
	get_tree().call_group(
		&"transmutation_circles", 
		&"_adjust_modulate", 
		1.0 - (property_stack.count(null) * ModulateModifier))


## Should be called on group. Starts load-up animation
func start_transmutation():
	if null in property_stack or not self in affected_circles:
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
	if _aborted or circle.animation != &"transmute":
		_reset_circle()
		return
	
	# Display smoke effect
	smoke.show()
	smoke.play(&"idle")
	
	_reset_circle()
	
	# Set _transmute to be called before next frame, but exactly once
	var process_signal := get_tree().process_frame
	if not process_signal.is_connected(TransmutationCircle._transmute):
		process_signal.connect(TransmutationCircle._transmute, Object.CONNECT_ONE_SHOT)
