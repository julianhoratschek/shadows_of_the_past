extends Area2D


@onready var _initial_position := position
@onready var _target_position := position
@onready var timer: Timer = $Timer

var _distance := 50
var speed := 20

func _ready():
	_set_target_position()

func _physics_process(delta):
	if not timer.is_stopped():
		return

	if position.distance_squared_to(_target_position) <= 4:
		timer.start(randf_range(0.5, 2.0))

	position = position.move_toward(_target_position, speed * delta)


func _set_target_position():
	_target_position = _initial_position + (Vector2(1, 0).rotated(randf_range(0, 2 * PI)) * _distance)


func _on_body_entered(body):
	if body is Player:
		body.on_winning.emit()

