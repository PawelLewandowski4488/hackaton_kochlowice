extends Node



@onready var ice_cube = $IceCube
@onready var ice_cube_camera = $IceCube/Camera3D
@onready var col_up = $Room/CollisionShape_Up
@onready var col_right = $Room/CollisionShape_Right
@onready var col_front = $Room/CollisionShape_Front
@onready var mesh = $Room/MeshInstance3D
@onready var light = $Room/OmniLight3D

func _ready():
	load_level_from_json(GlobalData.MAPS_DIR + "test.json");
	
func update_level_size():
	col_right.position.x = GlobalData.level_size[0]
	col_up.position.y = GlobalData.level_size[1]
	col_front.position.z = GlobalData.level_size[2]
	mesh.position = GlobalData.level_size / 2
	mesh.mesh.size = GlobalData.level_size
	light.position = GlobalData.level_size / 2
	light.omni_range = max(GlobalData.level_size[0], GlobalData.level_size[1], GlobalData.level_size[2])
	

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
	
	for obj_data in data["objects"]:
		var type = obj_data["type"] 
		
		if type == 'start_position':
			var pos = obj_data["pos"]
			var rot = obj_data["rot"]
			ice_cube.global_position = Vector3(pos.x, pos.y, pos.z)
			ice_cube.global_rotation_degrees = Vector3(rot.x, rot.y, rot.z)
		else:
			var full_path = GlobalData.OBJ_DIR + type + ".tscn"
			var scene = load(full_path)
			
			if scene:
				var instance = scene.instantiate()
				
				#instance.set_meta("object_id", type)
				#instance.add_to_group("built_objects")
				add_child(instance)
				
				var pos = obj_data["pos"]
				var rot = obj_data["rot"]
				var scl = obj_data["scale"]
				
				instance.global_position = Vector3(pos.x, pos.y, pos.z)
				instance.global_rotation_degrees = Vector3(rot.x, rot.y, rot.z)
				instance.scale = Vector3(scl.x, scl.y, scl.z)
			else:
				print("Nie udało się załadować sceny: ", full_path)
	ice_cube_camera.activate()
