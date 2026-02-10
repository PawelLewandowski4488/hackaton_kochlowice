extends CanvasLayer

signal object_selected_to_spawn(object_id)

@onready var item_list = $Control2/Object_List

# Called when the node enters the scene tree for the first time.
func _ready():
	item_list.item_selected.connect(_on_item_list_selected)
	fill_item_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		"objects": []
	}
	
	var objects = get_tree().get_nodes_in_group("built_objects")
	
	if objects.is_empty():
		print("Brak obiektów do zapisu.")
		return

	for obj in objects:
		if obj is Node3D:
			var object_type = obj.get_meta("object_id")
			
			var object_data = {
				"type": object_type,
				"pos": {"x": obj.global_position.x, "y": obj.global_position.y, "z": obj.global_position.z},
				"rot": {"x": obj.global_rotation_degrees.x, "y": obj.global_rotation_degrees.y, "z": obj.global_rotation_degrees.z},
				"scale": {"x": obj.scale.x, "y": obj.scale.y, "z": obj.scale.z}
			}
			save_data["objects"].append(object_data)

	var json_string = JSON.stringify(save_data, "\t")
	
	var file_path = "res://maps/" + GlobalData.current_level_name
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		file.close()
		print("SUKCES: Zapisano plik w: ", file_path)
	else:
		var err = FileAccess.get_open_error()
		print("BŁĄD ZAPISU (Kod: ", err, "). Upewnij się, że folder res://maps/ istnieje!")


func _on_delete_button_pressed():
	var objects = get_tree().get_nodes_in_group("built_objects")
	for obj in objects:
		obj.queue_free()
