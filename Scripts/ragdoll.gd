extends Skeleton3D
@export var boneNames = ["LeftLowerArm"]

# Called when the node enters the scene tree for the first time.
func _ready():
	$PhysicalBoneSimulator3D.physical_bones_start_simulation(boneNames)
