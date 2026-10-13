extends RefCounted
## Rear doors follow the registered 1F plan; outdoor dimensions remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const G:=2.24
static func openings()->Array:
	var out:Array=[]
	for v:float in [447.5,580.]:
		var z:float=P.world(924,v).z
		out.append(Vector2(z-3.25,z+3.25))
	return out
static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"StudentRearConnectedApronsV210")
	# Replace overlapping narrow/wide strips with one ground-following public walk.
	builder.ribbon(n,[[107.65,G,-420],[107.65,G,-366]],8.5,"818780",26,.102)
	# Outer infill closes the old lawn seam between footway and the road kerb.
	builder.ribbon(n,[[112.4,G,-420],[112.4,G,-372]],1.0,"8f958b",6,.106)
	for v:float in [447.5,580.]:
		var p:=P.world(924,v)
		builder.ribbon(n,[[p.x,G,p.z],[110.9,G,p.z]],3.3,"92988f",26,.132)
		# Fan out to the cut kerb. Fine sampling follows the terrain on both axes.
		var vertices:=PackedVector3Array()
		for i in 10:
			var a:float=110.9+i*.245;var b:float=a+.245
			var wa:float=lerpf(1.65,2.35,float(i)/10);var wb:float=lerpf(1.65,2.35,float(i+1)/10)
			vertices.append_array(K.quad(Vector3(a,builder.height(a,p.z-wa)+.136,p.z-wa),Vector3(b,builder.height(b,p.z-wb)+.136,p.z-wb),Vector3(b,builder.height(b,p.z+wb)+.136,p.z+wb),Vector3(a,builder.height(a,p.z+wa)+.136,p.z+wa)))
		K.surface(n,vertices,"92988f",26)
		# Sloping visual kerb terminals meet the flush mouth rather than a square end.
		for side:float in [-1,1]:
			var verts:=PackedVector3Array()
			for i in 6:
				var za:float=p.z+side*(2.35+i*.15);var zb:float=p.z+side*(2.35+(i+1)*.15)
				var ya:float=lerpf(.136,.166,float(i)/6);var yb:float=lerpf(.136,.166,float(i+1)/6)
				var a:=Vector3(112.755,builder.height(112.755,za)+ya,za);var b:=Vector3(113.005,builder.height(113.005,za)+ya,za)
				var c:=Vector3(113.005,builder.height(113.005,zb)+yb,zb);var d:=Vector3(112.755,builder.height(112.755,zb)+yb,zb)
				if side<0:verts.append_array(K.quad(d,c,b,a))
				else:verts.append_array(K.quad(a,b,c,d))
			K.surface(n,verts,"bdc1b7",6)
	# Short masonry border on building side; stop at both mapped door mouths.
	var holes:=openings();holes.reverse()
	var start:float=-420
	for hole:Vector2 in holes:
		builder.ribbon(n,[[103.55,G,start],[103.55,G,hole.x]],.16,"71786f",6,.111)
		start=hole.y
	builder.ribbon(n,[[103.55,G,start],[103.55,G,-371]],.16,"71786f",6,.111)
	# Ground decals must not cast tiny false shadows onto their underlying walk.
	for child in n.get_children():
		if child is MeshInstance3D:child.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	K.finish(n)
