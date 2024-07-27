extends PathFollow2D

const delta_progress := 120.0

const start_moving_frame := 3
const stop_moving_frame := 5

@onready var sprite := $StaticBody2D/TransmutableProperties/AnimatedSprite2D

func _process(delta: float):
	if start_moving_frame <= sprite.frame and sprite.frame <= stop_moving_frame:
		progress += delta_progress * delta

