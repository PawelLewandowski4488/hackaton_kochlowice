extends Camera3D

@export var target: RigidBody3D  # kostka, czyli rodzic
@export var distance := 10.0
@export var mouse_sensitivity := 0.002
@export var min_pitch := deg_to_rad(-30)
@export var max_pitch := deg_to_rad(60)



var yaw := 0.0
var pitch := 0.0

func _ready():
	target = get_parent()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	look_at(target.global_transform.origin, Vector3.UP)

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch += event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, min_pitch, max_pitch)
		
	if event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://main_menu.tscn")
		
func _process(delta):
	
	# Oblicz offset kamery względem target
	var offset = Vector3(
		distance * sin(yaw) * cos(pitch),
		distance * sin(pitch),
		distance * cos(yaw) * cos(pitch)
	)
	
	# Ustaw pozycję kamery
	global_transform.origin = target.global_transform.origin + offset
	
	# Kamera patrzy na target
	look_at(target.global_transform.origin, Vector3.UP)
