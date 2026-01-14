extends Node3D

var move_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	move_mode = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if event.is_action_pressed("alt"):
		move_mode = !move_mode
		if move_mode:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	pass
