extends RigidBody2D


func desintegrate():
	for child in get_children():
		if child is TransmutableProperties:
			await child.desintegrate()
			queue_free()
			break
