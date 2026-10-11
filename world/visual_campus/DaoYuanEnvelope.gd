extends RefCounted
## Anniversary built photograph: tall screened entry, open roof frame, curved glazed return.
## Concealed elevations and metric scale remain fitted; no invented crest graphic.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const F := preload("res://world/visual_campus/StartZoneFacades.gd")
const P := preload("res://world/visual_campus/StartZonePublic.gd")
const Stair := preload("res://world/visual_campus/ShawEastPodium.gd")

static func build(b: Node3D,w: float,d: float) -> void:
	var z: float=d*.35
	# Tall central composition surrounds a clear ground entrance.
	for side in [-1,1]:
		K.box(b,Vector3(side*9,11.6,z-2.5),Vector3(4,23.2,7),"bbb9aa",true,22)
		K.box(b,Vector3(side*11,24,z+.1),Vector3(.5,1,10),"bbb9aa",false,22)
	K.box(b,Vector3(0,24,z+4.9),Vector3(22.5,.6,.65),"bdb9a8",false,22)
	K.box(b,Vector3(0,22.5,z-4.7),Vector3(22,.6,.45),"bdb9a8",false,22)
	for x in range(-9,10,3):K.box(b,Vector3(x,23.9,z),Vector3(.26,.38,10),"acaa9a",false,22)
	K.box(b,Vector3(0,13.1,z-.30),Vector3(13.8,17.2,.30),"364748",true,5)
	for i in 42:K.box(b,Vector3(-6.75+i*.329,13.1,z+.08),Vector3(.115,17.2,.36),"c0b89d",false,11)
	# The real crest needs a clean licensed source; keep an honest building-name plaque.
	K.box(b,Vector3(0,14.4,z+.33),Vector3(5.4,3.0,.18),"695473",false,22)
	K.label(b,"道 远 楼",Vector3(0,14.4,z+.46),.013)
	K.box(b,Vector3(0,4.6,z+1.7),Vector3(16,.24,4.8),"b8b1a0",true,22)
	for x in [-7.6,7.6]:K.column(b,Vector3(x,0,z+3.5),4.5,.32)
	# Three short entry risers sit above the brick forecourt in the named panorama.
	Stair.stair(b,Vector3(0,0,z+5.2),Vector3(0,.48,z+3.4),13.6)
	K.box(b,Vector3(0,.24,z-1.7),Vector3(15.6,.48,10.2),"b3b3a7",true,26)
	var doors:=K.holder(b,"DaoYuanRaisedEntry",Vector3(0,.48,0))
	P.glazing(doors,16,z-1.1,false);K.finish(doors)
	# The canopy's underside is a beam grid, not a featureless slab.
	for x in [-5,0,5]:K.box(b,Vector3(x,4.32,z+1.7),Vector3(.22,.34,4.8),"b9b9aa",false,22)
	for zz in [z-.4,z+1.7,z+3.8]:K.box(b,Vector3(0,4.32,zz),Vector3(15.7,.34,.22),"b9b9aa",false,22)
	for side in [-1,1]:
		K.box(b,Vector3(side*9.7,.27,z+4.0),Vector3(3.3,.54,2.6),"c3c3b5",true,22)
		K.box(b,Vector3(side*9.7,.57,z+4.0),Vector3(3.05,.10,2.35),"665c49",false,4)
		preload("res://world/visual_campus/CampusVegetation.gd").shrub(b,Vector3(side*9.7,.63,z+4.0),Vector3(2.9,1.7,2.2),5510+side)
	# The photographed classroom wing has a teal glazed ground base, not empty pilotis.
	var base:=K.holder(b,"DaoYuanClassroomGroundFront",Vector3(-w*.35,0,d*.22))
	K.box(base,Vector3(0,2.2,-.12),Vector3(w*.30,4.3,.12),"7baba7",true,19)
	for i in 7:K.box(base,Vector3(-w*.15+i*w*.05,2.2,0),Vector3(.09,4.4,.18),"50675e",false,11)
	K.box(base,Vector3(0,.12,0),Vector3(w*.30,.24,.27),"859a89",false,22)
	K.box(base,Vector3(0,4.37,0),Vector3(w*.30,.16,.22),"50675e",false,11)
	K.finish(base)
	# Right-hand return: faceted along a shallow curve, with real piers and floor bands.
	var n:=K.holder(b,"DaoYuanCurvedGlazedWing")
	var rows: Array=[0.0,4.6,8.3,12.0,15.7,19.4]
	var count:=16
	for i in count:
		var t0:=float(i)/count;var t1:=float(i+1)/count
		var a:=Vector2(w*.32+4*sin(t0*PI),z-1-t0*d*.73)
		var c:=Vector2(w*.32+4*sin(t1*PI),z-1-t1*d*.73)
		var q: Vector2=(a+c)/2;var delta:=c-a;var length:=delta.length()
		var yaw: float=atan2(-delta.y,delta.x)
		for j in rows.size()-1:
			var lo: float=rows[j];var hi: float=rows[j+1]
			K.box(n,Vector3(q.x,(lo+hi)/2,q.y),Vector3(length+.035,hi-lo,.12),"47636c",true,5,yaw)
			K.box(n,Vector3(q.x,hi-.24,q.y),Vector3(length+.06,.78,.44),"bec2b7",false,22,yaw)
			K.box(n,Vector3(q.x,lo+.31,q.y),Vector3(length+.06,.62,.35),"c3c6bb",false,22,yaw)
			K.box(n,Vector3(q.x,(lo+hi)/2-.2,q.y),Vector3(length+.06,.07,.22),"50665e",false,11,yaw)
			for k in 3:
				var p:=a.lerp(c,(k+.5)/3.0)
				K.box(n,Vector3(p.x,(lo+hi)/2,p.y),Vector3(.055,hi-lo,.18),"52665f",false,11,yaw)
		if i%3==0:K.box(n,Vector3(a.x,9.7,a.y),Vector3(.55,19.4,.58),"c3c6bc",true,22,yaw)
		K.box(n,Vector3(q.x,19.65,q.y),Vector3(length+.05,.65,.66),"c4c7bd",false,22,yaw)
		# Close the roof strip between the curved edge and the retained rear shell.
		var roof:=K.quad(Vector3(9,19.4,a.y),Vector3(a.x,19.4,a.y),Vector3(c.x,19.4,c.y),Vector3(9,19.4,c.y))
		K.surface(n,roof,"aab2a4",18,true)
		K.surface(n,K.quad(Vector3(9,.07,a.y),Vector3(a.x,.07,a.y),Vector3(c.x,.07,c.y),Vector3(9,.07,c.y)),"a3a89e",6)
	K.finish(n)
