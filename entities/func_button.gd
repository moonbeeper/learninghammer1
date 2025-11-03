@tool
class_name func_button extends VMFEntityNode

func _entity_setup(_vmf_entity: VMFEntity) -> void:
	$body/mesh.mesh = create_mesh_from_convex_shape(get_entity_convex_shape())
	$body/collision.shape = get_entity_convex_shape();


func OnPressed(_param = null):
	trigger_output("OnPressed")
	
func OnDamaged(_param = null):
	trigger_output("OnDamaged")
	
func OnIn(_param = null):
	trigger_output("OnIn")
	
func OnOut(_param = null):
	trigger_output("OnOut");

func _interact(_param = null):
	print("Button interact")
	OnPressed()

# Pretty pretty shitty, but it works. thanks mr gpt for helping out a birb
func create_mesh_from_convex_shape(convex_shape: ConvexPolygonShape3D) -> ArrayMesh:
	var points = convex_shape.points
	
	if points.size() < 4:
		push_error("Not enough points to create a mesh")
		return null
	
	# Create arrays for the mesh
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	
	# Use Delaunay or simple face generation
	# For a simple convex hull, we need to triangulate the faces
	# This is a simplified approach - you might need a proper convex hull algorithm
	
	for point in points:
		vertices.append(point)
	
	# Generate triangles (this is simplified - real convex hull needs proper algorithm)
	# Using a basic fan triangulation from first point
	for i in range(1, points.size() - 1):
		indices.append(0)
		indices.append(i)
		indices.append(i + 1)
	
	# Create the ArrayMesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return mesh
