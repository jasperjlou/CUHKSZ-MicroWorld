extends RefCounted
## V255 official 2026 reopening photo, event1365: frosted aluminium enclosure and soft seats.
## Shape is source-led;8x5m footprint and placement beside the fitted computer side remain approximate.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
static func panel(n:Node3D,a:Vector3,b:Vector3)->void:
	var delta:=b-a;var length:=delta.length();var yaw:=atan2(-delta.z,delta.x)
	var h:=K.holder(n,"FrostedBay",(a+b)/2);h.rotation.y=yaw
	K.box(h,Vector3(0,1.18,0),Vector3(length,2.12,.065),"c3cdc5",true,79)
	K.box(h,Vector3(0,2.43,0),Vector3(length,.38,.065),"d2dbd3",true,80)
	for y in [.16,2.25,2.66]:K.box(h,Vector3(0,y,0),Vector3(length,.055,.085),"a7ada5",false,11)
	for x in [-length/2,length/2]:K.box(h,Vector3(x,1.40,0),Vector3(.045,2.58,.085),"a7ada5",false,11)
	K.finish(h)
static func soft_seat(n:Node3D,p:Vector3,colour:String)->void:
	var h:=K.holder(n,"SoftSeat",p)
	for part:Vector3 in [Vector3(0,.40,0),Vector3(0,.63,-.38)]:
		var mesh:=SphereMesh.new();mesh.radius=.65;mesh.height=1.30;mesh.radial_segments=24;mesh.rings=12
		var shape:=MeshInstance3D.new();shape.mesh=mesh;shape.material_override=K.material(colour,22);shape.position=part;shape.scale=Vector3(1.1,.53,.85) if part.z==0 else Vector3(.90,.66,.45);h.add_child(shape)
	var body:=StaticBody3D.new();h.add_child(body);var c:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(1.4,1.05,1.3);c.shape=shape;c.position=Vector3(0,.525,-.10);body.add_child(c)
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"OldLibraryCozyZoneV255",Vector3(-23,0,-19.5))
	for x in [-4,-2.4,-.8,.8,2.4]:panel(n,Vector3(x,0,-2.5),Vector3(x+1.6,0,-2.5))
	for x in [-4,4]:
		for z in [-2.5,-1.25,0,1.25]:panel(n,Vector3(x,0,z),Vector3(x,0,z+1.25))
	# Open front bay1.6m wide; no invisible glass across the entrance.
	panel(n,Vector3(-4,0,2.5),Vector3(-3.3,0,2.5))
	for x in [-1.7,.2,2.1]:panel(n,Vector3(x,0,2.5),Vector3(x+1.9,0,2.5))
	K.box(n,Vector3(-2.5,2.66,2.5),Vector3(1.6,.055,.085),"a7ada5",false,11)
	soft_seat(n,Vector3(.2,0,-.8),"b17445");soft_seat(n,Vector3(2.3,0,-.8),"be7947")
	K.finish(n)
