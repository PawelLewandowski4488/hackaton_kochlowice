extends Node3D

@export var speed: float = 10.0       
@export var sensitivity: float = 0.2   

var yaw: float = 0.0
var pitch: float = 0.0

func _ready():
	pass

func _input(event):
	if owner.move_mode == false:
		return
	
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, -90, 90)
		rotation_degrees = Vector3(pitch, yaw, 0)

	if event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _process(delta):
	if owner.move_mode == false:
		return
	
	var dir = Vector3.ZERO

	if Input.is_action_pressed("go_forward"): dir -= transform.basis.z
	if Input.is_action_pressed("go_back"):    dir += transform.basis.z
	if Input.is_action_pressed("go_left"):    dir -= transform.basis.x
	if Input.is_action_pressed("go_right"):   dir += transform.basis.x
	if Input.is_action_pressed("jump"):       dir += transform.basis.y
	if Input.is_action_pressed("go_down"):    dir -= transform.basis.y

	dir = dir.normalized()
	if dir != Vector3.ZERO:
		global_translate(dir * speed * delta)
