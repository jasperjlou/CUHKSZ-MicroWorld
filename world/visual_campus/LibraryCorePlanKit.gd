extends RefCounted
## Bake plan dimensions into primitives; never non-uniformly scale a physics-body ancestor.
const Base=preload("res://world/visual_campus/VisualCampusKit.gd")
static func factor(n:Node3D)->Vector3:return n.get_meta("core_plan_scale",Vector3.ONE)
static func holder(parent:Node3D,id:String,p:Vector3=Vector3.ZERO)->Node3D:
	var n=Base.holder(parent,id,p*factor(parent));n.set_meta("core_plan_scale",factor(parent));return n
static func box(n:Node3D,p:Vector3,size:Vector3,hex:String="b9bcb6",solid:bool=false,kind:int=0,yaw:float=0)->void:
	Base.box(n,p*factor(n),size*factor(n),hex,solid,kind,yaw)
static func label(n:Node3D,text:String,p:Vector3,pixel_size:float=.006)->Label3D:
	return Base.label(n,text,p*factor(n),pixel_size)
static func finish(n:Node3D)->void:Base.finish(n)
