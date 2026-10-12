extends RefCounted
## V173: official backdoor70040615 and anniversary built photograph.
## Fitted podium terrace, recessed glazed undercroft, stone tree beds; not surveyed grade.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/ShawEastPodium.gd")
const V=preload("res://world/visual_campus/CampusVegetation.gd")
const BASE:=11.5

static func column(n:Node3D,p:Vector3)->void:
	var mesh:=CylinderMesh.new();mesh.height=3.52;mesh.top_radius=.46;mesh.bottom_radius=.46;mesh.radial_segments=28
	var col:=MeshInstance3D.new();col.mesh=mesh;col.position=p+Vector3.UP*1.76;col.material_override=K.material("d4d6cb",22);n.add_child(col)
	var body:=StaticBody3D.new();body.position=col.position
	var collision:=CollisionShape3D.new();var shape:=CylinderShape3D.new();shape.height=3.52;shape.radius=.46
	collision.shape=shape;body.add_child(collision);n.add_child(body)

static func tree_bed(n:Node3D,x:float,seed:int)->void:
	# Stone sides enclose a planted centre; the wall cap also supports the photographed timber seat.
	var z:=40.3;var w:=7.2;var depth:=3.4
	for side in [-1,1]:
		K.box(n,Vector3(x,BASE+.24,z+side*(depth/2-.14)),Vector3(w,.48,.28),"b5b3a8",true,26)
		K.box(n,Vector3(x+side*(w/2-.14),BASE+.24,z),Vector3(.28,.48,depth),"b5b3a8",true,26)
		K.box(n,Vector3(x,BASE+.49,z+side*(depth/2-.05)),Vector3(w+.1,.07,.42),"c2c1b4",false,26)
	K.box(n,Vector3(x,BASE+.15,z),Vector3(w-.56,.22,depth-.56),"54543e",false,8)
	V.shrub(n,Vector3(x,BASE+.27,z),Vector3(w-.7,.42,depth-.7),seed)
	K.tree(n,Vector3(x,BASE+.27,z),5.5,seed)
	# Rear seating leaves the broad facade-side walking aisle unobstructed.
	for j in 4:K.box(n,Vector3(x,BASE+.55,z+depth/2-.16+j*.15),Vector3(w-.6,.075,.12),"a18058",false,0)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"ResearchUpperTerraceV173")
	# Extend the fitted forecourt over the existing podium, leaving the main stair throat open.
	for span:Vector2 in [Vector2(-45,-7.2),Vector2(7.2,23.8)]:
		K.box(n,Vector3((span.x+span.y)/2,BASE-.18,41),Vector3(span.y-span.x,.36,6),"bfc1b7",true,22)
		K.box(n,Vector3((span.x+span.y)/2,BASE+.018,38.6),Vector3(span.y-span.x,.026,10.8),"b2b2a8",false,26)
		P.rail(n,Vector3(span.x,BASE,44),Vector3(span.y,BASE,44),true)
		# Close both return ends while preserving the old main-stair opening.
		for x in [span.x,span.y]:P.rail(n,Vector3(x,BASE,38),Vector3(x,BASE,44),true)
	for x:float in [-32,-19,12]:tree_bed(n,x,17300+int(x))
	# Narrow flush drainage and deliberate paving bands below the curtain wall.
	for span:Vector2 in [Vector2(-42,-7.5),Vector2(7.5,17.5)]:
		K.box(n,Vector3((span.x+span.y)/2,BASE+.04,34.7),Vector3(span.y-span.x,.025,.18),"59645c",false,22)
	for x:float in [-41,-27,-13,8,18]:K.box(n,Vector3(x,BASE+.036,36.1),Vector3(.09,.018,4),"818b81",false,22)
	column(n,Vector3(21.3,BASE,33.3))
	# Mullions articulate the observed ground glass without closing the retained central doorway.
	for x in range(-37,18,3):
		if abs(x)<4:continue
		K.box(n,Vector3(x,BASE+1.8,33.09),Vector3(.065,3.6,.16),"6d7d78",false,11)
	K.finish(n)
