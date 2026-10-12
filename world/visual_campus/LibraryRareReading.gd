extends RefCounted
## Envelope follows public5F202401 map via independentV112 fit; furnishings remain schematic.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const A=preload("res://world/visual_campus/LibraryAtrium.gd")
const S=preload("res://world/visual_campus/LibrarySixthFloor.gd")

static func wall(n:Node3D,a:Vector2,b:Vector2,y:float,height:float)->void:
	var delta:=b-a;var h:=K.holder(n,"RarePerimeter",Vector3((a.x+b.x)/2,y,(a.y+b.y)/2));h.rotation.y=-atan2(delta.y,delta.x)
	K.box(h,Vector3.ZERO,Vector3(delta.length(),height,.16),"d4d4c6",true,22);K.finish(h)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"RareReadingRegisteredV113");var poly:=P.rare_room()
	K.surface(n,P.floor_vertices([poly],16.815),"b4ae9c",25)
	K.surface(n,P.floor_vertices([poly],20.05,true),"deded2",22)
	for i in poly.size():
		# The two front edges abut the exterior window wall; no second opaque wall in its reveals.
		if i in [6,7]:continue
		var a:=poly[i];var b:=poly[(i+1)%poly.size()]
		if i==0:
			# V147: the core's end wall owns the middle of this boundary.
			# Endpoints include its full side-wall thickness, avoiding duplicate faces.
			var core=preload("res://world/visual_campus/LibraryServiceCores.gd")
			var left:Vector3=core.local_point(0,Vector3(-4.35,0,7.75))
			var right:Vector3=core.local_point(0,Vector3(4.35,0,7.75))
			wall(n,a,Vector2(left.x,left.z),18.42,3.24)
			wall(n,Vector2(right.x,right.z),b,18.42,3.24)
			continue
		if i==1:
			# The small diagonal edge is the double doorway, not a full-height wall.
			wall(n,a,b,19.82,.46)
			for q in [a,b]:K.box(n,Vector3(q.x,18.18,q.y),Vector3(.075,2.76,.075),"8c9686",false,11)
			# The 2025-09-17 official photograph shows the updated timber sign.
			var p:=P.point5(447,949,18.55);var sign:=K.holder(n,"SpecialCollectionsSign2025",p);sign.rotation.y=PI-.36
			K.box(sign,Vector3.ZERO,Vector3(.53,1.12,.045),"c69c62",false,4)
			var label:=K.label(sign,"特\n藏\n室",Vector3(-.07,0,.035),.0034);label.modulate=Color("3d3e37")
			K.finish(sign)
		else:wall(n,a,b,18.42,3.24)
	# Return platform follows the5F drawing and feeds the room door as well as the6F stair.
	var landing:=P.rare_landing();var bridge:=P.fifth_diagonal_bridge()
	var parts:Array[PackedVector2Array]=P.subtract([landing],bridge);parts.append(bridge)
	K.surface(n,P.floor_vertices(parts,16.8),"b5b3a6",12,true)
	K.surface(n,P.floor_vertices(parts,16.56,true),"d8d8ca",22)
	# Leave the upper portal open for the4F public stair; lower half follows the5F map.
	var a:=bridge[0];var b:=bridge[3];var start:=a.lerp(b,.42)
	A.edge_piece(n,Vector3(start.x,16.8,start.y),Vector3(b.x,16.8,b.y))
	A.edge_piece(n,P.point(442,779,16.8),P.point(455,779,16.8))
	A.edge_piece(n,P.point(490,779,16.8),P.point(548,779,16.8))
	# Inner edges of the left double-height bay: outside room wall closes its front half.
	var v:=P.fifth_left_void()
	for i in [0,1,2]:A.edge_piece(n,Vector3(v[i].x,16.8,v[i].y),Vector3(v[i+1].x,16.8,v[i+1].y))
	for q in [[300,1035],[475,1060]]:S.desk(n,P.point5(q[0],q[1],16.8),-.055)
	var lamp:=OmniLight3D.new();lamp.position=P.point5(400,1040,19.4);lamp.light_energy=.65;lamp.omni_range=12;lamp.light_color=Color("eae3d0");n.add_child(lamp)
	K.finish(n)
