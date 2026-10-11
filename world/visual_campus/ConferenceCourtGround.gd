extends RefCounted
## V94: continuous stone undercroft, bounded hedges and platform supports.
## Official ICC avenue/front views support the features; extents and structure are fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const A := preload("res://world/visual_campus/ConferenceAvenue.gd")
const S := preload("res://world/visual_campus/LowerCampusLandscape.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")

static func bed(n: Node3D,x0: float,x1: float,z0: float,z1: float,seed_value: int) -> void:
	var middle:=Vector3((x0+x1)/2,.12,(z0+z1)/2)
	K.box(n,middle+Vector3.UP*.03,Vector3(x1-x0,.06,z1-z0),"544f3f",false,8)
	for x in [x0,x1]:K.box(n,Vector3(x,.25,middle.z),Vector3(.20,.30,z1-z0+.20),"a6aaa0",true,15)
	for z in [z0,z1]:K.box(n,Vector3(middle.x,.25,z),Vector3(x1-x0,.30,.20),"a6aaa0",true,15)
	# Low yellow-green edging and taller clipped hedge are separate visible layers.
	var count:=ceili((x1-x0)/2.5);var cell: float=(x1-x0)/count
	for i in count:
		var x: float=x0+(i+.5)*cell
		V.shrub(n,Vector3(x,.18,z0+.75),Vector3(cell-.12,.35,1.0),seed_value+i)
		V.shrub(n,Vector3(x,.20,z1-1.0),Vector3(cell-.10,1.25,1.7),seed_value+50+i)

static func build(parent: Node3D,builder) -> void:
	var n:=K.holder(parent,"ICCCadCourtV95")
	# Rear arcade, both side streets and front entrances form a continuous outdoor circuit.
	A.floor_rect(n,builder,-34,36,-49,-36,42,"969c94")
	A.floor_rect(n,builder,29,37,-36,58,42,"969c94")
	A.floor_rect(n,builder,-35,-28,-36,4,42,"969c94")
	A.floor_rect(n,builder,-28,-12,4,43,42,"969c94")
	A.floor_rect(n,builder,-12,8.1,4,42.5,12,"92978e")
	A.floor_rect(n,builder,-16,37,38.7,58,42,"969c94")
	# A wide stone apron meets the retained gate walk; its absolute registration remains fitted.
	A.floor_rect(n,builder,36,45,-30,-20,42,"969c94")
	bed(n,-33,-29,9,35,9511)
	bed(n,32,35,6,24,9561)
	for x in [-26.5,30.5]:
		var q:=K.holder(n,"SideDrain",Vector3(x,0,20));q.rotation.y=PI/2
		S.drain(q,Vector3(0,.115,0),29);K.finish(q)
	for span:Vector2 in [Vector2(-15,-6),Vector2(3,28)]:S.drain(n,Vector3((span.x+span.y)/2,.115,54),span.y-span.x)
	S.drain(n,Vector3(1,.115,-43),59)
	K.finish(n)
