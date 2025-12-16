extends RigidBody3D

var script_enabled = true

var bottom_raycast: RayCast3D = null
var front_dir = Vector3.ZERO

var force = Vector3.ZERO
var aforce = Vector3.ZERO

var jump_charge

var particles: GPUParticles3D
var particles_end: GPUParticles3D

var cube: MeshInstance3D

var collision_shape: CollisionShape3D

var camera: Camera3D

var ray_up: RayCast3D
var ray_down: RayCast3D
var ray_front: RayCast3D
var ray_back: RayCast3D
var ray_right: RayCast3D
var ray_left: RayCast3D

func _ready() -> void:
	particles = $GPUParticles3D
	particles_end = $GPUParticles3D_End
	cube = $Cube
	collision_shape = $CollisionShape3D
	camera = $Camera3D
	ray_up = $RayCast_Up
	ray_down = $RayCast_Down
	ray_front = $RayCast_Front
	ray_back = $RayCast_Back
	ray_right = $RayCast_Right
	ray_left = $RayCast_Left
	
	continuous_cd = true
	gravity_scale = 5.0
	


func _process(delta: float) -> void:
	if script_enabled == false:
		return
	force = Vector3.ZERO
	aforce = Vector3.ZERO
	var dir = Vector3.ZERO
	
	melt(delta)
	
	# kierunek przodu względem kamery
	front_dir = -camera.global_transform.basis.z
	front_dir.y = 0
	front_dir = front_dir.normalized()

	# --------- Która ściana jest dolna ---------
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
		force = jump(min(jump_charge,0.5), dir)*150
		aforce = dir_to_aforce(dir)
		jump_charge = 0
		return

	force = dir*10

func _physics_process(delta: float) -> void:
	if force.length() > 0:
		apply_central_force(force*10000)

	apply_torque_impulse(aforce*10000)


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

@export var melt_speed := 0.008
@export var start_distance := 15.0
var melt_progress := 1.0    # 1 = pełna kostka, 0 = stopiona

func melt(delta):
	melt_progress -= melt_speed * delta
	# zabezpieczenie, żeby nie spadło poniżej 0.1
	if melt_progress < 0.1:
		melt_progress = 0.1
	
	# --- LINEAR SCALING ---
	cube.scale = Vector3.ONE * melt_progress
	collision_shape.shape.size = Vector3.ONE * melt_progress * 2.0
	camera.distance = start_distance * melt_progress
	print(melt_progress)
	if melt_progress <= 0.1:
		game_over()
		
func game_over():
	particles.emitting = false
	particles_end.emitting = true
	cube.visible = false
	script_enabled = false
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://lose.tscn")
	
func win():
	script_enabled = false
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://end.tscn")
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		win()
