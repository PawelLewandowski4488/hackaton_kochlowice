extends CanvasLayer

signal object_selected_to_spawn(object_id)

@onready var item_list = $Left_Control/Object_List
@onready var camera = $"../Camera_Pivot/Camera3D"
@onready var object_properties = $Right_Control/VBoxContainer/Object_Properties

func _ready():
	item_list.item_selected.connect(_on_item_list_selected)
	fill_item_list()

func _process(delta):
	pass
	
func fill_item_list():
	item_list.fixed_icon_size = Vector2i(64, 64)
	item_list.clear()
	
	var path = "res://scenes/objects/" 
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".tscn"):
				var clean_name = file_name.replace(".tscn", "")
				
				var icon_path = path + clean_name + ".png"
				var icon_texture = null
				
				if FileAccess.file_exists(icon_path):
					icon_texture = load(icon_path)
				
				var idx = item_list.add_item(clean_name, icon_texture)
				item_list.set_item_metadata(idx, clean_name)
			
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Błąd: Nie można otworzyć folderu: ", path)

func _on_item_list_selected(index):
	var id = item_list.get_item_metadata(index)
	object_selected_to_spawn.emit(id) 
	item_list.deselect_all()


func _on_write_button_pressed():
	var save_data = {
		"level_name": GlobalData.current_level_name,
		"date_created": Time.get_datetime_string_from_system(),
		"level_size": { # Dodane
			"x": GlobalData.level_size.x,
			"y": GlobalData.level_size.y,
			"z": GlobalData.level_size.z
		},
		"objects": []
	}
	
	var objects = get_tree().get_nodes_in_group("built_objects")
	
	if objects.is_empty():
		print("Brak obiektów do zapisu.")
		return

	for obj in objects:
		if obj is Node3D:
			var object_type = obj.get_meta("object_id")
			
			# Pobieramy czystą rotację bez zniekształceń skali
			var pure_basis = obj.global_transform.basis.orthonormalized()
			var pure_rot_rad = pure_basis.get_euler()
			
			var object_data = {
				"type": object_type,
				"pos": {
					"x": snappedf(obj.global_position.x, 0.01), 
					"y": snappedf(obj.global_position.y, 0.01), 
					"z": snappedf(obj.global_position.z, 0.01)
				},
				"rot": {
					"x": snappedf(rad_to_deg(pure_rot_rad.x), 0.01), 
					"y": snappedf(rad_to_deg(pure_rot_rad.y), 0.01), 
					"z": snappedf(rad_to_deg(pure_rot_rad.z), 0.01)
				},
				"scale": {
					"x": snappedf(obj.scale.x, 0.01), 
					"y": snappedf(obj.scale.y, 0.01), 
					"z": snappedf(obj.scale.z, 0.01)
				}
			}
			save_data["objects"].append(object_data)

	var json_string = JSON.stringify(save_data, "\t")
	
	var file_path = "user://maps/" + GlobalData.current_level_name + ".json"
	
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("maps"):
		dir.make_dir("maps")
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		file.close()
		print("SUKCES: Zapisano plik w: ", file_path)
	else:
		var err = FileAccess.get_open_error()
		print("BŁĄD ZAPISU (Kod: ", err, ")")


func _on_delete_button_pressed():
	var objects = get_tree().get_nodes_in_group("built_objects")
	for obj in objects:
		obj.queue_free()


func _on_middle_control_gui_input(event): #kliknięcie w obiekt zaznaczenie
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Kliknięto w obszar kamery!")
			shoot_ray()
			
func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_length = 2000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_node = result.collider
		print(hit_node)
		var target = null
		
		# Sprawdzanie czy obiekt lub jego rodzic należy do grupy build_objects
		if hit_node.is_in_group("built_objects"):
			target = hit_node
		elif hit_node.get_parent().is_in_group("built_objects"):
			target = hit_node.get_parent()
		
		if target:
			object_properties.select_object(target)
		else:
			print("Obiekt nie należy do grupy build_objects")
	else:
		print("Nic nie trafiono")


func _on_level_size_text_submitted(new_text: String, extra_arg_0: String) -> void:
	var axis_map = {"x": 0, "y": 1, "z": 2}
	
	if extra_arg_0 in axis_map and new_text.is_valid_int():
		GlobalData.level_size[axis_map[extra_arg_0]] = int(new_text)
		get_viewport().gui_release_focus()
		get_parent().update_level_size()
