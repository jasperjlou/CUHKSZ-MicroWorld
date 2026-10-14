extends RefCounted
## Graffiti-wall panorama: battered concrete bank, narrow inset stair, toe drain and planting.
## Relative roadside structure is observed; dimensions/placement fitted to retained library anchors.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const G := 2.24
const STAIR_Z := -313.0
const BANK_MIN := -340
const BANK_MAX := -232
const RISE := 3.4
const RUN := 4.2

static func road_x(z: float,points: Array) -> float:
	for i in range(points.size()-1):
		var a: Array=points[i];var c: Array=points[i+1]
		if z<=a[2] and z>=c[2]:return lerpf(a[0],c[0],inverse_lerp(a[2],c[2],z))
	return 110.0

static func toe(z: float,points: Array) -> float:
	return road_x(z,points)+4.4

static func weight(z: float) -> float:
	return smoothstep(BANK_MIN,BANK_MIN+12,z)*(1.0-smoothstep(BANK_MAX-15,BANK_MAX,z))

static func road_height(z: float) -> float:
	return preload("res://world/visual_campus/LibraryRearRoad.gd").rear_avenue_height(z)

static func fitted_height(x: float,z: float,base: float,points: Array) -> float:
	if z<=BANK_MIN or z>=BANK_MAX or x<100 or x>195:return base
	var edge:=toe(z,points)
	if x<=edge:return base
	var t:=clampf((x-edge)/RUN,0,1)
	var raised: float=road_height(z)+RISE*t
	# Recess soil beneath the concrete toe: interpolated terrain cells must not
	# cut through its face. The upper garden and landing retain their elevation.
	var inset: float=.45*(1.0-smoothstep(.1,.55,t))
	if absf(z-STAIR_Z)<.85 and x<toe(STAIR_Z,points)+RUN+1.4:
		raised=road_height(STAIR_Z)+RISE*clampf((x-toe(STAIR_Z,points))/RUN,0,1)
		inset=.20
	return lerpf(base,maxf(base,raised)-inset,weight(z))

static func stair(root: Node3D,points: Array) -> void:
	var x0:=toe(STAIR_Z,points);var x1:=x0+RUN;var ground:=road_height(STAIR_Z)
	for i in 20:
		var h: float=RISE*(i+1)/20
		var x: float=x0+RUN*(i+.5)/20
		K.box(root,Vector3(x,ground+h/2,STAIR_Z),Vector3(RUN/20+.012,h,1.22),"b4ae9b",false,82)
	var ramp:=K.surface(root,K.quad(Vector3(x0,ground+.025,STAIR_Z-.61),Vector3(x0,ground+.025,STAIR_Z+.61),Vector3(x1,ground+RISE+.025,STAIR_Z+.61),Vector3(x1,ground+RISE+.025,STAIR_Z-.61)),"b4ae9b",82,true);ramp.visible=false
	K.box(root,Vector3(x1+.7,ground+RISE-.045,STAIR_Z),Vector3(1.4,.14,1.6),"adaf9f",false,82)
	K.surface(root,K.quad(Vector3(x1,ground+RISE+.025,STAIR_Z-.8),Vector3(x1,ground+RISE+.025,STAIR_Z+.8),Vector3(x1+1.4,ground+RISE+.025,STAIR_Z+.8),Vector3(x1+1.4,ground+RISE+.025,STAIR_Z-.8)),"adaf9f",82,true)
	# No invented continuous uphill route beyond the visible top landing.
	for side in [-1,1]:
		var z: float=STAIR_Z+side*.72
		K.surface(root,K.quad(Vector3(x0,ground+.08,z-.09),Vector3(x0,ground+.08,z+.09),Vector3(x1,ground+RISE+.08,z+.09),Vector3(x1,ground+RISE+.08,z-.09)),"b7b3a2",82,true)

static func build(root: Node3D,builder) -> void:
	var b:=K.holder(root,"LibraryRearGraffitiBank");var points: Array=builder.rear_route
	# Split at the stair opening so concrete never seals the passage.
	var zs: Array[float]=[]
	for z in range(BANK_MIN,BANK_MAX+1,2):zs.append(float(z))
	for z in [STAIR_Z-.61,STAIR_Z+.61]:zs.append(z)
	zs.sort()
	var stone:=PackedVector3Array();var blue:=PackedVector3Array();var peach:=PackedVector3Array()
	for i in range(zs.size()-1):
		var za: float=zs[i];var zc: float=zs[i+1]
		if absf((za+zc)/2-STAIR_Z)<.61:continue
		var a:=Vector3(toe(za,points),road_height(za)+.03,za);var c:=Vector3(toe(zc,points),road_height(zc)+.03,zc)
		var at:=a+Vector3(RUN,RISE*weight(za),0);var ct:=c+Vector3(RUN,RISE*weight(zc),0)
		stone.append_array(K.quad(a,c,ct,at))
		# Broad observed turquoise / warm base tones; artwork itself is deliberately not claimed current.
		var shift:=Vector3(-.045,.095,0)
		peach.append_array(K.quad(a+shift,c+shift,c.lerp(ct,.22)+shift,a.lerp(at,.22)+shift))
		blue.append_array(K.quad(a.lerp(at,.22)+shift,c.lerp(ct,.22)+shift,ct+shift,at+shift))
	# Keep the existing wall collider. Its coarse visible triangulation crossed the
	# separate colour-band meshes at grade transitions, exposing pale triangles.
	var backing:=K.surface(b,stone,"a8aaa1",15,true);backing.visible=false
	K.surface(b,peach,"9d7c63",22);K.surface(b,blue,"4c8583",22)
	stair(b,points)
	# Groundcover behind the crest; keep the stair's top landing open.
	for z in range(BANK_MIN+10,BANK_MAX-8,4):
		if absf(z-STAIR_Z)<3:continue
		var x:=toe(z,points)+RUN+1.8
		V.shrub(b,Vector3(x,builder.height(x,z),z),Vector3(2.6,1.0,3.6),abs(z)+1700)
		if z%12==-10:K.tree(b,Vector3(x+4,builder.height(x+4,z),z),9.5,abs(z)+340)
	# Student rear paving is authored beside its V49 outline in LibraryRearRoad.
	# V194 owns the actual covered roof and its graded brick waiting pad.
	K.finish(b)
