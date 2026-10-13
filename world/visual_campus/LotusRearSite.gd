extends RefCounted
## Pond screen sits on the water bank; rear walk and avenue must remain separate.
## 2024 photo / undated official panorama support relation, not surveyed grades.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const G:=2.24
static func fitted_height(x:float,z:float,base:float)->float:
	if x<=112 or x>=126 or z<=-369 or z>=-329:return base
	var across:float=smoothstep(112,116,x)*(1-smoothstep(122,126,x))
	var along:float=smoothstep(-369,-363,z)*(1-clampf((z+337)/8.0,0,1))
	return lerpf(base,G,across*along)
static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"LotusRearDryWalkV211")
	var vertices:=PackedVector3Array()
	for z in range(-365,-329):
		for i in 11:
			var x:float=116.5+i*.5;var xx:float=x+.5
			vertices.append_array(K.quad(Vector3(x,builder.height(x,z)+.10,z),Vector3(xx,builder.height(xx,z)+.10,z),Vector3(xx,builder.height(xx,z+1)+.10,z+1),Vector3(x,builder.height(x,z+1)+.10,z+1)))
	K.surface(n,vertices,"747c78",53).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Close the fitted grade flank with an engineered stone face, not exposed turf.
	var flank:=PackedVector3Array()
	for z in range(-355,-336):
		for i in 8:
			var x:float=122+i*.5;var xx:float=x+.5
			flank.append_array(K.quad(Vector3(x,builder.height(x,z)+.12,z),Vector3(xx,builder.height(xx,z)+.12,z),Vector3(xx,builder.height(xx,z+1)+.12,z+1),Vector3(x,builder.height(x,z+1)+.12,z+1)))
	K.surface(n,flank,"898e84",15).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Seats stay beside the screen, not on the vehicle lane. Their exact location is fitted.
	for z:float in [-345,-353]:K.bench(n,Vector3(117.25,builder.height(117.25,z)+.1,z),PI/2)
	for z:float in [-339,-364]:
		var p:=Vector3(117.5,builder.height(117.5,z),z)
		K.box(n,p+Vector3.UP*.09,Vector3(1.1,.18,1.1),"71766d",false,6)
		K.tree(n,p+Vector3.UP*.15,7.2,21100+absi(int(z)))
	builder.ribbon(n,[[121.8,G,-363],[121.8,G,-337]],.18,"535e57",11,.115)
	K.finish(n)
