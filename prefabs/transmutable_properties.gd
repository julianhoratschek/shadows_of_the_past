@tool

extends Node2D

class_name TransmutableProperties

enum PropertyName {COLOR, SHAPE, SIZE}

enum TransColor {RED, BLUE, GREEN}
enum TransShape {CIRCLE, TRIANGLE, SQUARE, FISH, LEAF}
enum TransSize {SMALL, NORMAL, BIG}

const PropertyMap := {
	PropertyName.COLOR: TransColor,
	PropertyName.SHAPE: TransShape,
	PropertyName.SIZE: TransSize
}

const ColorMap := {
	TransColor.RED: Color.RED,
	TransColor.BLUE: Color.BLUE,
	TransColor.GREEN: Color.GREEN
}

signal transmuted(property_name: PropertyName, old_value, new_value)

var _properties := {
	PropertyName.COLOR: TransColor.RED,
	PropertyName.SHAPE: TransShape.TRIANGLE,
	PropertyName.SIZE: TransSize.NORMAL
}

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

func _ready():
	_changed_shape()

func _changed_color():
	modulate = ColorMap[_properties[PropertyName.COLOR]]

func _changed_shape():
	$AnimatedSprite2D.play(TransShape.keys()[_properties[PropertyName.SHAPE]].to_lower() + "_idle")
	
	if no_animation:
		$AnimatedSprite2D.stop()

func _changed_size():
	pass

func get_property(property_name: PropertyName):	
	return _properties[property_name]

func set_properties(other: TransmutableProperties):
	for property_name in PropertyName:
		change_property(property_name, other._properties[property_name])

func change_property(property_name: PropertyName, new_value):
	if not new_value in PropertyMap[property_name].values():
		print("ERROR: Invalid Value assigned to transmutable Property")
		return
		
	var old_value = _properties[property_name]
	
	_properties[property_name] = new_value
	
	transmuted.emit(property_name, old_value, new_value)
	
	if default_change:
		var prop_string: String = PropertyName.keys()[property_name].to_lower()
		var method_name: String = "_changed_" + prop_string
		
		if has_method(method_name):
			call(method_name)
			
		else:
			print("ERROR: _changed_method not defined for property %s" % prop_string)
		
	else:
		default_change = true



