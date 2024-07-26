extends CharacterBody2D

var speed := 90.0

func _input(event):
	if Input.is_action_just_pressed("gme_interact"):
		get_tree().call_group(&"transmutation_circles", &"start_transmutation")
	elif Input.is_action_just_released("gme_interact"):
		get_tree().call_group(&"transmutation_circles", &"abort_transmutation")

func _physics_process(delta):
	var direction := Input.get_vector("gme_left", "gme_right", "gme_up", "gme_down")
	
	velocity = direction * speed
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider()
		
		if body is RigidBody2D:
			if body.mass > 1.0:
				return
			body.apply_central_impulse(collision.get_normal() * -50)
