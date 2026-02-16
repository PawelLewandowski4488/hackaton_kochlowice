extends PanelContainer

@onready var object_name = $VBoxContainer/Object_Name

@onready var pos_x = $VBoxContainer/Position_Container/Position_X
@onready var pos_y = $VBoxContainer/Position_Container/Position_Y
@onready var pos_z = $VBoxContainer/Position_Container/Position_Z

@onready var rot_x = $VBoxContainer/Rotation_Container/Rotation_X
@onready var rot_y = $VBoxContainer/Rotation_Container/Rotation_Y
@onready var rot_z = $VBoxContainer/Rotation_Container/Rotation_Z

@onready var sca_x = $VBoxContainer/Scale_Container/Scale_X
@onready var sca_y = $VBoxContainer/Scale_Container/Scale_Y
@onready var sca_z = $VBoxContainer/Scale_Container/Scale_Z

var selected_object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func select_object(object):
	selected_object = object
	
	object_name.text = str(selected_object.get_meta("object_id"))
	# Pozycja
	pos_x.text = str(selected_object.global_position.x)
	pos_y.text = str(selected_object.global_position.y)
	pos_z.text = str(selected_object.global_position.z)
	
	# Rotacja
	rot_x.text = str(selected_object.rotation_degrees.x)
	rot_y.text = str(selected_object.rotation_degrees.y)
	rot_z.text = str(selected_object.rotation_degrees.z)
	
	# Skala
	sca_x.text = str(selected_object.scale.x)
	sca_y.text = str(selected_object.scale.y)
	sca_z.text = str(selected_object.scale.z)
	
	visible = true


func _on_hide_pressed():
	selected_object = null
	visible = false
	
	object_name = ''
	
	pos_x.text = ''
	pos_y.text = ''
	pos_z.text = ''
	
	rot_x.text = ''
	rot_y.text = ''
	rot_z.text = ''
	
	sca_x.text = ''
	sca_y.text = ''
	sca_z.text = ''


func _on_delete_object_pressed():
	selected_object.queue_free()
	_on_hide_pressed()


func _on_value_submitted(new_text, extra_arg_0):
	if not selected_object or not is_instance_valid(selected_object):
		return
	
	if not new_text.is_valid_float():
		select_object(selected_object) 
		return

	var val = snappedf(float(new_text), 0.01)
	
	match extra_arg_0:
		"pos_x": selected_object.global_position.x = val
		"pos_y": selected_object.global_position.y = val
		"pos_z": selected_object.global_position.z = val
		
		"rot_x": selected_object.rotation_degrees.x = val
		"rot_y": selected_object.rotation_degrees.y = val
		"rot_z": selected_object.rotation_degrees.z = val
		
		"sca_x": selected_object.scale.x = val
		"sca_y": selected_object.scale.y = val
		"sca_z": selected_object.scale.z = val

	select_object(selected_object)
