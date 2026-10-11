extends RefCounted
## C public corridor follows the oblique classroom wing shown in the architect plan.
## Door offset/room boundaries are fitted; not a claim to reproduce every classroom.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func build(b: Node3D,r: Dictionary) -> void:
	# b cube shows square grey tiles; .8m module is fitted, not measured.
	K.material("68716b",26).set_shader_parameter("tile_size",Vector2(.8,.8))
	var a:=Vector3(float(r.width)*.25,0,float(r.depth)*.36)
	var c:=Vector3(-float(r.width)*.17,0,-float(r.depth)*.36)
	var length: float=a.distance_to(c)
	var n:=K.holder(b,"TeachingCObliquePublicCorridor",(a+c)/2)
	n.rotation.y=atan2(a.x-c.x,a.z-c.z)
	K.box(n,Vector3(0,.145,0),Vector3(4.2,.026,length),"68716b",false,26)
	K.box(n,Vector3(0,3.40,0),Vector3(4.45,.12,length),"465148",false,16)
	K.box(n,Vector3(2.2,1.7,0),Vector3(.18,3.4,length),"b3b9ac",true,22)
	# Side court opening is cut into the wall, not painted onto an unbroken collider.
	for side in [-1,1]:
		var span: float=length/2-2.5
		K.box(n,Vector3(-2.2,1.7,side*(2.5+span/2)),Vector3(.18,3.4,span),"b3b9ac",true,22)
		K.box(n,Vector3(side*2.09,.12,0),Vector3(.06,.24,length),"758273",false,11)
	for i in range(-int(length/2)+4,int(length/2)-2,6):
		K.box(n,Vector3(0,3.30,i),Vector3(1.4,.04,.18),"e4e2cf",false,17)
		if abs(i)<4:continue
		# Shallow door leaves/reveals communicate the classroom edge without inventing room labels.
		for side in [-1,1]:
			K.box(n,Vector3(side*2.08,1.5,i),Vector3(.06,2.95,1.4),"768276",false,22)
			K.box(n,Vector3(side*2.035,2.14,i),Vector3(.035,.72,.84),"587277",false,5)
	for z in [-26,-10,10,26]:
		var light:=OmniLight3D.new();light.position=Vector3(0,2.8,z);light.light_energy=.40;light.omni_range=10;light.light_color=Color("e9e5d5");n.add_child(light)
	# Long-wing supports stand outside the walking corridor and leave the central side exit clear.
	for z in [-30,-22,-14,-6,6,14,22,30]:
		for x in [-6.2,6.2]:K.column(n,Vector3(x,0,z),4.66,.55)
	K.finish(n)
	# Short vestibule meets the square-on photographed entry and the diagonal hall mouth.
	K.box(b,Vector3(a.x,3.40,a.z+.8),Vector3(6,.12,3.6),"465148",false,16)
	K.box(b,Vector3(a.x,.092,a.z+.8),Vector3(6,.025,3.6),"68716b",false,26)
	# The far end exits beneath the low rear bar onto the continuous perimeter walk.
	# V138 rear street is downstairs; upper hall exits to guarded platform.
	K.box(b,Vector3(c.x,.145,-38),Vector3(5.4,.025,10),"999f93",false,42)
