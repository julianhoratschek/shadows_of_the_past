extends PathFollow2D

const delta_progress := 120.0

const shape_moving_frames := {
	TransmutableProperties.TransShape.GUARD: [3, 5],
	TransmutableProperties.TransShape.FISH: [0, 2],
}

@onready var sprite := $StaticBody2D/TransmutableProperties/AnimatedSprite2D
@onready var transmutable_properties := $StaticBody2D/TransmutableProperties

func _process(delta: float):
	if not is_instance_valid(transmutable_properties):
		queue_free()
		return
		
	if (transmutable_properties.transmute_shape in shape_moving_frames):
		var frames: Array = shape_moving_frames[transmutable_properties.transmute_shape]
		if frames[0] <= sprite.frame and sprite.frame <= frames[1]:
			progress += delta_progress * delta
			

