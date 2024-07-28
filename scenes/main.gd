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
@onready var reset_properties := $ResetProperties

var _transition_direction := TransitionDirection.NONE
var _transition_size := 0.0
var _transition_size_change := 1.2

var _room_path := "res://scenes/shape_change_scene.tscn"
var _reset := false

var _to_winning_scene := false

func _ready():
	scene_fade_in()
	scene_door.entered.connect(scene_fade_out)


func _input(event):
	if not _reset and Input.is_action_just_pressed(&"gme_reset_room"):
		_reset = true
		scene_fade_out(_room_path)


func _process(delta):
	if _transition_direction == TransitionDirection.NONE:
		return
		
	_transition_size += delta * _transition_size_change * _transition_direction
	transition_rect.material.set_shader_parameter("circle_size", _transition_size)
	
	if (_transition_direction == TransitionDirection.FADE_OUT and _transition_size <= 0.0):
		if _to_winning_scene:
			get_tree().change_scene_to_file(_room_path)
		else:
			do_transition()
			scene_fade_in()
		
	elif _transition_size >= 1.5:
		_transition_direction = TransitionDirection.NONE


func scene_fade_out(next_room_path: String):
	transition_rect.material.set_shader_parameter("circle_position", 
		scene_door.global_position / get_viewport_rect().size)

	_transition_direction = TransitionDirection.FADE_OUT
	_room_path = next_room_path


func scene_fade_in():
	transition_rect.material.set_shader_parameter("circle_position", 
		scene_player.global_position / get_viewport_rect().size)
		
	_transition_direction = TransitionDirection.FADE_IN


func do_transition():
	var new_scene = load(_room_path).instantiate()
	
	$Scene.remove_child(scene)
	$Scene.add_child(new_scene)
	
	var new_player: Player = new_scene.get_node(^"TileMap/Player")
	
	if not _reset:
		reset_properties.set_properties(scene_player.transmutable_properties)
		
	else:
		_reset = false
		
	new_player.transmutable_properties.set_properties(reset_properties)
	
	scene.queue_free()
	
	scene = new_scene
	scene_door =  scene.get_node(^"TileMap/Door")
	scene_player = new_player
	
	scene_door.entered.connect(scene_fade_out)
	scene_player.on_winning.connect(_on_player_winning)


func _on_player_winning():
	_to_winning_scene = true
	scene_fade_out("res://scenes/winning_scene.tscn")
