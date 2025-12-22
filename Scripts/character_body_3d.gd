extends CharacterBody3D

#region Physics Vars
@export_category("Glide && Move Physics")
@export_range(0,20) var speed = 5
@export_range(0,20) var jump_velocity = 4
@export_range(-6,0) var gravity_clamp = -3
#endregion

#region Movement Vars
@onready var wall_check = $GeneralSkeleton/raycasts/wall_check #check if character is on the wall
@onready var still_wall = $GeneralSkeleton/raycasts/still_wall #check if only the bottom of the character is on the wall or ready to jump over ledge

@export_range(0, 20) var climb_speed = 5;

var move = true
var climb = false
#endregion

#region Animation Vars
@onready var anim_tree = $AnimationTree
var run_blend_number = 0
var jump_blend_number = 0
#endregion

@onready var camera = %Camera3D
@onready var visuals = %GeneralSkeleton

func _update_blend_tree():
	#clamping the blends for animation so it doesn't get crazy
	run_blend_number = clamp(run_blend_number, 0,1)
	jump_blend_number = clamp(jump_blend_number, 0,1)
	
	anim_tree["parameters/Run/blend_amount"] = run_blend_number
	anim_tree["parameters/Jump/blend_amount"] = jump_blend_number

func _process(delta):
	_update_blend_tree()
	
	
func _physics_process(delta):
	climbing()
	
	#region Gravity Scale
	if !climb: #add gravity if player isn't climbing
		# Add the gravity if player isn't gliding
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
	
	if climb:
		velocity = Vector3.ZERO
		direction = Vector3.ZERO
		
		var rot = -(atan2(wall_check.get_collision_normal().z, wall_check.get_collision_normal().x) - PI /2)
		direction.x = input_dir.x
		direction.y = input_dir.y
		direction = Vector3(direction.x, direction.y, 0).rotated(Vector3.UP, rot).normalized()
		
		velocity.x = -direction.x * climb_speed
		velocity.z = -direction.z * climb_speed
		velocity.y = -direction.y * climb_speed
	else:
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
			
			
	#rotate character with camera
	if velocity.length() > 0.2 and !climb:
		var look_direction = Vector2(velocity.z, velocity.x)
		visuals.rotation.y = look_direction.angle()
	elif velocity.length() > 0.2 and climb:
		visuals.rotation.y = -(atan2(wall_check.get_collision_normal().z, wall_check.get_collision_normal().x) - PI /2)
	
	move_and_slide()
	#endregion

#check if wall is climbable
func climbing():
	if wall_check.is_colliding():
		if still_wall.is_colliding():
			climb = true
		else:
			velocity.y = jump_velocity
			climb = false
	else:
		climb = false
