extends Node3D

@onready var camera = $Camera3D
@onready var speed_bar = owner.get_node("HUD/Middle_control/ProgressBar")
	  
@export var sensitivity: float = 0.2   

var speed: float = 2.0  
const MIN_SPEED = 0.5 
const MAX_SPEED = 50.0  
const SPEED_STEP = 1.2  

var yaw: float = 0.0
var pitch: float = 0.0

func _ready():
	yaw = rotation_degrees.y
	pitch = rotation_degrees.x
	update_speed_ui()

func _input(event):
	if owner.move_mode == false:
		return
	
	if event.is_action_pressed("scroll_up"):
		speed *= SPEED_STEP
		speed = clamp(speed, MIN_SPEED, MAX_SPEED)
		update_speed_ui()
		
	if event.is_action_pressed("scroll_down"):
		speed /= SPEED_STEP
		speed = clamp(speed, MIN_SPEED, MAX_SPEED)
		update_speed_ui()
	
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
	if Input.is_action_pressed("jump"):       dir += Vector3.UP
	if Input.is_action_pressed("go_down"):    dir -= Vector3.UP

	dir = dir.normalized()
	if dir != Vector3.ZERO:
		global_translate(dir * speed * delta)

func update_speed_ui():
	if speed_bar:
		speed_bar.value = speed*2
