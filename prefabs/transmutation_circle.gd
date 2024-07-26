extends Area2D

class_name TransmutationCircle

static var property_stack: Array[TransmutableProperties] = [null, null]
static var affected_circles: Array[TransmutationCircle] = [null, null]

const ModulateModifier := 0.4

var _aborted := false

@export var transmute_property := TransmutableProperties.PropertyName.COLOR

@onready var circle := $Circle
@onready var smoke := $Smoke


func _ready():
	smoke.animation_finished.connect(smoke.hide)

func _adjust_modulate(value: float):
	modulate.a = value

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


func _transmute():
	var prop_buf = property_stack[0].get_property(transmute_property)
	
	property_stack[0].change_property(transmute_property, property_stack[1].get_property(transmute_property))
	property_stack[1].change_property(transmute_property, prop_buf)

func start_transmutation():
	if null in property_stack or not self in affected_circles:
		return

	circle.play(&"transmute")
	_aborted = false


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


func _on_circle_animation_finished():
	if _aborted or circle.animation != &"transmute":
		circle.play(&"idle")
		return
	
	smoke.show()
	smoke.play(&"idle")
	circle.play(&"idle")
	
	get_tree().call_group_flags(get_tree().GROUP_CALL_UNIQUE | get_tree().GROUP_CALL_DEFERRED, 
	&"transmutation_circles", &"_transmute")
