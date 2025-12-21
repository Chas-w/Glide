extends CharacterBody3D

#region Physics Vars
@export_category("Glide && Move Physics")
@export_range(0,20) var speed = 5
@export_range(0,20) var jump_velocity = 4
@export_range(-6,0) var gravity_clamp = -3
#endregion

#region Animation Vars
@onready var anim_tree = $AnimationTree
var run_blend_number = 0
var jump_blend_number = 0
#endregion

@onready var camera = %Camera3D

func _update_blend_tree():
	#clamping the blends for animation so it doesn't get crazy
	run_blend_number = clamp(run_blend_number, 0,1)
	jump_blend_number = clamp(jump_blend_number, 0,1)
	
	anim_tree["parameters/Run/blend_amount"] = run_blend_number
	anim_tree["parameters/Jump/blend_amount"] = jump_blend_number

func _process(delta):
	_update_blend_tree()
	
	
func _physics_process(delta):
	#region Gravity Scale
	# Add the gravity if player isn't gliding.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("Glide") and is_on_floor():
		velocity.y = jump_velocity
	#endregion
	
	#region WASD movement
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	if direction:
		if (run_blend_number < 1):
			run_blend_number += .1
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if (run_blend_number > 0):
			run_blend_number -= .1
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	#endregion
