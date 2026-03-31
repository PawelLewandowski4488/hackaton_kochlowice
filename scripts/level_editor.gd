extends Node3D

var move_mode

@onready var camera_pivot = $Camera_Pivot
@onready var camera = $Camera_Pivot/Camera3D
@onready var hud = $HUD
@onready var object_properties = $HUD/Right_Control/VBoxContainer/Object_Properties
@onready var col_up = $Room/CollisionShape_Up
@onready var col_right = $Room/CollisionShape_Right
@onready var col_front = $Room/CollisionShape_Front
@onready var mesh = $Room/MeshInstance3D
@onready var light = $OmniLight3D

var level_size: Vector3 = Vector3(10,20,30)

var selected_object = null

var is_holding: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if GlobalData.current_level_name != "":
		if GlobalData.should_load_existing:
			# Tutaj wywołaj swoją funkcję wczytywania
			load_level_from_json(GlobalData.MAPS_DIR + GlobalData.current_level_name + ".json")
		else:
			print("Rozpoczynanie nowego projektu: ", GlobalData.current_level_name)
	
	update_level_size()
	move_mode = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	object_properties.hold_mode_changed.connect(_on_hold_mode_changed)
	object_properties.ortho_mode_changed.connect(_on_ortho_mode_changed)
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
	if is_holding:
		var obj = object_properties.selected_object
		if obj and is_instance_valid(obj):
			obj.global_position = camera_pivot.global_position

func _on_hold_mode_changed(toggled_on: bool):
	is_holding = toggled_on
	var obj = object_properties.selected_object
	
	if not obj or not is_instance_valid(obj): 
		is_holding = false
		return

	if is_holding:
		# --- WEJŚCIE W TRYB HOLD ---
		# 1. Pivot skacze do obiektu
		camera_pivot.global_position = obj.global_position
		# 2. Kamera odsuwa się, żebyśmy widzieli co trzymamy (np. 5m)
		camera.position = Vector3(0, 0, 5.0)
		camera.look_at(obj.global_position)
	else:
		# --- WYJŚCIE Z TRYBU HOLD ---
		# Pivot zostaje tam, gdzie była fizycznie kamera
		var current_cam_pos = camera.global_position
		camera_pivot.global_position = current_cam_pos
		# Kamera wraca do środka (0,0,0) względem Pivota
		camera.position = Vector3.ZERO

func _on_ortho_mode_changed(toggled_on: bool):
	if toggled_on and is_holding:
		camera.position = Vector3.ZERO
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 10.0
		# Opcjonalnie możesz tu ustawić domyślny rozmiar (zoom), 
		# bo domyślnie może być za mały/za duży:
		# camera.size = 10.0
	else:
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		camera.position = Vector3(0, 0, 5.0)

func update_level_size():
	col_right.position.x = GlobalData.level_size[0]
	col_up.position.y = GlobalData.level_size[1]
	col_front.position.z = GlobalData.level_size[2]
	mesh.position = GlobalData.level_size / 2
	mesh.mesh.size = GlobalData.level_size
	light.position = GlobalData.level_size / 2
	light.omni_range = max(GlobalData.level_size[0], GlobalData.level_size[1], GlobalData.level_size[2])

func _create_object(id: String):
	var unique_ids = ["start_position", "goal"] 
	
	if id in unique_ids:
		for existing_obj in get_tree().get_nodes_in_group("built_objects"):
			if existing_obj.get_meta("object_id") == id:
				print("Obiekt ", id, " już istnieje! Nie można stworzyć drugiego.")
				object_properties.select_object(existing_obj)
				return 
	var full_path = GlobalData.OBJ_DIR + id + ".tscn"
	var object_scene = load(full_path)
	
	if object_scene:
		var instance = object_scene.instantiate()
		instance.set_meta("object_id", id)
		instance.add_to_group("built_objects")
		add_child(instance)
		
		if camera_pivot:
			var spawn_pos = camera_pivot.global_position - camera_pivot.global_transform.basis.z * 5
			instance.global_position = spawn_pos
		object_properties.select_object(instance)


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
	
	if data.has("level_size"):
		var sz = data["level_size"]
		GlobalData.level_size = Vector3i(sz.x, sz.y, sz.z)
		update_level_size()
	
	var loaded_scenes = {}
	for obj_data in data["objects"]:
		var type = obj_data["type"]
		if not loaded_scenes.has(type):
			loaded_scenes[type] = load(GlobalData.OBJ_DIR + type + ".tscn")
		var scene = loaded_scenes[type]
		
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
			print("Nie udało się załadować sceny: ", GlobalData.OBJ_DIR, type, ".tscn")
