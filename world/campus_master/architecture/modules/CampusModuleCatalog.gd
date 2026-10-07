extends RefCounted
## Named reusable vocabulary; dimensions are authored parameters, not measured reality.
const K := preload("res://world/campus_master/architecture/modules/ArchitectureKit.gd")
const WALLS := {"LIGHT_STONE_WALL":"light_stone","WHITE_CONCRETE_WALL":"warm_white","DARK_BASE_WALL":"dark_frame","GLASS_CURTAIN_WALL":"glass_bluegray","PODIUM_EDGE":"concrete_gray","PARAPET":"warm_white","RAILING":"railing_metal","COURTYARD_EDGE":"concrete_gray"}
const MODULES := ["LIGHT_STONE_WALL","WHITE_CONCRETE_WALL","DARK_BASE_WALL","GLASS_CURTAIN_WALL","WINDOW_GRID_SMALL","WINDOW_GRID_MEDIUM","VERTICAL_WINDOW_BAY","BALCONY_BAY","OPEN_CORRIDOR","COVERED_CORRIDOR","COLONNADE","GROUND_ARCADE","GLASS_ENTRANCE","CANOPY","PODIUM_EDGE","PARAPET","ROOF_SCREEN","RAILING","STAIR_BLOCK","RAMP","COURTYARD_EDGE"]

static func add(root: Node3D,id: String,pos: Vector3,size: Vector3) -> void:
	assert(id in MODULES,"Unknown architecture module")
	if WALLS.has(id):K.box(root,pos,size,WALLS[id]);return
	match id:
		"WINDOW_GRID_SMALL","WINDOW_GRID_MEDIUM":K.facade(root,pos,size,id=="WINDOW_GRID_SMALL")
		"VERTICAL_WINDOW_BAY":K.box(root,pos,size,"glass_bluegray")
		"BALCONY_BAY":
			K.box(root,pos,size,"warm_white");K.box(root,pos+Vector3(0,.7,size.z/2),Vector3(size.x,.9,.12),"railing_metal")
		"OPEN_CORRIDOR","COVERED_CORRIDOR","COLONNADE","GROUND_ARCADE":K.arcade(root,pos,size.x,size.z,size.y)
		"GLASS_ENTRANCE":K.box(root,pos,size,"glass_bluegray")
		"CANOPY":K.box(root,pos,size,"warm_white")
		"ROOF_SCREEN":K.screen(root,pos,size.x,size.y,"dark_frame")
		"STAIR_BLOCK":
			for i in 5:K.box(root,pos+Vector3(0,size.y*(i+.5)/10,size.z*(i+.5)/5-size.z/2),Vector3(size.x,size.y*(i+1)/5,size.z/5),"concrete_gray",true)
		"RAMP":
			var ramp := K.box(root,pos,Vector3(size.x,.25,size.z),"concrete_gray",true)
			ramp.rotation.x=-atan2(size.y,size.z);root.set_meta("future_walkable_surface",true)
