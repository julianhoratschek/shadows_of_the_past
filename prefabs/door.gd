extends Area2D

class_name Door

signal entered

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
		entered.emit()
