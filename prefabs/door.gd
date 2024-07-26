extends Area2D


func open():
	$AnimatedSprite2D.play(&"open")
	$StaticBody2D.process_mode = Node.PROCESS_MODE_DISABLED

func close():
	$AnimatedSprite2D.play_backwards(&"open")
	$StaticBody2D.process_mode = Node.PROCESS_MODE_INHERIT
	

func _on_body_entered(body: Node2D):
	if body is Player:
		print("entered")
