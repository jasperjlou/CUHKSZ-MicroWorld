extends RefCounted
## V231: built301 photos016/017 establish a glazed top and perimeter gallery.
## Opening footprint inherited from V222/031 fit; shaft through5F/6F is provisional,
## not independent as-built floor evidence. All affected slabs share one exact polygon.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const R=preload("res://world/visual_campus/StudentThirdRooms.gd")
const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const RAW=[612.,709.,508.,636.]
const GLASS_Y=16.22
const SHAFT_TOP=23.55

static func outline()->PackedVector2Array:
	var out:=PackedVector2Array()
	for q in [[RAW[0],RAW[2]],[RAW[1],RAW[2]],[RAW[1],RAW[3]],[RAW[0],RAW[3]]]:
		var p:=R.point(q[0],q[1],0);out.append(Vector2(p.x,p.z))
	return out

static func cut(parts:Array[PackedVector2Array])->Array[PackedVector2Array]:
	return Plan.subtract(parts,outline())

static func beam(n:Node3D,a:Vector3,b:Vector3,width:float,height:float,color:String,solid:bool=false)->void:
	var d:=b-a
	K.box(n,(a+b)/2,Vector3(d.length(),height,width),color,solid,22,-atan2(d.z,d.x))

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentHallSkylightV231")
	var poly:=outline();var centre:=Vector2.ZERO
	for p in poly:centre+=p
	centre/=poly.size()
	# White returns close each cut slab from hall ceiling to the open roof.
	# Offset outward so the shared fitted polygon is clear; solid boundaries protect upper users.
	for i in poly.size():
		var a:=poly[i];var b:=poly[(i+1)%poly.size()]
		var normal:=Vector2((b-a).y,-(b-a).x).normalized()
		if normal.dot((a+b)/2-centre)<0:normal=-normal
		var aa:=Vector3(a.x+normal.x*.10,0,a.y+normal.y*.10)
		var bb:=Vector3(b.x+normal.x*.10,0,b.y+normal.y*.10)
		beam(n,aa+Vector3.UP*((15.61+SHAFT_TOP)/2),bb+Vector3.UP*((15.61+SHAFT_TOP)/2),.20,SHAFT_TOP-15.61,"d5d7cc",true)
		beam(n,aa+Vector3.UP*SHAFT_TOP,bb+Vector3.UP*SHAFT_TOP,.34,.10,"b8c1b9")
	# V232: photo016/017 shows deep white blades and fine glazing subdivisions.
	# These are finish geometry; keep the V231 glass collider and provisional shaft.
	var glass:=K.surface(n,Plan.floor_vertices([poly],GLASS_Y),"bccfd0",19,true)
	glass.name="HallSkylightGlass";glass.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var glazing:StandardMaterial3D=glass.material_override.duplicate()
	glazing.albedo_color=Color(.80,.85,.84,.34);glazing.roughness=.38
	glass.material_override=glazing
	for i in 11:
		var u:float=lerpf(RAW[0],RAW[1],i/10.)
		beam(n,R.point(u,RAW[2],GLASS_Y-.34),R.point(u,RAW[3],GLASS_Y-.34),.075,.62,"d4d6cc")
		beam(n,R.point(u,RAW[2],GLASS_Y-.66),R.point(u,RAW[3],GLASS_Y-.66),.10,.035,"b9c0b9")
		# Narrow top channel and repeated bracket plates support the daylight blades.
		beam(n,R.point(u,RAW[2],GLASS_Y-.035),R.point(u,RAW[3],GLASS_Y-.035),.09,.045,"a5b3b0")
		for j in range(1,8):
			var v:float=lerpf(RAW[2],RAW[3],j/8.)
			beam(n,R.point(u-1.1,v,GLASS_Y-.13),R.point(u+1.1,v,GLASS_Y-.13),.06,.16,"9daaa7")
	for j in range(9):
		var v:float=lerpf(RAW[2],RAW[3],j/8.)
		beam(n,R.point(RAW[0],v,GLASS_Y-.015),R.point(RAW[1],v,GLASS_Y-.015),.04,.055,"a7b5b1")
	# White inner curb and slim sill close the rough glazing-to-wall joint.
	for i in poly.size():
		var a:=poly[i];var b:=poly[(i+1)%poly.size()]
		beam(n,Vector3(a.x,15.72,a.y),Vector3(b.x,15.72,b.y),.14,.22,"d5d7cc")
	# Roof curb guards the open shaft; no unguarded new holes on occupied upper levels.
	for i in poly.size():
		var a:=poly[i];var b:=poly[(i+1)%poly.size()]
		beam(n,Vector3(a.x,24.29,a.y),Vector3(b.x,24.29,b.y),.045,.065,"74827b",true)
		var count:=maxi(1,ceili(a.distance_to(b)/1.2))
		for j in range(count+1):
			var q:=a.lerp(b,float(j)/count)
			K.box(n,Vector3(q.x,23.90,q.y),Vector3(.04,.78,.04),"74827b",false,11)
		beam(n,Vector3(a.x,23.90,a.y),Vector3(b.x,23.90,b.y),.06,.78,"b8c5be",true)
	var light:=OmniLight3D.new();light.position=R.point((RAW[0]+RAW[1])/2,(RAW[2]+RAW[3])/2,15.10)
	light.light_color=Color("edf1e8");light.light_energy=.55;light.omni_range=13;light.shadow_enabled=false;n.add_child(light)
	n.set_meta("fit_limits","V232 photo016/017 deep blades and pane joints; dimensions fitted; V231 upper shaft depth remains unverified, no6F as-built plan")
	K.finish(n)
