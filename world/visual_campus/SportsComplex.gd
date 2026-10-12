extends RefCounted
## V57: the coloured folded-roof bar beside the track is not University Sports Hall.
## Anniversary aerial and panoramas establish shape; all metre values are fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const C := preload("res://world/visual_campus/ConferenceCentre.gd")
const S := preload("res://world/visual_campus/LowerCampusLandscape.gd")
const E := preload("res://world/visual_campus/SportsOpenEnd.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")
const I := preload("res://world/visual_campus/SportsPublicInterior.gd")
const SECTION := preload("res://world/visual_campus/SportsSection.gd")
const U := preload("res://world/visual_campus/SportsUpperHall.gd")

static func roof_height(x: float) -> float:
	return SECTION.roof_height(x)

static func field_fin_color(x: float) -> String:
	if x < -45:return "c8bc3d"
	if x < -21:return "d88231"
	if x < 7:return "dab63c"
	return "cc922e"

static func build(b: Node3D) -> void:
	# A shallow, elongated three-level bar, with a genuinely open lower central passage.
	K.box(b,Vector3(0,-.14,0),Vector3(126,.28,32),"aab0a5",true,26)
	for y in [4.8,9.2]:
		E.slab(b,y)
		for z in [-16,16]:K.box(b,Vector3(0,y-.12,z),Vector3(126,.6,.35),"d0d5ca",false,22)
	for x in [-58,-42,-22,22,42,58]:
		for z in [-12,12]:K.column(b,Vector3(x,0,z),4.5,.5)
	# Coloured ground cores appear under the suspended gallery; keep the central crossing open.
	for x in [-31]:
		K.box(b,Vector3(x,2.15,1),Vector3(22,4.3,18),"bd9958",true,22)
		for i in 18:K.box(b,Vector3(x-10.5+i*1.23,2.15,-8.08),Vector3(.055,4.3,.04),"917440",false,11)
	for side in [-1,1]:
		if side<0:K.box(b,Vector3(side*61.8,2.18,0),Vector3(.35,4.36,31.8),"c4cbc1",true,22)
		if side<0:
			# V177 aerial: white opaque end band with only a narrow glazed return at the field corner.
			K.box(b,Vector3(-62.04,6.98,2),Vector3(.28,3.9,27.7),"ced3ca",true,22)
			C.glazing(b,Vector3(-62,6.98,-13.9),3.8,3.9,PI/2)
		if side<0:
			var top: float=roof_height(-62)-.45
			C.glazing(b,Vector3(-62,(9.2+top)/2,0),31.7,top-9.2,PI/2)
	# Flush hardscape covers the terrain beneath the pilotis and all the way to the field strip.
	K.box(b,Vector3(0,.074,-1.5),Vector3(142,.025,48.5),"a4aaa1",false,26)
	# First elevated floor: gallery outside the glazed room boundary, both long elevations.
	I.build(b)
	# V58: the centre slopes are a dipped viewing gallery, not stairs down to the track.
	for span: Vector2 in [Vector2(-62,-31),Vector2(31,62)]:
		P.rail(b,Vector3(span.x,4.8,-16),Vector3(span.y,4.8,-16))
	for i in 3:
		var xs: Array[float]=[-27,-17,17,27];var ys: Array[float]=[4.8,3.85,3.85,4.8]
		var a:=Vector3(xs[i],ys[i],-20);var c:=Vector3(xs[i+1],ys[i+1],-20)
		var n:=K.holder(b,"DippedViewingGallery",(a+c)/2);n.rotation.z=atan2(c.y-a.y,c.x-a.x)
		K.box(n,Vector3(0,-.18,0),Vector3(a.distance_to(c)+.04,.36,8),"bdc5ba",true,22);K.finish(n)
		P.rail(b,a+Vector3(0,0,-4),c+Vector3(0,0,-4))
		P.rail(b,a+Vector3(0,0,4),c+Vector3(0,0,4))
	P.rail(b,Vector3(-62,4.8,16),Vector3(62,4.8,16))
	# Upper glass follows the changing roof height. Narrow metal fins sit outside the glazing.
	for x in range(-61,62,2):
		var top: float=roof_height(x)-.5
		for z in [-15.5,15.5]:
			if x>33 and z<0:continue
			var low: float=11.4 if z>0 and x<33 else 9.2
			K.box(b,Vector3(x,(low+top)/2,z),Vector3(1.98,top-low,.10),"638580",true,19)
			if low>9.2:K.box(b,Vector3(x,10.3,z+.08),Vector3(2,2.2,.18),"d0d3ca",true,22)
			K.box(b,Vector3(x,(low+top)/2,z+signf(z)*.45),Vector3(.12,top-low,.62),field_fin_color(x) if z<0 else "78746b",false,11)
		if x < -15:
			K.box(b,Vector3(x,6.98,-15.75),Vector3(.26,3.9,.62),["b78b3c","b76145","8a956c"][posmod(x,3)],false,11)
	for i in 186:
		var x: float=-61.5+i*.665;var top: float=roof_height(x)-.35
		for z in [-15.9,15.9]:
			if x>33 and z<0:continue
			K.box(b,Vector3(x,(11+top)/2,z),Vector3(.09,top-11,.62),field_fin_color(x) if z<0 else "726d65",false,11)
	# Campus-side photograph has pale wall bays interrupted by tall strips, not the field's all-glass band.
	for x in range(-59,33,4):
		K.box(b,Vector3(x,6.95,15.82),Vector3(2.7,4.1,.18),"cfd3c9",true,22)
		K.box(b,Vector3(x,4.98,15.95),Vector3(2.7,.16,.18),"b4beb4",false,11)
	# The aerial visibly shows yellow/orange/red roofs, not a uniform grey sports-hall roof.
	var segments: Array[Vector2]=[Vector2(-63,-25),Vector2(-25,5),Vector2(5,22),Vector2(22,63)]
	var colors: Array[String]=["d5b13f","d18e28","cc7840","b85d4a"]
	for i in segments.size():
		var a:=Vector3(segments[i].x,roof_height(segments[i].x),0)
		var c:=Vector3(segments[i].y,roof_height(segments[i].y),0)
		var roof:=K.holder(b,"ColouredFoldedRoof",(a+c)/2);roof.rotation.z=atan2(c.y-a.y,c.x-a.x)
		K.box(roof,Vector3.ZERO,Vector3(a.distance_to(c)+.06,.35,33.5),colors[i],true,18)
		K.box(roof,Vector3(0,-.19,0),Vector3(a.distance_to(c),.03,33.4),"898d82",false,22)
		for z in [-16.75,16.75]:K.box(roof,Vector3(0,-.18,z),Vector3(a.distance_to(c)+.10,.55,.20),"c4ccc2",false,11)
		for x in range(0,ceili(a.distance_to(c)),2):K.box(roof,Vector3(-a.distance_to(c)/2+x,.20,0),Vector3(.045,.07,33.4),colors[i],false,11)
		K.finish(roof)
	for x in [-29,29]:K.box(b,Vector3(x,4.62,-19),Vector3(4,.36,6),"b9c2b9",true,22)
	for side in [-1,1]:
		P.rail(b,Vector3(side*27,4.8,-24),Vector3(side*27,4.8,-22))
		P.rail(b,Vector3(side*27,4.8,-22),Vector3(side*31,4.8,-22))
		P.rail(b,Vector3(side*31,4.8,-22),Vector3(side*31,4.8,-16))
	E.build(b)
	U.build(b)
	preload("res://world/visual_campus/SportsUndercroft.gd").build(b)
	preload("res://world/visual_campus/SportsWhitePlinth.gd").build(b)
	# Lower forecourts, white cycle canopy and side strips join both separate buildings.
	S.paving(b,Vector3(0,0,22),Vector2(142,12))
	S.paving(b,Vector3(0,0,-24.4),Vector2(142,5.2))
	for x in [-67,67]:S.paving(b,Vector3(x,0,0),Vector2(8,44))
	S.drain(b,Vector3(0,0,-26.6),126)
	# V62 perpendicular Hall: connect its hillside-facing portal to this campus-side forecourt.
	preload("res://world/visual_campus/SportsLinkCanopy.gd").build(b)
	for x in [-51,-41,43,53]:K.bench(b,Vector3(x,0,20),PI)
