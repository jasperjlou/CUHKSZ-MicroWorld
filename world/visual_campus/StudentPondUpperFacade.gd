extends RefCounted
## Official pond view +2024bookfair crop identify pool side;031 constrains upper gaps.
## Lower entrance datum is unresolved, so this module does not move whole building or cut lower slabs.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Wing=preload("res://world/visual_campus/StudentUpperCrossWing.gd")
static func strip(n:Node3D,u:float,v0:float,v1:float,low:float,high:float)->void:
	var a:=Wing.point(u,v0);var b:=Wing.point(u,v1);var d:=b-a
	K.box(n,(a+b)/2+Vector3.UP*(low+high)/2,Vector3(d.length(),high-low,.035),"c4af5f",false,52,-atan2(d.z,d.x))
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"PondUpperFacadeV162")
	# Facing reveals of the existing upper notch, without filling its open court or gallery.
	strip(n,302.5,25,186,16,23.2)
	strip(n,407.5,25,186,16,23.2)
	# Fine red perforated external screen over the rear upper portion; depth/extent fitted to photo.
	var a:=Wing.point(592,20.5);var b:=Wing.point(893,20.5);var d:=b-a
	var s:=K.holder(n,"PondRedPerforatedScreen",(a+b)/2);s.rotation.y=-atan2(d.z,d.x)
	var count:=maxi(1,roundi(d.length()/.72));var pitch:=d.length()/count
	var panels:=PackedVector3Array()
	for i in count:
		var x:float=-d.length()/2+(i+.5)*pitch
		var left:float=x-(pitch-.025)/2;var right:float=x+(pitch-.025)/2
		var p:=Vector3(left,16,0);var q:=Vector3(right,16,0);var r:=Vector3(right,23.2,0);var t:=Vector3(left,23.2,0)
		# Single perforated sheet avoids moire between the front/back skins of a thin box.
		panels.append_array(PackedVector3Array([p,q,r,p,r,t,t,r,q,t,q,p]))
		K.box(s,Vector3(x-pitch/2,19.6,.055),Vector3(.035,7.2,.14),"713d38",false,44)
	K.surface(s,panels,"8f4540",54,true)
	for y in [16.,19.6,23.2]:K.box(s,Vector3(0,y,.02),Vector3(d.length(),.07,.16),"86463e",false,44)
	K.finish(s);K.finish(n)
