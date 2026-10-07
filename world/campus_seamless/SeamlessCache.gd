extends RefCounted
const PATH: String="res://world/campus_seamless/generated/CampusSeamlessBaked.scn"
const MANIFEST: String="res://world/campus_seamless/generated/manifest.json"
static func fingerprint() -> String:
	var paths: Array[String]=[]
	for name: String in DirAccess.get_files_at("res://world/campus_exterior"):
		if name.ends_with(".gd"):paths.append("res://world/campus_exterior/"+name)
	paths.append_array(["res://systems/data/campus_masterplan.json","res://systems/data/campus_paths.json","res://systems/data/building_architecture_profiles.json","res://systems/data/campus_exterior_environment_v4.json","res://systems/data/campus_terrain_grid_v4.json"])
	for name: String in DirAccess.get_files_at("res://world/campus_seamless"):
		if name.ends_with(".gd"):paths.append("res://world/campus_seamless/"+name)
	paths.append("res://systems/data/campus_interiors.json")
	paths.sort();var hashes: String=""
	for path: String in paths:hashes+=path+FileAccess.get_file_as_string(path).replace("\r\n","\n").sha256_text()
	return hashes.sha256_text()

static func valid() -> bool:
	if not FileAccess.file_exists(PATH) or not FileAccess.file_exists(MANIFEST):return false
	var m: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	if m.fingerprint!=fingerprint() or FileAccess.get_sha256(PATH)!=m.scene_sha256:return false
	for path: String in m.get("interiors",{}):
		if not FileAccess.file_exists(path) or FileAccess.get_sha256(path)!=m.interiors[path]:return false
	return m.get("interiors",{}).size()==10

static func own(node: Node,root: Node) -> void:
	for child: Node in node.get_children():child.owner=root;own(child,root)

static func save(world: Node3D) -> Error:
	DirAccess.make_dir_recursive_absolute("res://world/campus_seamless/generated")
	var root:=Node3D.new();root.name="BakedExterior"
	for name: String in ["Terrain","Regions","Buildings","Landmarks","CampusEnvironmentV3","ExteriorContext"]:
		var node: Node=world.get_node(name);world.remove_child(node);root.add_child(node)
	own(root,root)
	var packed:=PackedScene.new();var result:=packed.pack(root)
	if result==OK:result=ResourceSaver.save(packed,PATH,ResourceSaver.FLAG_COMPRESS)
	if result==OK:
		var interiors: Dictionary={}
		for d: Dictionary in JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_interiors.json")):
			var path: String="res://world/campus_seamless/generated/"+d.interior_id+".scn";interiors[path]=FileAccess.get_sha256(path)
		FileAccess.open(MANIFEST,FileAccess.WRITE).store_string(JSON.stringify({"interiors":interiors,"version":"V5","fingerprint":fingerprint(),"scene_sha256":FileAccess.get_sha256(PATH),"generated_by":"Godot authoring build; no original reference assets"},"\t"))
	root.free();return result
