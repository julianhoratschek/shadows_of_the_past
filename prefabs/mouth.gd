@tool

extends Area2D

signal fed()


@export var expected_color := TransmutableProperties.TransColor.RED:
	get:
		return expected_color

	set(value):
		expected_color = value
		$TongueSprite.modulate = TransmutableProperties.ColorMap[value]


func _on_body_entered(body: Node2D):
	if body is Player:
		return
		
	for child in body.get_children():
		if (child is TransmutableProperties 
			and child.transmute_shape == TransmutableProperties.TransShape.FISH 
			and child.transmute_color == expected_color):
				body.queue_free()
				$AudioStreamPlayer2D.play()
				$TongueSprite.play(&"roll")
				await $TongueSprite.animation_finished
				$TongueSprite.hide()
				$AnimatedSprite2D.play(&"eat")


func _on_animation_finished():
	hide()
	fed.emit()
