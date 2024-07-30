extends Area2D

var _audio_streams := [
	preload("res://assets/sfx/sad_shadow_01.wav"),
	preload("res://assets/sfx/sad_shadow_02.wav"),
	preload("res://assets/sfx/sad_shadow_03.wav"),
	preload("res://assets/sfx/sad_shadow_04.wav"),
	preload("res://assets/sfx/sad_shadow_05.wav"),
	preload("res://assets/sfx/sad_shadow_06.wav"),
	preload("res://assets/sfx/sad_shadow_07.wav"),
	preload("res://assets/sfx/sad_shadow_08.wav"),
	preload("res://assets/sfx/sad_shadow_09.wav"),
	preload("res://assets/sfx/sad_shadow_10.wav")]

@onready var _initial_position := position
@onready var _target_position := position
@onready var move_timer: Timer = $MovementTimer
@onready var audio_timer: Timer = $AudioTimer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var _distance := 50
var speed := 20

func _ready():
	_set_target_position()

func _process(delta):
	if not move_timer.is_stopped():
		return

	if position.distance_squared_to(_target_position) <= 4:
		move_timer.start(randf_range(0.5, 2.0))

	position = position.move_toward(_target_position, speed * delta)


func _set_target_position():
	_target_position = _initial_position + (Vector2(1, 0).rotated(randf_range(0, 2 * PI)) * _distance)


func _set_audio_file():
	audio.stream = _audio_streams.pick_random()
	audio.play()

func _on_body_entered(body):
	if body is Player:
		body.on_winning.emit()

func _on_audio_stream_player_2d_finished():
	audio_timer.start(randf_range(0.8, 2.4))
