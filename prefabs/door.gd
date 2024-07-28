extends Area2D

class_name Door

signal entered(next_room_path: String)

var _is_open := false
var is_open: bool:
	get:
		return _is_open

@export_file var next_room

func open():
	if _is_open:
		return

	$AnimatedSprite2D.play(&"open")
	$StaticBody2D.process_mode = Node.PROCESS_MODE_DISABLED
	_is_open = true

func close():
	if not _is_open:
		return

	$AnimatedSprite2D.play_backwards(&"open")
	$StaticBody2D.process_mode = Node.PROCESS_MODE_INHERIT
	_is_open = false
	

func _on_body_entered(body: Node2D):
	if body is Player:
		var modulate_tween := body.create_tween()
		modulate_tween.tween_property(body, "modulate", Color(Color.BLACK, 0.0), 0.8)
		body.speed = 0.0
		entered.emit(next_room)
