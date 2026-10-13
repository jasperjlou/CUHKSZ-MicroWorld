extends RefCounted
## Historical architect photos + official panorama70040610 distinguish white cross-link
## from the tall shaded side galleries. World endpoints/upper-deck use remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
static func build(parent:Node3D,a:Vector3,c:Vector3)->void:
	var length:=Vector2(c.x-a.x,c.z-a.z).length()
	var cross_link:bool=is_equal_approx(a.x,56.0) and is_equal_approx(c.x,56.0)
	var n:=K.holder(parent,"WhitePondCrossLinkV212" if cross_link else "ShadedSideGalleryV212",(a+c)/2)
	n.rotation.y=atan2(c.x-a.x,c.z-a.z)
	K.box(n,Vector3(0,-.16,0),Vector3(4.4,.32,length),"b3b5aa",true,6)
	K.box(n,Vector3(0,-.34,0),Vector3(4.1,.08,length),"c3c8bf",false,22)
	# Independent longitudinal beams and transverse heads are visible from the ground walk.
	for side:float in [-1,1]:
		K.box(n,Vector3(side*1.7,-.53,0),Vector3(.27,.38,length),"c4c9c1",false,22)
	if not cross_link:
		K.box(n,Vector3(0,3.05,0),Vector3(4.7,.28,length+.2),"bfc2b8",true,18)
		for side:float in [-1,1]:
			K.box(n,Vector3(side*2.12,1.05,0),Vector3(.06,.065,length-5),"747569",false,11)
			for i in int(length/.42):
				var z:float=-length/2+(i+.5)*.42
				if absf(z)>length/2-2.5:continue
				# Warm vertical blades turn into an open horizontal shade below the gallery.
				K.box(n,Vector3(side*2.18,1.64,z),Vector3(.56,3.02,.085),"b5a27e",false,11)
				K.box(n,Vector3(side*2.94,-.27,z),Vector3(2.08,.16,.085),"b5a27e",false,11)
			K.box(n,Vector3(side*3.80,-.30,0),Vector3(.055,.12,length-5),"a69271",false,11)
	# Fitted low edge guards keep the retained upper route contained without recreating
	# an unsupported extra screened storey on the white cross-link. End junctions stay open.
	for side:float in [-1,1]:
		var guard:=K.holder(n,"UpperEdgeGuard")
		K.box(guard,Vector3(side*2.12,.55,0),Vector3(.065,1.10,length-5),"e0e1d8",true,22)
		if not cross_link:
			# Collision only behind the already visible fins; do not turn them into a white wall.
			guard.remove_meta("box_groups")
		else:
			# Thin black pickets/readable open guard, instead of an opaque extra floor.
			guard.remove_meta("box_groups")
			for h:float in [.12,1.08]:K.box(guard,Vector3(side*2.12,h,0),Vector3(.065,.065,length-5),"67736a",false,11)
			for i in int((length-5)/.2)+1:
				K.box(guard,Vector3(side*2.12,.60,-length/2+2.5+i*.2),Vector3(.035,.98,.035),"67736a",false,11)
			K.finish(guard)
	for i in int(length/9):
		var z:float=-length/2+4+i*9
		for side:float in [-1,1]:
			var p:=Vector3(side*1.7,-4.4,z)
			var site:Vector3=(a+c)/2+Basis(Vector3.UP,n.rotation.y)*p
			if site.x>28 and site.x<36 and site.z>-336 and site.z<-326:continue
			var h:float=4.05 if cross_link else 7.3
			K.box(n,p+Vector3.UP*h/2,Vector3(.48,h,.48),"c3c8bf",true,22)
			K.box(n,p+Vector3.UP*1.94,Vector3(.50,3.88,.50),"d4d7cf",false,22)
			# Modest base joint, not the temporary banners seen in panorama photos.
			K.box(n,p+Vector3.UP*.055,Vector3(.53,.11,.53),"a9afa6",false,26)
		K.box(n,Vector3(0,-.53,z),Vector3(3.65,.32,.27),"c4c9c1",false,22)
	for i in int(length/5):
		var z:float=-length/2+2.5+i*5
		K.box(n,Vector3(0,-.40,z),Vector3(.11,.065,.18),"b4b8ac",false,11)
		K.box(n,Vector3(0,-.44,z),Vector3(.10,.035,.13),"e4dfce",false,17)
		if not cross_link:K.box(n,Vector3(0,2.88,z),Vector3(.16,.055,1.6),"e2dfce",false,17)
	K.finish(n)
