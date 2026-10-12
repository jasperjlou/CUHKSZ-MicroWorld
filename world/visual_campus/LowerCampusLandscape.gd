extends RefCounted
## Site details fitted to the retained East Gate frame; no surveyed dimensions implied.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const G := 2.24
const PondEdges=preload("res://world/visual_campus/LotusPondEdges.gd")

static func pond_cutout(x: float,z: float) -> bool:
	return x>65 and x<116 and z>-363 and z<-337

static func paving(b: Node3D,p: Vector3,size: Vector2) -> void:
	K.box(b,p+Vector3.UP*.028,Vector3(size.x,.045,size.y),"b6b3a7",false,6)

static func hedge(b: Node3D,p: Vector3,size: Vector2) -> void:
	K.box(b,p+Vector3.UP*.10,Vector3(size.x+.22,.20,size.y+.22),"abae9f",false,6)
	K.box(b,p+Vector3.UP*.24,Vector3(size.x,.18,size.y),"554b38",false,4)
	V.shrub(b,p+Vector3.UP*.23,Vector3(size.x,.46,size.y),absi(int(p.x*13+p.z*7)))

static func drain(b: Node3D,p: Vector3,length: float,yaw: float=0) -> void:
	var n:=K.holder(b,"Drain",p);n.rotation.y=yaw
	K.box(n,Vector3(0,.031,0),Vector3(length,.04,.22),"515a54",false,11)
	for i in int(length/.16):K.box(n,Vector3(-length/2+i*.16,.055,0),Vector3(.033,.02,.21),"91968b",false,11)
	K.finish(n)

static func lilies(b: Node3D) -> void:
	var rng:=RandomNumberGenerator.new();rng.seed=116440795
	# One notched radial mesh, instanced across the water. The V-shaped cut is a real silhouette.
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 17:
		var a:=.22+i*(TAU-.44)/17;var c:=.22+(i+1)*(TAU-.44)/17
		st.add_vertex(Vector3.ZERO);st.add_vertex(Vector3(cos(a),.025,sin(a)));st.add_vertex(Vector3(cos(c),.025,sin(c)))
	st.generate_normals();var leaf_mesh:=st.commit()
	var leaves:=MultiMesh.new();leaves.transform_format=MultiMesh.TRANSFORM_3D;leaves.use_colors=true;leaves.mesh=leaf_mesh
	var positions: Array[Vector3]=[]
	for i in 820:
		var x:=rng.randf_range(66,115);var z:=rng.randf_range(-362,-338)
		# Open reflection strip, with denser patches against the student-centre shore.
		if z>-346 and x>86 and x<105:continue
		if sin(x*.26+z*.32)>.55 and rng.randf()>.30:continue
		positions.append(Vector3(x,1.995+rng.randf_range(0,.022),z))
	leaves.instance_count=positions.size()
	for i in positions.size():
		var r:=rng.randf_range(.27,.58)
		leaves.set_instance_transform(i,Transform3D(Basis(Vector3.UP,rng.randf()*TAU)*Basis.from_scale(Vector3(r,1,r*.88)),positions[i]))
		leaves.set_instance_color(i,Color(1,1,1)*rng.randf_range(.65,1.15))
	var node:=MultiMeshInstance3D.new();node.multimesh=leaves;node.material_override=K.material("667e42",14);b.add_child(node)
	var petals:=PackedVector3Array()
	for i in range(0,positions.size(),23):
		var p:=positions[i]+Vector3.UP*.12
		for j in 8:
			var a:=j*TAU/8;var radial:=Vector3(cos(a),0,sin(a));var tangent:=Vector3(-sin(a),0,cos(a))
			var tip:=p+radial*.26+Vector3.UP*.12
			petals.append_array(K.quad(p,p+radial*.13+tangent*.075,tip,p+radial*.13-tangent*.075))
	K.surface(b,petals,"c588b1",0)

static func lotus_pond(root: Node3D) -> void:
	var b:=K.holder(root,"LotusPondBetweenLibraryAndStudentCentre")
	K.box(b,Vector3(90.5,1.52,-350),Vector3(51,.16,26),"6e7560",true,6)
	K.box(b,Vector3(90.5,1.92,-350),Vector3(51,.12,26),"40584d",false,10)
	for x in [64.8,116.2]:K.box(b,Vector3(x,1.96,-350),Vector3(.40,.80,26.4),"92988b",true,6)
	K.box(b,Vector3(90.5,1.96,-363.2),Vector3(51.4,.80,.40),"92988b",true,6)
	for interval: Vector2 in [Vector2(64.8,87),Vector2(103,116.2)]:
		K.box(b,Vector3((interval.x+interval.y)/2,1.96,-336.8),Vector3(interval.y-interval.x,.8,.4),"92988b",true,6)
	for x in [64.75,116.25]:K.box(b,Vector3(x,2.30,-350),Vector3(.62,.13,26.7),"b8b9aa",false,6)
	K.box(b,Vector3(90.5,2.30,-363.25),Vector3(51.7,.13,.62),"b8b9aa",false,6)
	for interval: Vector2 in [Vector2(64.65,87),Vector2(103,116.35)]:
		K.box(b,Vector3((interval.x+interval.y)/2,2.30,-336.75),Vector3(interval.y-interval.x,.13,.62),"b8b9aa",false,6)
	PondEdges.paving(b,Vector3(61.2,G,-350),Vector2(6.2,29))
	PondEdges.paving(b,Vector3(121,G,-350),Vector2(8,34))
	PondEdges.paving(b,Vector3(91,G,-334.3),Vector2(53,5.5))
	PondEdges.paving(b,Vector3(91,G,-365.7),Vector2(53,4.3))
	# Curved stone sitting edge in the library-side quay, clearly visible in the architect's aerial.
	var quay:=PackedVector3Array();var center:=Vector3(95,2.27,-337)
	for i in 28:
		var a:=PI+i*PI/28;var c:=PI+(i+1)*PI/28
		var p:=center+Vector3(cos(a)*8,0,sin(a)*5);var q:=center+Vector3(cos(c)*8,0,sin(c)*5)
		quay.append_array(K.quad(center,p,q,center))
		var mid: Vector3=(p+q)/2
		K.box(b,mid-Vector3.UP*.16,Vector3(p.distance_to(q)+.05,.34,.28),"adaf9e",false,6,-atan2(q.z-p.z,q.x-p.x))
	K.surface(b,quay,"747c78",53,true)
	lilies(b)
	PondEdges.build(b)
	for p: Vector3 in [Vector3(121,G,-339),Vector3(121,G,-368),Vector3(80,G,-333.8),Vector3(109,G,-333.8)]:
		K.box(b,p+Vector3.UP*.055,Vector3(2,.1,2),"716d58",false,6)
		K.tree(b,p,7.2,absi(int(p.x*10+p.z)))
	for p: Vector3 in [Vector3(122,G,-345),Vector3(122,G,-353),Vector3(75,G,-334.4),Vector3(107,G,-334.4)]:K.bench(b,p,PI/2 if p.x>120 else 0)
	drain(b,Vector3(124.7,G,-350),28,PI/2)
	# Replace the former detached south-side placeholder pool with a planted court.
	# V127 open lower lane and planted bank replace the former continuous upper paving.
	paving(b,Vector3(21.75,G,-461),Vector2(6.5,21))
	paving(b,Vector3(45.75,G,-461),Vector2(11.5,21))
	for x in [22,45]:
		hedge(b,Vector3(x,G,-461),Vector2(5,12));K.tree(b,Vector3(x,G+.4,-461),8,int(x))
		K.bench(b,Vector3(x,G,-453))
	K.finish(b)

static func south_gate(root: Node3D) -> void:
	# Map relationship: the south entrance axis lies in the gap between Teaching A and B.
	var b:=K.holder(root,"SouthGate",Vector3(-158,G,-167));b.rotation.y=-PI/2
	paving(b,Vector3.ZERO,Vector2(30,35))
	K.box(b,Vector3(0,.28,0),Vector3(18,.55,2.2),"9c9e91",true,6)
	K.box(b,Vector3(0,1.35,0),Vector3(17.5,1.60,.70),"c6c4b5",true,15)
	K.box(b,Vector3(0,2.17,0),Vector3(17.65,.09,.82),"d0cdbd",false,6)
	var name_label:=K.label(b,"香港中文大学（深圳）",Vector3(0,1.57,.39),.021);name_label.modulate=Color("927547")
	var en:=K.label(b,"The Chinese University of Hong Kong, Shenzhen",Vector3(0,.92,.39),.0065);en.modulate=Color("927547")
	hedge(b,Vector3(0,0,3.2),Vector2(19,2.2));hedge(b,Vector3(0,0,-3.2),Vector2(19,2.2))
	# Gatehouse on one flank; both pedestrian openings remain physically clear.
	var booth:=Vector3(12.3,0,9)
	K.box(b,booth+Vector3.UP*1.6,Vector3(3.3,3.2,3.3),"bec2b6",true,15)
	K.box(b,booth+Vector3.UP*3.29,Vector3(3.8,.20,3.8),"d0d2c5",false,6)
	K.window(b,booth+Vector3(0,1.95,1.69),2.65,1.55)
	K.window(b,booth+Vector3(-1.69,1.95,0),2.5,1.55,-PI/2)
	for x in [-14.2,-9.4,9.4,14.2]:
		for z in [-7,6]:K.box(b,Vector3(x,.43,z),Vector3(.18,.86,.18),"6c7268",true,11)
	for side in [-1,1]:
		for i in 18:K.box(b,Vector3(side*(15.8+i*.44),.72,11.3),Vector3(.055,1.44,.055),"535b52",false,11)
		K.box(b,Vector3(side*19.6,1.45,11.3),Vector3(8,.055,.06),"535b52",false,11)
	K.finish(b)
	var avenue:=K.holder(root,"SouthGateAvenue")
	paving(avenue,Vector3(-77,G,-167),Vector2(152,12))
	for x in range(-139,-8,14):
		for side in [-1,1]:
			var p:=Vector3(x,G,-167+side*10)
			K.tree(avenue,p,8.5+(absi(x)%3),absi(x)+side)
			hedge(avenue,p,Vector2(5,2.2))
	for x in [-136,-108,-24]:
		K.bench(avenue,Vector3(x,G,-174.5));K.lamp(avenue,Vector3(x,G,-159.2))
	for z in [-172.7,-161.3]:drain(avenue,Vector3(-77,G,z),147)
	# Small dark border bands leave the main walking surface unobstructed.
	for z in [-173,-161]:K.box(avenue,Vector3(-77,G+.054,z),Vector3(152,.026,.26),"7d8073",false,6)
	K.finish(avenue)

static func build(root: Node3D) -> void:
	lotus_pond(root);south_gate(root)
	preload("res://world/visual_campus/StartZoneLandscape.gd").build(root)
