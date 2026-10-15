extends RefCounted
## V87 user photos 222548/552/556/613. Exact footprint and elevations remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const W:=preload("res://world/visual_campus/WesternCampus.gd")
const S:=preload("res://world/visual_campus/StartZoneLandscape.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24

static func library_base(parent:Node3D,w:float,d:float) -> void:
	var n:=K.holder(parent,"LibraryRoadRecessedGlazingV87",Vector3(-w/2+1.15,0,0))
	n.rotation.y=-PI/2
	var length:float=d*.93
	var count:=roundi(length/2.7);var pitch:float=length/count
	K.box(n,Vector3(0,.07,-.6),Vector3(length,.12,1.8),"a5a398",false,26)
	K.box(n,Vector3(0,4.35,-.3),Vector3(length,.22,2.0),"b7baaf",false,22)
	for i in count:
		var x:float=-length/2+(i+.5)*pitch
		K.box(n,Vector3(x,2.05,0),Vector3(pitch-.07,3.98,.09),"a0b6b3",true,19)
		K.box(n,Vector3(x-pitch/2,2.1,.075),Vector3(.075,4.2,.16),"475c59",false,11)
		K.box(n,Vector3(x,3.12,.075),Vector3(pitch,.085,.16),"475c59",false,11)
		K.box(n,Vector3(x,4.10,.075),Vector3(pitch,.09,.16),"475c59",false,11)
		K.box(n,Vector3(x,.14,.075),Vector3(pitch,.20,.22),"5c6861",false,11)
		# Quiet interior surfaces give the recessed glass depth without inventing room use.
		K.box(n,Vector3(x,2.0,-1.5),Vector3(pitch,3.9,.10),"a7afa6",false,22)
	K.finish(n)
	var sign_node:=K.holder(parent,"OldLibraryRoadName",Vector3(-w/2-.05,0,-d*.13));sign_node.rotation.y=-PI/2
	var title:=K.label(sign_node,"黄宜弘梁凤仪图书馆",Vector3(0,15.83,.04),.017);title.modulate=Color("35433c")
	var subtitle:=K.label(sign_node,"PHILIP YU HONG WONG & ANITA FUNG YEE LEUNG LIBRARY",Vector3(0,15.20,.045),.0055);subtitle.modulate=Color("35433c")
	K.finish(sign_node)

static func rail(n:Node3D,points:Array) -> void:
	for i in range(points.size()-1):
		var a:Vector2=points[i];var b:Vector2=points[i+1];var delta:=b-a
		var count:=maxi(1,ceili(delta.length()/.22))
		for j in count+1:
			var p:=a.lerp(b,float(j)/count)
			K.box(n,Vector3(p.x,G+.70,p.y),Vector3(.032,1.05,.032),"dadfd6",false,11)
		for h in [.20,1.23]:
			K.box(n,Vector3((a.x+b.x)/2,G+h,(a.y+b.y)/2),Vector3(.055,.05,delta.length()),"dadfd6",true,11,atan2(delta.x,delta.y))
		K.box(n,Vector3(a.x,G+.7,a.y),Vector3(.065,1.1,.065),"e0e4da",true,11)

static func curved_corner(a:Vector2,control:Vector2,b:Vector2)->Array:
	var points:Array=[]
	for i in 25:
		var t:float=float(i)/24
		points.append(a.lerp(control,t).lerp(control.lerp(b,t),t))
	return points

static func build(root:Node3D,builder) -> void:
	var n:=K.holder(root,"OldLibraryCourtRoadV87")
	# V145: one brick approach owns the crossing; no generic stone ribbon across the grass.
	# Photo222613 retains the court-side grass seam and library planted strip.
	# Exact polygon is fitted to the existing rail/road, not a surveyed footprint.
	var corner:=PackedVector2Array([Vector2(-11.5,-668),Vector2(-6.6,-668),Vector2(-6.6,-673),Vector2(-9,-675.5),Vector2(-13,-676.8),Vector2(-22.1,-676.8),Vector2(-22.1,-673.6),Vector2(-16,-673.6)])
	var triangles:=Geometry2D.triangulate_polygon(corner);var verts:=PackedVector3Array()
	for i in range(0,triangles.size(),3):
		var a:=corner[triangles[i]];var c:=corner[triangles[i+1]];var e:=corner[triangles[i+2]]
		verts.append_array(K.quad(Vector3(a.x,G+.147,a.y),Vector3(c.x,G+.147,c.y),Vector3(e.x,G+.147,e.y),Vector3(a.x,G+.147,a.y)))
	K.surface(n,verts,"918c7c",65)
	# Lower crossing landing stops at the photographed planted verge, then rounds the corner.
	builder.ribbon(n,[[-20.5,G,-687.4],[-14,G,-687.4],[-10.2,G,-689.3],[-8.1,G,-693],[-8.1,G,-700]],2.7,"918c7c",65,.147)
	# Rail follows the rounded branch mouth. Openings align with the actual crossing.
	# Photo613 shows an open planted verge beyond the short junction guardrail.
	rail(n,[Vector2(-28,-686.7),Vector2(-23,-686.7)])
	var south:Array=[Vector2(-18,-686.7)]
	south.append_array(curved_corner(Vector2(-13,-686.7),Vector2(-5.1,-686.7),Vector2(-5.1,-695)))
	south.append(Vector2(-5.1,-699));rail(n,south)
	var north:Array=[Vector2(-18,-677.5)]
	north.append_array(curved_corner(Vector2(-13,-677.5),Vector2(-5.2,-677.5),Vector2(-5.2,-670)))
	north.append(Vector2(-5.2,-668));rail(n,north)
	# White pickets do not run through the public crossing or the court gate approach.
	for i in range(-4,5):K.box(n,Vector3(-20.5,G+.190,-682+i*.79),Vector3(3.5,.008,.42),"dfdfd2",false,22)
	for x in [-24.0,-25.2,-15.8,-14.6]:
		K.box(n,Vector3(x,G+.190,-682),Vector3(.18,.008,7.5),"d9ddd2",false,22)
	for z in [-677.4,-686.6]:K.box(n,Vector3(-20.5,G+.15,z),Vector3(3.7,.018,.62),"b7a16c",false,1)
	# Court-side narrow brick walk, small grass seam, kerb and painted asphalt edge.
	# V214 continuous branch ribbon now owns this strip; no overlapping second slab.
	K.box(n,Vector3(-46,G+.152,-677.67),Vector3(43,.012,.20),"949a8e",false,15)
	K.box(n,Vector3(-44,G+.166,-677.40),Vector3(44,.012,.18),"85867c",false,87)
	# Photo222613 has a visible lawn strip; keep the central gate bridge open.
	var verge:=K.holder(n,"CourtWallGrassVergeV252")
	for span:Vector2 in [Vector2(-66,-45.7),Vector2(-42.3,-22)]:
		var length:float=span.y-span.x;var x:float=(span.x+span.y)*.5
		K.box(verge,Vector3(x,G+.13,-675.30),Vector3(length,.04,.50),"607047",false,2)
		K.box(verge,Vector3(x,G+.165,-675.59),Vector3(length,.012,.08),"74796a",false,15)
		# Small low blades break up the flat verge without a tall hedge or invented wall.
		var blades:=PackedVector3Array()
		for i in int(length*12):
			var xx:float=span.x+.04+float(i)/12
			var zz:float=-675.47+fmod(float(i)*.137,.34)
			var yy:float=G+.15;var height:float=.035+fmod(float(i)*.019,.055)
			blades.append_array(K.quad(Vector3(xx-.018,yy,zz),Vector3(xx,yy+height,zz+.008),Vector3(xx+.018,yy,zz),Vector3(xx-.018,yy,zz)))
		K.surface(verge,blades,"6b7850",22)
	K.finish(verge)
	# Visible kerb units use narrow joints, rather than a continuous monolithic lip.
	for i in 40:
		var x:float=-67.5+i
		K.box(n,Vector3(x,G+.244,-677.90),Vector3(.008,.003,.22),"737b70",false,22)
	for bounds:Vector2 in [Vector2(-68,-27),Vector2(-14,-10)]:
		K.box(n,Vector3((bounds.x+bounds.y)/2,G+.19,-677.90),Vector3(bounds.y-bounds.x,.10,.22),"aeb2a6",false,15)
		K.box(n,Vector3((bounds.x+bounds.y)/2,G+.215,-678.18),Vector3(bounds.y-bounds.x,.012,.13),"e0e1d6",false,22)
	# Direction arrows are visible in photo548; exact offsets remain fitted.
	for item in [[-31.5,-680.1,1.0],[-36.0,-684.0,-1.0]]:
		var x:float=item[0];var z:float=item[1];var direction:float=item[2]
		K.box(n,Vector3(x,G+.208,z),Vector3(2.8,.008,.17),"d6d6c8",false,22)
		K.surface(n,K.quad(Vector3(x+direction*2.2,G+.213,z),Vector3(x+direction*.85,G+.213,z-.66),Vector3(x+direction*.85,G+.213,z+.66),Vector3(x+direction*2.2,G+.213,z)),"d6d6c8",22)
	# Shallow speed cushion stays drivable; the photographic location is proportion fitted.
	for i in 16:
		K.box(n,Vector3(-55,G+.225,-685.65+i*.47),Vector3(.46,.055,.44),"c3ac51" if i%2 else "39423f",true,22)
	var cover:=CylinderMesh.new();cover.top_radius=.43;cover.bottom_radius=.43;cover.height=.012;cover.radial_segments=32
	var manhole:=MeshInstance3D.new();manhole.mesh=cover;manhole.material_override=K.material("4a504a",11);manhole.position=Vector3(-16,G+.255,-684.2);n.add_child(manhole)
	for i in 7:K.box(n,Vector3(-16,G+.266,-684.5+i*.1),Vector3(.62,.007,.018),"677067",false,11)
	# Trees/low hedges separate the road from the photographed recessed glass base.
	# V253 road-side lawn in front, low hedge by the glazing; no invented walkway between.
	var planting:=K.holder(n,"LibraryRoadPlantingV253")
	K.box(planting,Vector3(-43,G+.11,-688.82),Vector3(38,.04,4.40),"65754d",false,2)
	K.box(planting,Vector3(-43,G+.13,-690.65),Vector3(38,.04,.70),"59664a",false,3)
	for z in [-686.55,-691.16]:
		K.box(planting,Vector3(-43,G+.17,z),Vector3(38,.14,.14),"a4aa9b",false,15)
		for i in 37:K.box(planting,Vector3(-61.5+i,G+.242,z),Vector3(.008,.003,.14),"727c70",false,22)
	# Short returns close the planting at the still-open crossing and rear approach.
	for x in [-62,-24]:K.box(planting,Vector3(x,G+.17,-688.855),Vector3(.14,.14,4.75),"a4aa9b",false,15)
	K.finish(planting)
	# Fine drain at the glass setback; slats stay separate from the planted strip.
	K.box(n,Vector3(-39,G+.115,-691.45),Vector3(45,.025,.19),"4a5851",false,11)
	for i in 180:K.box(n,Vector3(-61.4+i*.25,G+.135,-691.45),Vector3(.04,.015,.18),"778075",false,11)
	for x in [-57,-47,-37,-27]:
		K.tree(n,Vector3(x,G,-689.9),9.5,8700+absi(x),1.7)
		for side in [-1,1]:
			W.beam(n,Vector3(x+side*.8,G,-689.2),Vector3(x,G+2.65,-689.9),.05,.05,"456e5b")
		# Third brace and a modest trunk tie complete the photographed green support.
		W.beam(n,Vector3(x,G,-690.72),Vector3(x,G+2.65,-689.9),.05,.05,"456e5b")
		K.box(n,Vector3(x,G+2.60,-689.9),Vector3(.35,.10,.35),"536d56",false,22)
		V.shrub(n,Vector3(x,G,-690.5),Vector3(8.8,.70,.90),8700+absi(x))
	for x in [-35,-61]:
		K.box(n,Vector3(x,G+1.72,-688.9),Vector3(.10,3.2,.12),"b5beb0",false,11)
		K.box(n,Vector3(x+.07,G+2.0,-688.9),Vector3(.035,2.3,.08),"e1dec0",false,17)
	K.finish(n)
	preload("res://world/visual_campus/OldLibraryCoachApron.gd").build(root,builder)
