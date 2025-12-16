extends Node

@export var outline_scale := 1.05
@export var outline_color := Color.BLACK

func _ready():
	add_outline_to_all(self)


func add_outline_to_all(root):
	for child in root.get_children():

		# POMIJAMY outline, żeby nie robić outline na outline
		if child.name == "Outline":
			continue

		# jeśli dziecko to MeshInstance3D → dodaj outline
		if child is MeshInstance3D:
			add_outline(child)

		# schodzimy niżej w drzewie (rekurencja)
		add_outline_to_all(child)


func add_outline(mesh_instance: MeshInstance3D):
	# jeśli już ma outline → nic nie rób
	if mesh_instance.has_node("Outline"):
		return

	var mesh := mesh_instance.mesh
	if mesh == null:
		return

	# tworzymy node na outline
	var outline = MeshInstance3D.new()
	outline.name = "Outline"
	outline.mesh = mesh

	# materiał konturu
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = outline_color
	mat.cull_mode = BaseMaterial3D.CULL_FRONT  # <--- KLUCZ DO KONTURU
	outline.material_override = mat

	# skalowanie konturu — delikatnie większe od obiektu
	outline.scale = Vector3.ONE * outline_scale

	# dodajemy jako dziecko mesh_instance
	mesh_instance.add_child(outline)

	# żeby outline był widoczny w drzewie sceny
	outline.owner = get_tree().current_scene
