extends Node2D


enum TransitionDirection {
	NONE = 0,
	FADE_OUT = -1,
	FADE_IN = 1
}

@onready var scene := $Scene.get_child(0)
@onready var scene_door: Door =  scene.get_node(^"TileMap/Door")
@onready var scene_player: Player = scene.get_node(^"TileMap/Player")
@onready var transition_rect := $ColorRect

var _transition_direction := TransitionDirection.NONE
var _transition_size := 0.0
var _transition_size_change := 1.2


func _ready():
	scene_fade_in()
	scene_door.entered.connect(scene_fade_out)


func _input(event):
	if Input.is_key_pressed(KEY_Q):
		scene_fade_out()


func _process(delta):
	if _transition_direction == TransitionDirection.NONE:
		return
		
	_transition_size += delta * _transition_size_change * _transition_direction
	transition_rect.material.set_shader_parameter("circle_size", _transition_size)
	
	if (_transition_direction == TransitionDirection.FADE_OUT and _transition_size <= 0.0):
		do_transition()
		scene_fade_in()
	elif _transition_size >= 1.5:
		_transition_direction = TransitionDirection.NONE


func scene_fade_out():
	transition_rect.material.set_shader_parameter("circle_position", 
		scene_door.global_position / get_viewport_rect().size)

	_transition_direction = TransitionDirection.FADE_OUT


func scene_fade_in():
	transition_rect.material.set_shader_parameter("circle_position", 
		scene_player.global_position / get_viewport_rect().size)
		
	_transition_direction = TransitionDirection.FADE_IN


func do_transition():
	var new_scene = load(scene_door.next_room).instantiate()
	
	$Scene.remove_child(scene)
	$Scene.add_child(new_scene)
	
	var new_player: Player = new_scene.get_node(^"TileMap/Player")
	
	new_player.transmutable_properties.set_properties(scene_player.transmutable_properties)
	
	scene.queue_free()
	
	scene = new_scene
	scene_door =  scene.get_node(^"TileMap/Door")
	scene_player = new_player
	
	scene_door.entered.connect(scene_fade_out)
