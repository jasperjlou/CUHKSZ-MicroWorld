extends RefCounted
## G panorama25181872 l-left: one round pier stands before the timber seating.
## Relative placement/diameter fitted; this does not establish the entire column grid.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const G=preload("res://world/visual_campus/LibraryGroundStair.gd")
const D=preload("res://world/visual_campus/LibraryLobbyDetail.gd")
const RADIUS:float=.43
static func centre()->Vector3:return G.point(Vector3(7,0,-2))
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryGroundObservedRoundPier",centre())
	D.cylinder(n,Vector3(0,2.1025,0),RADIUS,3.995,"cacbbf",true)
	D.cylinder(n,Vector3(0,.16,0),RADIUS+.013,.11,"b5b9ae")
	D.cylinder(n,Vector3(0,4.045,0),RADIUS+.06,.075,"b9bcaf")
