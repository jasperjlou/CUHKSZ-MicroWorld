extends RefCounted
## V243 observed continuous asphalt-to-drain edge; width and modules are fitted.
## Visual finish only: retained terrain, wall and stair collisions are unchanged.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const Bank=preload("res://world/visual_campus/RearRoadBank.gd")
const FIRST=-340.0
const LAST=-232.0

static func point(builder,points:Array,z:float,inset:float,lift:float)->Vector3:
	var x:float=Bank.toe(z,points)-inset
	return Vector3(x,builder.height(x,z)+lift,z)

static func strip(builder,points:Array,z0:float,z1:float,i0:float,i1:float,lift:float)->PackedVector3Array:
	var out:=PackedVector3Array()
	var count:int=maxi(1,ceili((z1-z0)/.25))
	var across:int=maxi(1,ceili(absf(i1-i0)/.25))
	for j in count:
		var a:float=lerpf(z0,z1,float(j)/count);var b:float=lerpf(z0,z1,float(j+1)/count)
		for k in across:
			var u:float=lerpf(i0,i1,float(k)/across);var v:float=lerpf(i0,i1,float(k+1)/across)
			out.append_array(K.quad(point(builder,points,a,u,lift),point(builder,points,a,v,lift),point(builder,points,b,v,lift),point(builder,points,b,u,lift)))
	return out

static func build(parent:Node3D,builder,points:Array)->void:
	var n:=K.holder(parent,"RearRoadContinuousFinishV243")
	# Road half-width is 3 m; bank toe is centreline +4.4 m.
	# Overlap only the old road finish edge; no grass strip exists in this panorama.
	K.surface(n,strip(builder,points,FIRST,LAST,1.48,.85,.126),"555954",32)
	K.surface(n,strip(builder,points,FIRST,LAST,.85,.06,.132),"a8aea4",82)
	K.surface(n,strip(builder,points,FIRST,LAST,.06,-.025,.136),"727b73",82)
	var slots:=PackedVector3Array();var joints:=PackedVector3Array()
	for z in range(int(FIRST),int(LAST)):
		for j in 3:
			var s:float=float(z)+.18+j*.30
			slots.append_array(strip(builder,points,s,s+.055,.72,.23,.136))
		joints.append_array(strip(builder,points,float(z),float(z)+.012,.85,.06,.135))
	K.surface(n,slots,"48514c",11)
	K.surface(n,joints,"6e7871",11)
	K.surface(n,strip(builder,points,FIRST,LAST,1.02,.94,.140),"d9d9c8",22)
