extends RefCounted
## V174: school opening photo2023 and photographer59-61 published2026-03-06.
## Lower white end enclosure, perforated coloured wedges and exposed soffit structure.
## Locations/dimensions fitted; no invented access through closed service rooms.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")

static func beam(n:Node3D,a:Vector3,b:Vector3,w:float=.16)->void:
	var h:=K.holder(n,"UndercroftSteelMember",(a+b)/2);h.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
	K.box(h,Vector3.ZERO,Vector3(w,a.distance_to(b),w),"9aa59d",false,11);K.finish(h)

static func perforated_wedge(n:Node3D,base_x:float,tip_x:float,color:String)->void:
	var z:float=-8.24;var top:float=4.42
	var domain:=PackedVector2Array([Vector2(base_x,0),Vector2(base_x,top),Vector2(tip_x,top)])
	var vertices:=PackedVector3Array()
	# Intersect each small frame with the triangular outline. Real holes remain between strips.
	var low:=minf(base_x,tip_x);var high:=maxf(base_x,tip_x)
	for ix in ceili((high-low)/.38):
		for iy in ceili(top/.38):
			var x:float=low+ix*.38;var y:float=iy*.38
			for strip:PackedVector2Array in [PackedVector2Array([Vector2(x,y),Vector2(x+.045,y),Vector2(x+.38,y+.38),Vector2(x+.335,y+.38)]),PackedVector2Array([Vector2(x+.335,y),Vector2(x+.38,y),Vector2(x+.045,y+.38),Vector2(x,y+.38)])]:
				for polygon:PackedVector2Array in Geometry2D.intersect_polygons(strip,domain):
					var indices:=Geometry2D.triangulate_polygon(polygon)
					for j in range(0,indices.size(),3):
						var a:=Vector3(polygon[indices[j]].x,polygon[indices[j]].y,z)
						var b:=Vector3(polygon[indices[j+1]].x,polygon[indices[j+1]].y,z)
						var c:=Vector3(polygon[indices[j+2]].x,polygon[indices[j+2]].y,z)
						vertices.append_array(PackedVector3Array([a,b,c,c,b,a]))
	K.surface(n,vertices,color,22)
	var a:=Vector3(base_x,0,z);var b:=Vector3(base_x,top,z);var c:=Vector3(tip_x,top,z)
	var collision:=K.surface(n,PackedVector3Array([a,b,c,c,b,a]),color,22,true);collision.visible=false
	beam(n,a,c,.12);beam(n,b,c,.12)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"SportsUndercroftV174")
	# The far end is a white closed lower wing in the built photograph, not a full-width arcade.
	K.box(n,Vector3(-52.5,2.22,0),Vector3(20.6,4.44,31.7),"d0d4ca",true,22)
	for x in range(-62,-42,4):K.box(n,Vector3(x,2.22,-15.87),Vector3(.018,4.44,.015),"a3afa5",false,22)
	for y:float in [1.48,2.96]:K.box(n,Vector3(-52.5,y,-15.88),Vector3(20.6,.02,.015),"a8b2a8",false,22)
	# Small closed vent in the photographed blank wall; no unsupported entrance.
	K.box(n,Vector3(-54,2.7,-15.9),Vector3(.8,.95,.055),"707f75",false,11)
	for j in 7:K.box(n,Vector3(-54,2.31+j*.13,-15.95),Vector3(.77,.035,.10),"9ba89c",false,11)
	perforated_wedge(n,42,53,"398cab")
	perforated_wedge(n,20,9,"b5b74d")
	perforated_wedge(n,-20,-9,"8e6295")
	# Lower core faces have panel seams and closed small field-side service doors.
	for center:float in [-31,31]:
		for x in range(-10,11,2):K.box(n,Vector3(center+x,2.18,-8.22),Vector3(.02,4.3,.024),"92816b",false,22)
		K.box(n,Vector3(center,1.14,-8.26),Vector3(1.20,2.28,.06),"505f59",false,11)
		for x:float in [-.64,.64]:K.box(n,Vector3(center+x,1.16,-8.31),Vector3(.06,2.32,.10),"b6b5a4",false,22)
		K.box(n,Vector3(center,2.32,-8.31),Vector3(1.34,.08,.10),"b6b5a4",false,22)
	# Exposed beams/trusses remain above the ground routes and below the real floor slabs.
	for z:float in [-14,-5,5,14]:
		beam(n,Vector3(-19,4.28,z),Vector3(19,4.28,z),.20)
		for x in [-18,-6,6]:
			beam(n,Vector3(x,3.72,z),Vector3(x+6,4.28,z),.12)
			beam(n,Vector3(x+6,4.28,z),Vector3(x+12,3.72,z),.12)
	for x:float in [-15,-5,5,15]:beam(n,Vector3(x,4.32,-15),Vector3(x,4.32,15),.16)
	# Under the dipped balcony the steel follows its lower soffit, preserving clear ground passage.
	for x in range(-15,16,5):beam(n,Vector3(x,3.38,-23),Vector3(x,3.38,-16),.14)
	# Hard paving and narrow drainage link the inter-hall court to the field gate.
	K.box(n,Vector3(10,.093,-3),Vector3(6,.018,44),"b1b2a6",false,26)
	for x:float in [6.8,13.2]:K.box(n,Vector3(x,.107,-3),Vector3(.12,.016,44),"5c6961",false,22)
	for z in range(-22,20,3):K.box(n,Vector3(10,.107,z),Vector3(6,.012,.055),"8e978c",false,22)
	K.finish(n)
