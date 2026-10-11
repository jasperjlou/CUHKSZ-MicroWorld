extends RefCounted
## Surface families follow Main Square / Le Tian / Dao Yuan panoramas.
## The surveyed road alignment is unknown: all coordinates fit the retained building anchors.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const G := 2.24

static func patch(b: Node3D,x: float,z: float,w: float,d: float,brick: bool=false) -> void:
	K.box(b,Vector3(x,G+.051,z),Vector3(w,.032,d),"a88573" if brick else "b8a384",false,7 if brick else 1)

static func strip(b: Node3D,a: Vector2,c: Vector2,width: float,height: float,hex: String,kind: int=6) -> void:
	var delta:=c-a;var p: Vector2=(a+c)/2
	K.box(b,Vector3(p.x,G+height/2,p.y),Vector3(width,height,delta.length()),hex,false,kind,atan2(delta.x,delta.y))

static func grate(b: Node3D,x: float,z: float,yaw: float=0) -> void:
	var n:=K.holder(b,"FlushStormInlet",Vector3(x,G+.064,z));n.rotation.y=yaw
	K.box(n,Vector3.ZERO,Vector3(.48,.025,1.15),"424a45",false,11)
	for i in 8:K.box(n,Vector3(0,.022,-.49+i*.14),Vector3(.42,.018,.035),"90988c",false,11)
	K.finish(n)

static func street_lamp(b: Node3D,p: Vector3,side: int) -> void:
	var n:=K.holder(b,"CurvedStreetLamp",p)
	K.box(n,Vector3(0,3.25,0),Vector3(.12,6.5,.12),"737c74",false,11)
	var previous:=Vector3(0,6.5,0)
	for i in range(1,9):
		var a:=float(i)/8*PI/2;var q:=Vector3(-side*1.75*(1-cos(a)),6.5+1.15*sin(a),0)
		var arm:=MeshInstance3D.new();var mesh:=CylinderMesh.new();mesh.top_radius=.05;mesh.bottom_radius=.05;mesh.height=previous.distance_to(q);mesh.radial_segments=7
		arm.mesh=mesh;arm.material_override=K.material("737c74",11);arm.position=(previous+q)/2
		arm.basis=Basis(Quaternion(Vector3.UP,(q-previous).normalized()));n.add_child(arm);previous=q
	K.box(n,previous+Vector3(-side*.28,0,0),Vector3(.7,.14,.28),"59675c",false,11)
	K.box(n,previous+Vector3(-side*.28,-.08,0),Vector3(.52,.025,.20),"d6d4be",false,17)
	K.finish(n)

static func planted_edge(b: Node3D,p: Vector2,length: float,seed: int,along_x: bool=false) -> void:
	var n:=K.holder(b,"PlantedCourtEdge",Vector3(p.x,G,p.y));n.rotation.y=PI/2 if along_x else 0
	# Low stone edge and soil, with open ends. No hidden collision across the court.
	K.box(n,Vector3(0,.18,0),Vector3(2.8,.36,length),"939d8c",false,6)
	K.box(n,Vector3(0,.38,0),Vector3(2.55,.10,length-.25),"635c45",false,4)
	V.shrub(n,Vector3(0,.42,0),Vector3(2.4,.52,length-.45),seed)
	for i in maxi(1,int(length/9)):
		var z: float=-length/2+4.5+i*9
		K.tree(n,Vector3(0,.4,z),9.4+float(i%3)*.7,seed+i)
	K.finish(n)

static func road_crossing(b: Node3D,z: float) -> void:
	for i in range(-4,5):K.box(b,Vector3(i*.95,G+.083,z),Vector3(.52,.02,3.5),"d5d1c3",false,22)
	for side in [-1,1]:
		if (z==-805 and side==1) or (z==-839 and side==-1):continue
		patch(b,side*7.8,z,6.4,4.8)
		# Flush tactile landing: crossing remains on the existing physical ground.
		K.box(b,Vector3(side*5.4,G+.079,z),Vector3(.8,.018,3.5),"c6ab6e",false,1)
		for j in 11:K.box(b,Vector3(side*5.4,G+.094,z-1.5+j*.30),Vector3(.7,.01,.055),"a68f5f",false,22)

static func avenue(b: Node3D) -> void:
	for side in [-1,1]:
		var gap: float=-805 if side==1 else -839
		patch(b,side*8.1,(-636+gap+4)/2,6.8,-636-(gap+4))
		patch(b,side*8.1,(-847+gap-4)/2,6.8,gap-4+847)
		# Named Main Square panorama: narrow ochre brick, not generic large beige tiles.
		# Keep the unregistered southern junction outside this material replacement.
		K.box(b,Vector3(side*8.1,G+.111,-707.5),Vector3(6.8,.024,143),"a99579",false,34)
		# White edge lines continue from the Shaw curve; stop at the existing crossings.
		for interval:Vector2 in [Vector2(-636,-663.6),Vector2(-668.4,-694.6),Vector2(-699.4,-732.6),Vector2(-737.4,-779)]:
			if side==-1 and interval.x==-668.4:
				for section:Vector2 in [Vector2(-668.4,-670),Vector2(-694,-694.6)]:K.box(b,Vector3(side*4.24,G+.087,(section.x+section.y)/2),Vector3(.15,.016,absf(section.y-section.x)),"e0dfd3",false,22)
				continue
			K.box(b,Vector3(side*4.24,G+.087,(interval.x+interval.y)/2),Vector3(.15,.016,absf(interval.y-interval.x)),"e0dfd3",false,22)
		# Main road curb segmented at every public crossing and vehicle junction.
		for interval: Vector2 in [Vector2(-637,-659),Vector2(-673,-691),Vector2(-701,-731),Vector2(-739,-801),Vector2(-809,-835),Vector2(-843,-847)]:
			if side==-1 and interval.x in [-673,-739]:
				continue
			strip(b,Vector2(side*4.66,interval.x),Vector2(side*4.66,interval.y),.28,.18,"bbbdb1")
		for interval: Vector2 in [Vector2(-676,-689),Vector2(-701,-714),Vector2(-755,-783),Vector2(-823,-833)]:
			if side==-1 and interval.x==-676:continue
			strip(b,Vector2(side*11.6,interval.x),Vector2(side*11.6,interval.y),.22,.13,"a9b09e")
		for z in [-678,-719,-777,-823]:
			if side==-1 and z==-678:continue # V81 rounded vehicle mouth
			grate(b,side*4.16,z)
			street_lamp(b,Vector3(side*5.65,G,z+5),side)
		# Established verge trees are kept; ground planting ties their formerly isolated trunks together.
		for z in [-680,-705,-755,-780]:
			if side==-1 and z in [-680,-780]:continue # V81 branch road replaces this old verge
			if side==1 and z<=-660:continue # V78 central lawn and TowerPlaza own planting.
			V.shrub(b,Vector3(side*13.4,G,float(z)),Vector3(2.2,.40,8),absi(z)+side)
		for z in [-655,-680,-705,-755,-780]:
			if side==-1 and z in [-680,-780]:continue
			if side==1 and z<=-660:continue
			K.box(b,Vector3(side*14,G+.111,z),Vector3(2.4,.024,2.4),"514e3c",false,8)
			for edge in [-1,1]:
				K.box(b,Vector3(side*14+edge*1.3,G+.10,z),Vector3(.20,.20,2.8),"9ba68e",false,6)
				K.box(b,Vector3(side*14,G+.10,z+edge*1.3),Vector3(2.4,.20,.20),"9ba68e",false,6)
	for z in [-666,-697,-735,-805,-839]:road_crossing(b,z)
	# Road surfacing sits above crossing footpath ribbons; otherwise a gray tiled square
	# overwrites the asphalt at each junction. Markings are redrawn on this final layer.
	K.box(b,Vector3(0,G+.064,-739.5),Vector3(9,.02,207),"414b4c",false,2)
	for z in range(-642,-837,-9):
		var clear:=true
		for crossing in [-666,-697,-735,-805,-839]:
			if abs(z-crossing)<5:clear=false
		if clear:K.box(b,Vector3(0,G+.083,z),Vector3(.12,.014,3),"c9af67",false,22)

static func build(root: Node3D) -> void:
	var b:=K.holder(root,"StartZoneStreetAndCourts")
	avenue(b);K.finish(b)
