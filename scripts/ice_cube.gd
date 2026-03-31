extends RigidBody3D

class_name IceCube

var script_enabled = true

var front_dir = Vector3.ZERO

var force = Vector3.ZERO
var jump_force = Vector3.ZERO
var aforce = Vector3.ZERO

var jump_charge

@onready var particles: GPUParticles3D = $Tears
@onready var cube: MeshInstance3D = $Cube
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var camera: Camera3D = $Camera3D
@onready var ray_up: RayCast3D = $RayCast_Up
@onready var ray_down: RayCast3D = $RayCast_Down
@onready var ray_front: RayCast3D = $RayCast_Front
@onready var ray_back: RayCast3D = $RayCast_Back
@onready var ray_right: RayCast3D = $RayCast_Right
@onready var ray_left: RayCast3D = $RayCast_Left

@onready var bottom_raycast: RayCast3D = ray_down

func _ready() -> void:
	continuous_cd = true
	gravity_scale = 5.0
	


func _process(delta: float) -> void:
	if script_enabled == false:
		return
		
	force = Vector3.ZERO
	var dir = Vector3.ZERO
	
	
	front_dir = -camera.global_transform.basis.z
	front_dir.y = 0
	front_dir = front_dir.normalized()

	var floor_face = get_lowest_face()
	match floor_face:
		"up":
			bottom_raycast = ray_up
		"down":
			bottom_raycast = ray_down
		"front":
			bottom_raycast = ray_front
		"back":
			bottom_raycast = ray_back
		"right":
			bottom_raycast = ray_right
		"left":
			bottom_raycast = ray_left
		
	if bottom_raycast == null or not bottom_raycast.is_colliding():
		particles.emitting = false
		return
	else:
		particles.emitting = true
	
	if Input.is_action_just_pressed("jump"):
		jump_charge = 0
		return
	if Input.is_action_pressed("jump"):
		jump_charge += delta
		return
		
	if Input.is_action_pressed("go_forward"):
		dir += front_dir
	if Input.is_action_pressed("go_back"):
		dir -= front_dir
	if Input.is_action_pressed("go_right"):
		dir += front_dir.rotated(Vector3.UP, -PI/2)
	if Input.is_action_pressed("go_left"):
		dir += front_dir.rotated(Vector3.UP, PI/2)
	
	dir = dir.normalized()
	
	if Input.is_action_just_released("jump"):
		jump_force = jump(min(jump_charge,0.5), dir)*150
		aforce = dir_to_aforce(dir)
		jump_charge = 0
		return

	force = dir*10


func _physics_process(delta: float) -> void:
	if force.length() > 0.0:
		apply_central_force(force*2000)
	
	if jump_force.length() > 0.0:
		apply_central_impulse(jump_force*100)
		apply_torque_impulse(aforce*2000)
		jump_force = Vector3.ZERO
		aforce = Vector3.ZERO

func get_lowest_face() -> String:
	var down = -Vector3.UP  # światowy dół

	var directions = {
		"up": transform.basis.y,
		"down": -transform.basis.y,
		"left": -transform.basis.x,
		"right": transform.basis.x,
		"front": -transform.basis.z,
		"back": transform.basis.z
	}

	var lowest_face = "none"
	var max_dot = -2.0

	for face in directions.keys():
		var dot_val = directions[face].dot(down)
		if dot_val > max_dot:
			max_dot = dot_val
			lowest_face = face

	return lowest_face
	
func jump(charge, dir):
	force = Vector3.UP * charge * 5 + dir
	return force

func dir_to_aforce(dir):
	if dir.length() == 0:
		return Vector3.ZERO
	else:
		return -dir.cross(Vector3.UP).normalized()


func game_over():
	particles.emitting = false
	cube.visible = false
	script_enabled = false
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/lose.tscn")
	
func win():
	script_enabled = false
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/end.tscn")
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		win()
