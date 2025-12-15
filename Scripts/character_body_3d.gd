extends CharacterBody3D

#region Physics Vars
@export_category("Glide && Move Physics")
@export_range(0,20) var speed = 5
@export_range(0,20) var jump_velocity = 4
@export_range(0,20) var glide_amount = 2
@export_range(-6,0) var gravity_clamp = -6
#endregion

var gliding

func _physics_process(delta):
	#region Gravity Scale
	# Add the gravity if player isn't gliding.
	if not is_on_floor() and not gliding:
		velocity += get_gravity()* delta
	elif not is_on_floor() and gliding: #gravity if player is gliding. 
		velocity += get_gravity()/glide_amount * delta
		#clamp so that the gravity doesn't build too much while gliding
		var newVelocity = clamp(velocity.y, gravity_clamp, jump_velocity)
		velocity.y = newVelocity
	# Handle jump.
	if Input.is_action_just_pressed("Glide") and is_on_floor():
		velocity.y = jump_velocity
	#trigger glide on double jump basically
	if Input.is_action_pressed("Glide") and not is_on_floor():
		gliding = true
	else:
		gliding = false
	#endregion
	
	#region WASD movement
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	#endregion
