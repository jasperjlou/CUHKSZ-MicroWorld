extends RefCounted
## V247: close the unsupported17cm below the existing .28m slab at F1=.45.
## The plinth follows the existing historical-plan footprint; dimensions remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const G=2.24
static func podium(b:Node3D)->void:
	var n:=K.holder(b,"ShawGroundPlinthV247")
	# Fill only below the retained slab underside, never across a door or stair tread.
	for x:float in [-33.90,33.90]:
		K.box(n,Vector3(x,.085,0),Vector3(.20,.17,58.6),"888c85",true,82)
	for z:float in [-29.20,29.20]:
		K.box(n,Vector3(0,.085,z),Vector3(67.6,.17,.20),"888c85",true,82)
	K.finish(n)
static func site(root:Node3D,builder)->void:
	var n:=K.holder(root,"ShawSouthWallApronV247")
	# Existing street paving stops short of the side wall in this retained site fit.
	# A narrow flush apron joins the side-door foot to it, without changing road/court grades.
	var verts:=PackedVector3Array()
	var cells:int=0
	for i in 111:
		var xa:float=55+i*.4;var xb:float=minf(99.3,xa+.4)
		if xb<=xa:continue
		for j in 4:
			var za:float=-575.6+j*.4;var zb:float=za+.4
			var ps:Array[Vector3]=[]
			for p:Vector2 in [Vector2(xa,za),Vector2(xb,za),Vector2(xb,zb),Vector2(xa,zb)]:
				ps.append(Vector3(p.x,builder.height(p.x,p.y)+.14,p.y))
			verts.append_array(K.quad(ps[0],ps[1],ps[2],ps[3]));cells+=1
	var mesh:=K.surface(n,verts,"979a92",53)
	mesh.set_meta("apron_cells",cells)
	K.finish(n)
