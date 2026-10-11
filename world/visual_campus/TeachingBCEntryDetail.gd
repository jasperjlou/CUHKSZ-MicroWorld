extends RefCounted
## V121: narrow bronze entrance awnings and stone aprons from the anniversary
## teaching-row photograph and official B/C panoramas. Dimensions remain fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const Site := preload("res://world/visual_campus/LowerCampusLandscape.gd")

static func build(b: Node3D,r: Dictionary) -> void:
	var n:=K.holder(b,"TeachingBCEntranceFinish")
	var front: float=float(r.depth)*.46
	var door_x: float=-13.0 if r.id=="teaching_b" else float(r.width)*.25
	var screen_z: float=front+.38 if r.id=="teaching_b" else front+2.48
	# Small sloping awning, not a full-width canopy masking the hanging screen.
	var awning:=K.holder(n,"BronzeEntranceAwning",Vector3(door_x,3.50,screen_z+1.14))
	awning.rotation.x=.14
	if r.id=="teaching_c":
		# Observed l face: gaps between timber slats, carried by a dark perimeter.
		for z in [-1.36,1.36]:K.box(awning,Vector3(0,0,z),Vector3(6.3,.13,.09),"535b55",false,11)
		for x in [-3.1,3.1]:K.box(awning,Vector3(x,0,0),Vector3(.09,.13,2.8),"535b55",false,11)
		for i in 25:K.box(awning,Vector3(-2.98+i*5.96/24,.04,0),Vector3(.105,.08,2.68),"a88657",false,11)
	else:
		K.box(awning,Vector3.ZERO,Vector3(6.2,.10,2.8),"a57d48",false,11)
		K.box(awning,Vector3(0,-.015,1.39),Vector3(6.3,.17,.11),"85643b",false,11)
		for i in 22:
			K.box(awning,Vector3(-3.0+i*6.0/21,.057,0),Vector3(.025,.022,2.8),"ba955e",false,11)
	for side in [-1,1]:
		K.box(awning,Vector3(side*2.75,-.13,0),Vector3(.06,.20,2.75),"5d625a",false,11)
	K.finish(awning)
	for side in [-1,1]:
		var a:=Vector3(door_x+side*2.75,4.35,screen_z-.20)
		var c:=Vector3(door_x+side*2.75,3.30,screen_z+2.20)
		var brace:=K.holder(n,"AwningSuspension",(a+c)/2)
		brace.rotation.x=-atan2(c.y-a.y,c.z-a.z)
		K.box(brace,Vector3.ZERO,Vector3(.045,.045,a.distance_to(c)),"63675e",false,11)
		K.finish(brace)
	# Continue the real hard paving to the apron. Keep long strips inside C's arcade.
	var apron_start: float=front+3.33 if r.id=="teaching_c" else front
	var apron_mid: float=(apron_start+front+8)/2
	var apron_depth: float=front+8-apron_start
	K.box(n,Vector3(door_x,.112,apron_mid),Vector3(7,.025,apron_depth),"aba99f",false,42)
	for side in [-1,1]:
		K.box(n,Vector3(door_x+side*3.55,.112,apron_mid),Vector3(.15,.026,apron_depth),"858b85",false,40)
	Site.drain(n,Vector3(door_x,.081,front+7.8),7.2)
	# Flush framed access cover, visible in the aerial paving, without a raised collider.
	K.box(n,Vector3(door_x+5.0,.109,front+5.5),Vector3(.72,.024,.72),"737b74",false,11)
	K.box(n,Vector3(door_x+5.0,.124,front+5.5),Vector3(.63,.010,.63),"a19f95",false,42)
	K.finish(n)
