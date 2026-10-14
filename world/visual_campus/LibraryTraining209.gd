extends RefCounted
## V227: official209 photo + current training-room page. Photo capture date unknown.
## Six rows of ten chairs and two screens are documented; metric layout is fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
static func size()->Vector2:
	return Vector2(P.point2(326,250).distance_to(P.point2(463,250)),P.point2(326,250).distance_to(P.point2(326,420)))
static func local_point(x:float,y:float,z:float)->Vector3:
	var along:Vector3=(P.point2(327,250)-P.point2(326,250)).normalized()
	return P.point2(326,250,4.4)+Basis(Vector3.UP,-atan2(along.z,along.x))*Vector3(x,y,z)
static func rod(n:Node3D,a:Vector3,b:Vector3,width:float,color:String)->void:
	var h:=K.holder(n,"TrainingChairTube",(a+b)/2);h.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
	K.box(h,Vector3.ZERO,Vector3(width,a.distance_to(b),width),color,false,11);K.finish(h)
static func chair(n:Node3D,p:Vector3)->void:
	var h:=K.holder(n,"TrainingChair209",p)
	h.add_to_group("library-training209-chairs")
	K.box(h,Vector3(0,.46,0),Vector3(.48,.095,.43),"703957",true,25)
	K.box(h,Vector3(0,.77,.215),Vector3(.46,.48,.045),"a4ada5",true,22)
	for side in [-1,1]:
		rod(h,Vector3(side*.26,.10,-.25),Vector3(side*.24,.71,.14),.027,"717b78")
		rod(h,Vector3(side*.26,.10,.29),Vector3(side*.24,.46,-.12),.027,"717b78")
		rod(h,Vector3(side*.245,.48,.20),Vector3(side*.245,1.01,.245),.024,"7c8782")
		K.box(h,Vector3(side*.272,.68,-.015),Vector3(.065,.065,.40),"454b49",false,22)
		for z in [-.25,.29]:K.box(h,Vector3(side*.26,.06,z),Vector3(.075,.08,.09),"414846",false,22)
	rod(h,Vector3(-.24,.28,.20),Vector3(.24,.28,.20),.023,"77837b")
	K.finish(h)
static func panel_wall(n:Node3D,origin:Vector3,length:float,yaw:float,back_door:Vector2=Vector2(-10,-9))->void:
	var h:=K.holder(n,"TrainingAcousticPanels",origin);h.rotation.y=yaw
	var count:=ceili(length/1.12);var pitch:float=length/count
	for row in 6:
		for col in count:
			var x0:float=col*pitch+.008;var x1:float=(col+1)*pitch-.008
			var spans:Array=[Vector2(x0,x1)]
			if row*.55<2.65 and x1>back_door.x and x0<back_door.y:
				spans=[]
				if x0<back_door.x:spans.append(Vector2(x0,back_door.x))
				if x1>back_door.y:spans.append(Vector2(back_door.y,x1))
			var tint:String="d7d8c9"
			if (row==1 and col%6==3) or (row==4 and col%7==0):tint="6d8761"
			if (row==2 and col%7==1) or (row==5 and col%8==5):tint="b47c48"
			for span:Vector2 in spans:K.box(h,Vector3((span.x+span.y)/2,.08+(row+.5)*.55,0),Vector3(span.y-span.x,.535,.035),tint,false,22)
	K.finish(h)
static func build(parent:Node3D)->void:
	var d:=size();var along:Vector3=(P.point2(327,250)-P.point2(326,250)).normalized()
	var n:=K.holder(parent,"LibraryTraining209V227",P.point2(326,250,4.4));n.rotation.y=-atan2(along.z,along.x)
	# Existing slab remains the physical floor; fine carpet finish has no stone joints.
	K.box(n,Vector3(d.x/2,.012,d.y/2),Vector3(d.x-.20,.020,d.y-.20),"969b90",false,25)
	panel_wall(n,Vector3(.11,0,.11),d.x-.22,0)
	panel_wall(n,Vector3(.11,0,d.y-.11),d.y-.22,PI/2)
	panel_wall(n,Vector3(d.x-.11,0,.11),d.y-.22,-PI/2)
	var door_x:float=(435.0-326.0)/(463.0-326.0)*d.x
	panel_wall(n,Vector3(.11,0,d.y-.11),d.x-.22,0,Vector2(door_x-.80-.11,door_x+.80-.11))
	K.box(n,Vector3(d.x/2,3.46,d.y/2),Vector3(d.x-.20,.10,d.y-.20),"d4d7cc",true,22)
	# Use the longer plan dimension for ten chair columns. Furniture orientation is
	# fitted, not surveyed; do not change the registered room or player capsule.
	var fit:=K.holder(n,"Training209Fitout",Vector3(0,0,d.y));fit.rotation.y=PI/2
	var width:float=d.y
	for z in [1.0,2.8,4.6,6.4]:
		for x in [width*.26,width*.74]:
			K.box(fit,Vector3(x,3.398,z),Vector3(2.32,.035,.20),"f1f0df",false,17)
		K.box(fit,Vector3(width/2,3.398,z),Vector3(1.15,.035,.18),"707a72",false,11)
		for k in 8:K.box(fit,Vector3(width/2-.50+k*.14,3.375,z),Vector3(.025,.02,.18),"b1bbb1",false,11)
	for x in [width*.26,width*.74]:
		K.box(fit,Vector3(x,2.85,.18),Vector3(2.50,.095,.12),"7f8880",false,11)
		K.box(fit,Vector3(x,2.03,.175),Vector3(2.46,1.55,.035),"e1e3d9",false,22)
		K.box(fit,Vector3(x,3.23,3.05),Vector3(.04,.35,.04),"929e94",false,11)
		K.box(fit,Vector3(x,3.03,3.05),Vector3(.40,.16,.30),"cbd0c7",false,22)
		K.box(fit,Vector3(x+.10,3.02,2.88),Vector3(.10,.07,.045),"394b50",false,19)
	#5+5 columns leave a central aisle; rear aisle connects the offset room entrance.
	for row in 6:
		for col in 10:
			var x:float=1.45+col*.61 if col<5 else width-1.45-(9-col)*.61
			chair(fit,Vector3(x,.02,2.15+row*.70))
	# Rounded wheeled lectern seen in the photo; location is fitted to the front aisle.
	var lectern:=K.holder(fit,"TrainingLectern",Vector3(2.0,0,.55))
	preload("res://world/visual_campus/LibraryLobbyDetail.gd").cylinder(lectern,Vector3(0,.60,0),.31,1.10,"424947",true)
	preload("res://world/visual_campus/LibraryLobbyDetail.gd").cylinder(lectern,Vector3(0,1.18,0),.49,.07,"b09a74")
	for x in [-.29,.29]:
		for z in [-.22,.22]:K.box(lectern,Vector3(x,.07,z),Vector3(.09,.10,.10),"434b46",false,22)
	K.finish(lectern)
	K.finish(fit)
	# Sixteen spare tables are movable; do not pretend all occupy a fixed observed location.
	for z in [2.6,6.6]:
		var light:=OmniLight3D.new();light.position=Vector3(d.x/2,3.1,z);light.light_color=Color("f2f2e8");light.light_energy=.65;light.omni_range=7;light.shadow_enabled=false;n.add_child(light)
	n.set_meta("chairs",60);n.set_meta("source","official209 room photo; capture date unknown; current page6x10chairs2screens")
	K.finish(n)
