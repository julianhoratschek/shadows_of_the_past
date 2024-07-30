extends Node2D


## Which direction does our transition go
enum TransitionDirection {
	NONE = 0,
	FADE_OUT = -1,
	FADE_IN = 1
}

var _background_music_accents := [
	preload("res://assets/music/shadows_of_the_past_music_02_01.wav"),
	preload("res://assets/music/shadows_of_the_past_music_02_02.wav"),
	preload("res://assets/music/shadows_of_the_past_music_02_03.wav"),
	preload("res://assets/music/shadows_of_the_past_music_02_04.wav"),
	preload("res://assets/music/shadows_of_the_past_music_02_05.wav")]

## Current direction of the transition
var _transition_direction := TransitionDirection.NONE

## How big is our circle?
var _transition_size := 1.5
var _transition_phi := 0.0

## How much do we count to our circle per frame?
# var _transition_size_change := 1.2
var _transition_size_change := 1.2
var _transition_phi_change := 8


## Path to packed scene with next room
var _room_path := "res://scenes/shape_change_scene.tscn"

## Indicates reset rather than loading of new scene
var _reset := false

## Indicates loading of winning scene
var _to_winning_scene := false


@onready var scene := $Scene.get_child(0)
@onready var scene_door: Door =  scene.get_node(^"TileMap/Door")
@onready var scene_player: Player = scene.get_node(^"TileMap/Player")
@onready var transition_rect := $ColorRect
@onready var reset_properties := $ResetProperties


## Fade first scene in and connect door signal
func _ready():
	scene_fade_in()
	scene_door.entered.connect(scene_fade_out)


## Catches reset request
func _input(event):
	# TODO: loading indicator
	if not _reset and Input.is_action_just_pressed(&"gme_reset_room"):
		_reset = true
		scene_fade_out(_room_path)


## Handles transition animation
func _process(delta):
	# Don't do anything if there is no transition
	if _transition_direction == TransitionDirection.NONE:
		return
	
	# Adjust circle size int the correct direction
	#_transition_size += delta * _transition_size_change * _transition_direction
	#transition_rect.material.set_shader_parameter("circle_size", _transition_size)
	_transition_size += delta * _transition_size_change * _transition_direction
	_transition_phi += delta * _transition_phi_change * _transition_direction
	transition_rect.material.set_shader_parameter("a", _transition_size)
	transition_rect.material.set_shader_parameter("phi", _transition_phi)
	
	# Test if we are done with fading out
	if (_transition_direction == TransitionDirection.FADE_OUT and _transition_size <= 0.0):
		
		# Unload this scene for winning scene
		if _to_winning_scene:
			get_tree().change_scene_to_file(_room_path)
		
		# Or transit to requested scene and fade back an
		else:
			do_transition()
			scene_fade_in()
	
	# If we are not fading out we must be fading in. Test if we are done.
	elif _transition_direction == TransitionDirection.FADE_IN and _transition_size >= 1.5:
		_transition_direction = TransitionDirection.NONE


## Start fading out targeting the scene door
func scene_fade_out(next_room_path: String):
	# Start shader
	#transition_rect.material.set_shader_parameter("circle_position", 
	#	scene_door.global_position / get_viewport_rect().size)
	
	transition_rect.material.set_shader_parameter("rect_center", 
		scene_door.global_position / get_viewport_rect().size)

	# Set out transition request
	_transition_direction = TransitionDirection.FADE_OUT
	
	# Set next room path
	_room_path = next_room_path


## Starg fading in from the player instance
func scene_fade_in():
	# Start shader
	transition_rect.material.set_shader_parameter("circle_position", 
		scene_player.global_position / get_viewport_rect().size)
	
	# Start fading request
	_transition_direction = TransitionDirection.FADE_IN


## Actually change current (sub-)scene and setup all parameters
func do_transition():
	# Load and isntantiate scene
	var new_scene = load(_room_path).instantiate()
	
	# Hold current scene in memory, but not in the tree
	$Scene.remove_child(scene)
	
	# Setup new scene
	$Scene.add_child(new_scene)
	
	# Load data into new player
	var new_player: Player = new_scene.get_node(^"TileMap/Player")
	
	# Load properties into reset-buffer
	if not _reset:
		reset_properties.set_properties(scene_player.transmutable_properties)
	
	# Reset is only good for one reload request, will be reset on new request
	else:
		_reset = false
	
	# Set new player data
	new_player.transmutable_properties.set_properties(reset_properties)
	
	# Now we don't need the old scene anymore
	scene.queue_free()
	
	# Re-set local variables
	scene = new_scene
	scene_door =  scene.get_node(^"TileMap/Door")
	scene_player = new_player
	
	# Re-connect important signals
	scene_door.entered.connect(scene_fade_out)
	scene_player.on_winning.connect(_on_player_winning)


## Special case: Player has met winning condition
func _on_player_winning():
	_to_winning_scene = true
	scene_fade_out("res://scenes/winning_scene.tscn")


func _on_background_music_finished():
	$BackgroundMusic.play()

func _play_background_accent():
	$BackgroundMusicAccents.stream = _background_music_accents.pick_random()
	$BackgroundMusicAccents.play()
	await $BackgroundMusicAccents.finished
	$BackgroundAccentsTimer.start(randf_range(7.5, 15.7))
