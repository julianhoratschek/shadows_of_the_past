@tool

extends Node2D

class_name TransmutableProperties

## Names of changeable properties
enum PropertyName {COLOR, SHAPE, SIZE}

## Colors
enum TransColor {RED, BLUE, GREEN}

## Shapes
enum TransShape {CIRCLE, TRIANGLE, SQUARE, FISH, R, E, D, GUARD, LEAF}

## Sizes
enum TransSize {SMALL, NORMAL, BIG}

## Select correct enum by name
const PropertyMap := {
	PropertyName.COLOR: TransColor,
	PropertyName.SHAPE: TransShape,
	PropertyName.SIZE: TransSize
}

## Select correct Color from TransColor
const ColorMap := {
	TransColor.RED: Color.RED,
	TransColor.BLUE: Color.BLUE,
	TransColor.GREEN: Color.GREEN
}

## Shapes which have a random alternative animation
const AltAnimations := [TransShape.FISH]

## Emitted right before transmutation takes place.
signal transmuted(property_name: PropertyName, old_value, new_value)

## Properties of this object
var _properties := {
	PropertyName.COLOR: TransColor.RED,
	PropertyName.SHAPE: TransShape.TRIANGLE,
	PropertyName.SIZE: TransSize.NORMAL
}

## Counters for random animations
var _alt_animation_timer := 0.0
var _alt_animation_counter := 0.0

## Indicates to use default setters for properties
var default_change := true

@export var transmute_color := TransColor.RED:
	get:
		return _properties[PropertyName.COLOR]
	set(value):
		change_property(PropertyName.COLOR, value)

@export var transmute_shape := TransShape.TRIANGLE:
	get:
		return _properties[PropertyName.SHAPE]
	set(value):
		change_property(PropertyName.SHAPE, value)

@export var transmute_size := TransSize.NORMAL:
	get:
		return _properties[PropertyName.SIZE]
	set(value):
		change_property(PropertyName.SIZE, value)

@export var no_animation := true


## Setup animation
func _ready():
	_changed_shape()


## Play random alternative animation if accessible
func _process(delta: float):
	# Test if we play animations and if we expect an alternative animation
	if no_animation or not transmute_shape in AltAnimations:
		return
	
	# Count frames until new random animation
	_alt_animation_counter += delta
	if _alt_animation_counter < _alt_animation_timer:
		return
	
	# Reset counters at random interval
	_alt_animation_counter = 0.0
	_alt_animation_timer = randf_range(2.4, 15.0)
	
	# Set random animation
	var animation_name: String = TransShape.keys()[_properties[PropertyName.SHAPE]].to_lower()
	_set_animation(&"_alt")
	
	# Set standard idle animation on finish and disconnect signal
	if not $AnimatedSprite2D.animation_finished.is_connected(_set_animation):
		$AnimatedSprite2D.animation_finished.connect(
			_set_animation.bind(&"_idle"),
			Object.CONNECT_ONE_SHOT)


## Set the current shape name with [param animation_suffix] as current animation
func _set_animation(animation_suffix: StringName):
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	
	sprite.play(
		TransShape.keys()[_properties[PropertyName.SHAPE]].to_lower() + animation_suffix)
	
	# Don't play animations if we don't want to
	if no_animation:
		sprite.stop()
	
	# Otherwise set random starting frame
	else:
		sprite.frame_progress = randf_range(0.0, 1.0)


## Default setter for color property: Change modulate
func _changed_color():
	modulate = ColorMap[_properties[PropertyName.COLOR]]


## Default setter for shape property: Set idle-Animation
func _changed_shape():
	_set_animation(&"_idle")


## Default setter for size property
func _changed_size():
	pass


## Convenience method to retrieve prpoerty
func get_property(property_name: PropertyName):	
	return _properties[property_name]


## Set all properties to the values of [param other]. Calls [method change_property]
func set_properties(other: TransmutableProperties):
	for property_name in PropertyName.values():
		change_property(property_name, other._properties[property_name])


## Transmute property [param property_name] to [param new_value]. Emits transmuted.
func change_property(property_name: PropertyName, new_value):
	# You can't be too sure
	if not new_value in PropertyMap[property_name].values():
		print("ERROR: Invalid Value assigned to transmutable Property")
		return
		
	# Set new value and emit transmute
	var old_value = _properties[property_name]
	_properties[property_name] = new_value
	transmuted.emit(property_name, old_value, new_value)
	
	# Only change values if we want to use standard methods
	if default_change:
		var prop_string: String = PropertyName.keys()[property_name].to_lower()
		var method_name: String = "_changed_" + prop_string
		
		if has_method(method_name):
			call(method_name)
			
		else:
			print("ERROR: _changed_method not defined for property %s" % prop_string)


## Play desintegration animation
func desintegrate():
	modulate = Color.WHITE
	$AnimatedSprite2D.play(&"desintegrate")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play(&"smoke")



