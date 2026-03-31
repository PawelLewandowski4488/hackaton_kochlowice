extends Area3D

var active = false

func _ready() -> void:
	active = false


func _process(delta: float) -> void:
	pass
	
func activate():
	active = true


func _on_body_entered(body: Node3D) -> void:
	if body is IceCube:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
