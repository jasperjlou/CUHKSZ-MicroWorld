extends RefCounted
## V237: official first-floor panorama finishes; exact fixture grid/heights fitted.
## Thin non-colliding linings preserve the authored openings and physical envelope.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const C=preload("res://world/visual_campus/StudentFrontCore.gd")

static func disk(n:Node3D,p:Vector3,r:float,h:float,color:String,kind:int)->void:
	var mesh:=CylinderMesh.new();mesh.top_radius=r;mesh.bottom_radius=r;mesh.height=h;mesh.radial_segments=20
	var item:=MeshInstance3D.new();item.mesh=mesh;item.position=p;item.material_override=K.material(color,kind);n.add_child(item)

static func pendant(n:Node3D,u:float,v:float)->void:
	var h:=K.holder(n,"TriplePendant",P.point(u,v))
	K.box(h,Vector3(0,3.79,0),Vector3(2.30,.045,.065),"252e2b",false,11)
	for x:float in [-.88,0.,.88]:
		K.box(h,Vector3(x,3.42,0),Vector3(.018,.72,.018),"252e2b",false,11)
		# Bell shade profile: curved flared shell and pale luminous open underside.
		var vertices:=PackedVector3Array()
		var profile:Array=[[.045,3.12],[.08,3.08],[.17,3.02],[.245,2.94],[.28,2.90]]
		for j in range(profile.size()-1):
			for i in 24:
				var a:float=TAU*i/24.;var b:float=TAU*(i+1)/24.
				var r:float=profile[j][0];var s:float=profile[j+1][0]
				var y:float=profile[j][1];var z:float=profile[j+1][1]
				var p0:=Vector3(x+cos(a)*r,y,sin(a)*r);var p1:=Vector3(x+cos(b)*r,y,sin(b)*r)
				var p2:=Vector3(x+cos(a)*s,z,sin(a)*s);var p3:=Vector3(x+cos(b)*s,z,sin(b)*s)
				vertices.append_array(PackedVector3Array([p0,p2,p1,p1,p2,p3]))
		K.surface(h,vertices,"29312c",11,false)
		disk(h,Vector3(x,2.897,0),.258,.018,"e4e5d7",17)
	K.finish(h)

static func vent(n:Node3D,u:float,v:float)->void:
	var h:=K.holder(n,"SquareCeilingDiffuser",P.point(u,v,3.825))
	K.box(h,Vector3.ZERO,Vector3(.74,.025,.74),"c4c8ba",false,11)
	K.box(h,Vector3(0,-.018,0),Vector3(.65,.013,.65),"424b44",false,11)
	for size:float in [.19,.32,.45,.58]:
		for side in [-1,1]:
			K.box(h,Vector3(side*size/2,-.027,0),Vector3(.023,.022,size),"a5ae9f",false,11)
			K.box(h,Vector3(0,-.027,side*size/2),Vector3(size,.022,.023),"a5ae9f",false,11)
	K.finish(h)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentCanteenFinishV237")
	var bays:Array=[[304.,333.,false],[340.,362.,true],[371.,387.,true],[425.,451.,true],[470.,500.,false],[510.,545.,false],[570.,597.,false]]
	var cursor:float=300.
	for bay in bays:
		var a:float=bay[0];var b:float=bay[1]
		if a>cursor:
			C.rect(n,220.,cursor,220.55,a,.09,4.12,"e0e1d6",false,22)
			C.rect(n,220.55,cursor,220.72,a,.09,.18,"9b9f94",false,22)
		# Linings follow existing side walls; no panel spans the open clear width.
		for edge:float in [a,b]:
			C.rect(n,219.2,edge-.18,220.55,edge+.18,.18,3.35,"dedfd4",false,22)
		C.rect(n,220.,a,220.55,b,3.35,4.12,"e0e1d6",false,22)
		if not bay[2]:
			C.rect(n,219.2,a,221.,b,.17,.195,"cbcec1",false,22)
		# V238 floor module owns the flush door threshold finish.
		cursor=b
	C.rect(n,220.,cursor,220.55,603.,.09,4.12,"e0e1d6",false,22)
	# Close the window-side ceiling band; the front stair opening is before v300.
	C.rect(n,220.,300.,325.,599.,3.84,3.91,"d6d8cb",false,22)
	for v:float in [275.,315.,395.,435.]:pendant(n,350.,v)
	# Downlights and diffusers on the white perimeter; none crosses the hexagon field.
	for u:float in [275.,395.,635.]:
		for v:float in [320.,375.,425.,485.,540.,578.]:
			if u==275. and v>453.:continue
			disk(n,P.point(u,v,3.824),.105,.018,"c0c6b8",11)
			disk(n,P.point(u,v,3.812),.075,.012,"eceadd",17)
	for q:Array in [[340,355],[340,485],[630,355],[630,520]]:vent(n,q[0],q[1])
	for band:Array in [[265.,405.],[498.,580.]]:
		C.rect(n,671.5,band[0],672.2,band[1],3.69,3.74,"333d37",false,11)
		for v in range(int(band[0])+10,int(band[1]),28):
			var h:=K.holder(n,"CounterTrackSpot",P.point(672,v,3.60))
			h.rotation.x=.30
			disk(h,Vector3.ZERO,.05,.18,"cdd3c6",11)
			disk(h,Vector3(0,-.095,0),.043,.015,"e7e6d8",17)
	K.finish(n)
