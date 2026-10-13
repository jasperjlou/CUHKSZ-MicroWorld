extends RefCounted
## User EXIF2026-10-10 photos222225/227: pale round downpipes and slotted precast drains.
## Diameters, positions and modules fitted; no below-ground network inferred.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const G:=2.24
static func drain(parent:Node3D,a:Vector2,b:Vector2)->void:
	var delta:=b-a;var length:=delta.length()
	var n:=K.holder(parent,"RecessedPrecastDrainV213",Vector3((a.x+b.x)/2,G,(a.y+b.y)/2));n.rotation.y=atan2(delta.x,delta.y)
	# Backing channel is below the actual slit openings, all visual above retained terrain.
	K.box(n,Vector3(0,.103,0),Vector3(.48,.016,length),"39433e",false,11)
	for side:float in [-1,1]:K.box(n,Vector3(side*.27,.144,0),Vector3(.08,.068,length),"858c87",false,15)
	var cells:=ceili(length/1.2);var module:float=length/cells
	for i in cells:
		var start:float=-length/2+i*module
		var count:=maxi(1,roundi(module/.19));var pitch:float=module/count
		for j in count:
			# Gaps between these blocks are geometrical slots, not painted black stripes.
			K.box(n,Vector3(0,.144,start+(j+.5)*pitch),Vector3(.46,.068,pitch-.042),"858c87",false,15)
		K.box(n,Vector3(0,.183,start+.006),Vector3(.61,.008,.012),"616c63",false,11)
	K.finish(n)
static func downpipe(parent:Node3D,x:float,z:float,roof:float)->void:
	var n:=K.holder(parent,"RoundRainpipeV213",Vector3(x,G,z))
	var segments:Array[Transform3D]=[];var collars:Array[Transform3D]=[]
	var points:Array[Vector3]=[Vector3(0,.16,0),Vector3(0,roof-G-.83,0),Vector3(0,roof-G-.48,-.27),Vector3(0,roof-G-.18,-.27)]
	for i in points.size()-1:segments.append(pipe_transform(points[i],points[i+1],.046))
	for y:float in [.5,1.6,2.75,roof-G-.86]:
		collars.append(pipe_transform(Vector3(0,y-.03,0),Vector3(0,y+.03,0),.058))
		K.box(n,Vector3(-.03,y,-.08),Vector3(.07,.025,.12),"9da79c",false,11)
	collars.append(pipe_transform(points[2]-Vector3.UP*.025,points[2]+Vector3.UP*.025,.058))
	pipe_mesh(n,segments,"c6cbc2");pipe_mesh(n,collars,"aeb7ab")
	K.finish(n)
static func pipe_transform(a:Vector3,b:Vector3,r:float)->Transform3D:
	var direction:=b-a
	return Transform3D(Basis(Quaternion(Vector3.UP,direction.normalized()))*Basis.from_scale(Vector3(r,direction.length(),r)),(a+b)/2)
static func pipe_mesh(n:Node3D,transforms:Array[Transform3D],color:String)->void:
	var cylinder:=CylinderMesh.new();cylinder.top_radius=1;cylinder.bottom_radius=1;cylinder.height=1;cylinder.radial_segments=16
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=cylinder;mm.instance_count=transforms.size()
	for i in transforms.size():mm.set_instance_transform(i,transforms[i])
	var node:=MultiMeshInstance3D.new();node.multimesh=mm;node.material_override=K.material(color,22);n.add_child(node)
