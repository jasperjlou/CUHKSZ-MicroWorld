extends RefCounted
## V123: official ICC cube faces for small stone modules/slit windows;
## architect aerial published 2025-12 for planted roofs and pale parapets.
## Exact planting boundaries, heights and window positions remain fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func planted_panel(n: Node3D,x0: float,x1: float,z0: float,z1: float,y: float) -> void:
	# The existing structural roof carries collision; foliage is a thin finish.
	K.box(n,Vector3((x0+x1)/2,y+.055,(z0+z1)/2),Vector3(x1-x0,.07,z1-z0),"536848",false,3)
	for x in [x0-.06,x1+.06]:K.box(n,Vector3(x,y+.085,(z0+z1)/2),Vector3(.12,.10,z1-z0+.24),"acae9d",false,22)
	for z in [z0-.06,z1+.06]:K.box(n,Vector3((x0+x1)/2,y+.085,z),Vector3(x1-x0,.10,.12),"acae9d",false,22)

static func parapet(n: Node3D,x0: float,x1: float,z0: float,z1: float,y: float) -> void:
	for x in [x0,x1]:
		K.box(n,Vector3(x,y+.42,(z0+z1)/2),Vector3(.28,.84,z1-z0+.28),"c2baaa",true,47)
		K.box(n,Vector3(x,y+.86,(z0+z1)/2),Vector3(.38,.075,z1-z0+.38),"c5c6b6",false,22)
	for z in [z0,z1]:
		K.box(n,Vector3((x0+x1)/2,y+.42,z),Vector3(x1-x0,.84,.28),"c2baaa",true,47)
		K.box(n,Vector3((x0+x1)/2,y+.86,z),Vector3(x1-x0+.38,.075,.38),"c5c6b6",false,22)

static func slit_group(n: Node3D,p: Vector3,count: int,yaw: float=0.0,tall: bool=false) -> void:
	var axis:=Basis(Vector3.UP,yaw)
	var pitch: float=.78 if tall else .86
	var height: float=1.92 if tall else .63
	# Shallow recess and dark reveals sit outside the opaque auditorium shell.
	K.box(n,p-axis*Vector3(0,0,.025),Vector3(count*pitch+.22,height+.18,.10),"747365",false,22,yaw)
	for i in count:
		var q:=p+axis*Vector3((i-(count-1)*.5)*pitch,0,.07)
		K.window(n,q,.46 if tall else .64,height,yaw)
		K.box(n,q+axis*Vector3(.37,0,.06),Vector3(.11,height+.20,.18),"c1bba8",false,47,yaw)

static func build(parent: Node3D) -> void:
	var n:=K.holder(parent,"ICCPhotoEnvelopeV123")
	# Long low roof wraps the higher stage tower. Keep the tower footprint bare.
	parapet(n,-21.9,27.9,-35.9,3.9,20.24)
	planted_panel(n,-20.4,6.5,-34.4,2.3,20.24)
	planted_panel(n,7.9,26.4,-34.4,-30.1,20.24)
	planted_panel(n,7.9,26.4,-1.8,2.3,20.24)
	parapet(n,8.0,28.0,-28.5,-3.5,27.7)
	planted_panel(n,9.7,26.3,-26.8,-5.2,27.7)
	# The two forecourt arms have distinct roof datums, not one floating cover.
	parapet(n,-11.7,8.2,4.1,38.7,19.54)
	planted_panel(n,-10.0,6.4,6.0,36.9,19.54)
	parapet(n,8.0,29.2,3.8,38.7,16.10)
	planted_panel(n,9.8,27.4,5.6,36.9,16.10)
	# Small repeated groups, separated by large unperforated wall fields.
	for y in [8.1,12.2,16.3]:
		for z in [-27.0,-13.0,-1.0]:slit_group(n,Vector3(28.07,y,z),3,PI/2)
	for x in [13.0,23.0]:slit_group(n,Vector3(x,17.5,4.08),3)
	slit_group(n,Vector3(18.0,24.8,-3.42),4,0.0,true)
	slit_group(n,Vector3(28.07,24.8,-16.0),4,PI/2,true)
	# Dark base/reveal under the stone volume, visible along the lower door arcade.
	K.box(n,Vector3(3,5.025,-36.13),Vector3(50,.11,.13),"807f72",false,22)
	K.finish(n)
