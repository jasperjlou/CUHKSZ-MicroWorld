extends RefCounted
## Architect establishes a 4.5m difference; extent and transition curves are fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const G:=2.24
## Occupied 1F lies in front of the hatched retained-earth strip in the published plan.
## Leave the 2F rear court and vehicle road grade intact; the podium supplies the floor.
static func cutout(x:float,z:float)->bool:
	return x>55 and x<99.71 and z> -574 and z< -506
static func terrain_breaks()->Dictionary:
	return {"x":[55.0,99.71],"z":[-574.0,-506.0]}
static func profile(z: float) -> float:
	return smoothstep(-575,-557,z)*(1.0-smoothstep(-500,-475,z))
static func fitted_height(x: float,z: float,base: float) -> float:
	if x<94 or x>175 or z<=-575 or z>=-475:return base
	var across:=smoothstep(99.3,99.7,x)*(1.0-smoothstep(145,175,x))
	across=preload("res://world/visual_campus/ShawPromenade.gd").height_blend(x,z,across)
	return base+4.5*profile(z)*across
static func build(root: Node3D,builder) -> void:
	var b:=K.holder(root,"ShawEastRearGradeV51")
	# Back court sits at the higher outdoor grade and joins the rear road.
	builder.ribbon(b,[[117,6.74,-553],[117,6.74,-506]],6.5,"9b9e96",26,.085)
	builder.ribbon(b,[[114,6.74,-533.2],[124.5,6.74,-533.2]],6,"9b9e96",26,.090)
	for z in range(-556,-504,2):
		K.box(b,Vector3(99.5,G+2.25,z),Vector3(.42,4.5,2.02),"747d75",true,22)
	K.finish(b)
