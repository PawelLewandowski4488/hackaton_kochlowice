extends Node3D

var move_mode
var objects_path = "res://scenes/objects/"
@onready var camera = $Camera_Pivot/Camera3D
@onready var hud = $HUD
@onready var object_properties = $HUD/Right_Control/Object_Properties

var selected_object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if GlobalData.current_level_name != "":
		if GlobalData.should_load_existing:
			# Tutaj wywołaj swoją funkcję wczytywania
			load_level_from_json("res://maps/" + GlobalData.current_level_name)
		else:
			print("Rozpoczynanie nowego projektu: ", GlobalData.current_level_name)
	
	object_properties.camera = camera
	move_mode = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hud.object_selected_to_spawn.connect(_create_object)

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		GlobalData.current_level_name = ""
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/level_manager.tscn")
		
	if event.is_action_pressed("alt"):
		move_mode = !move_mode
		if move_mode:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	pass

func _create_object(id: String):
	var full_path = objects_path + id + ".tscn"
	var object_scene = load(full_path)
	
	if object_scene:
		var instance = object_scene.instantiate()
		instance.set_meta("object_id", id)
		instance.add_to_group("built_objects")
		add_child(instance)
		
		if camera:
			var spawn_pos = camera.global_position - camera.global_transform.basis.z * 3.0
			instance.global_position = spawn_pos


func load_level_from_json(path: String):
	if not FileAccess.file_exists(path):
		print("Błąd: Plik nie istnieje!")
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		print("Błąd parsowania JSON: ", json.get_error_message())
		return

	var data = json.data
	
	for obj_data in data["objects"]:
		var type = obj_data["type"] 
		
		var full_path = objects_path + type + ".tscn"
		var scene = load(full_path)
		
		if scene:
			var instance = scene.instantiate()
			
			instance.set_meta("object_id", type)
			instance.add_to_group("built_objects")
			add_child(instance)
			
			var pos = obj_data["pos"]
			var rot = obj_data["rot"]
			var scl = obj_data["scale"]
			
			instance.global_position = Vector3(pos.x, pos.y, pos.z)
			instance.global_rotation_degrees = Vector3(rot.x, rot.y, rot.z)
			instance.scale = Vector3(scl.x, scl.y, scl.z)
		else:
			print("Nie udało się załadować sceny: ", full_path)
