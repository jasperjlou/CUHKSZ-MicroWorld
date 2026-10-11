extends RefCounted
## Narrow-window render, paired Zhiren panes and ribbon glazing are separate facade families.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func window(b: Node3D,p: Vector3,w: float,h: float) -> void:
	K.box(b,p+Vector3(0,0,-.11),Vector3(w,h,.10),"527077",false,5)
	for side in [-1,1]:
		K.box(b,p+Vector3(side*(w/2+.035),0,-.025),Vector3(.07,h+.14,.13),"586b66",false,11)
		K.box(b,p+Vector3(0,side*(h/2+.035),-.025),Vector3(w+.14,.07,.13),"586b66",false,11)
	K.box(b,p+Vector3(0,-h*.1,.015),Vector3(w,.065,.10),"435751",false,11)
	K.box(b,p+Vector3(0,-h/2-.07,.035),Vector3(w+.14,.09,.30),"b8bdb0",false,15)

static func equipment_balcony(b: Node3D,p: Vector3,width: float) -> void:
	K.box(b,p+Vector3(0,-.12,.42),Vector3(width,.18,.90),"a4b0a5",false,11)
	for side in [-1,1]:
		K.box(b,p+Vector3(side*(width/2-.035),.26,.42),Vector3(.06,.72,.90),"b8c2b5",false,11)
		K.box(b,p+Vector3(side*(width/2-.04),.26,.85),Vector3(.07,.76,.07),"c4cbbb",false,11)
	for j in 8:K.box(b,p+Vector3(0,-.06+j*.09,.86),Vector3(width,.035,.055),"b3bdae",false,11)
	K.box(b,p+Vector3(-width*.24,.14,.32),Vector3(.66,.46,.48),"929f95",false,11)
	for j in 6:K.box(b,p+Vector3(-width*.24,.00+j*.05,.57),Vector3(.56,.025,.025),"566961",false,11)

static func build(parent: Node3D,length: float,depth: float,levels: Array,axis: int,side: int,ribbon: bool,paired: bool) -> void:
	var origin:=Vector3(0,0,side*depth/2) if axis==0 else Vector3(side*depth/2,0,0)
	var b:=K.holder(parent,"StartZoneElevation",origin)
	b.rotation.y=(0.0 if side>0 else PI) if axis==0 else side*PI/2
	var count:=maxi(2,roundi(length/3.2));var cell:=length/count
	for f in range(levels.size()-1):
		var low: float=levels[f];var high: float=levels[f+1];var h:=high-low
		var wh:=h-1.15;var mid: float=(low+high)/2
		K.box(b,Vector3(0,low+.30,-.15),Vector3(length,.6,.32),"c8c9bf",true,22)
		K.box(b,Vector3(0,high-.275,-.15),Vector3(length,.55,.32),"c8c9bf",true,22)
		for i in count:
			var x: float=-length/2+(i+.5)*cell
			if ribbon:
				K.box(b,Vector3(x-cell/2+.09,mid,-.15),Vector3(.18,h,.32),"c8c9bf",true,22)
				window(b,Vector3(x+.09,mid,0),cell-.25,wh)
				# V76: photographed ribbons have slim intermediate glazing mullions,
				# rather than one three-metre pane between each concrete pier.
				for offset in [-1,1]:K.box(b,Vector3(x+.09+offset*cell/6,mid,.025),Vector3(.045,wh,.10),"4a625f",false,11)
			elif paired:
				var pane: float=cell*.26;var shift: float=cell*.22
				for interval: Vector2 in [Vector2(-cell/2,-shift-pane/2),Vector2(-shift+pane/2,shift-pane/2),Vector2(shift+pane/2,cell/2)]:
					K.box(b,Vector3(x+(interval.x+interval.y)/2,mid,-.15),Vector3(interval.y-interval.x,wh,.32),"b3b7ac",true,22)
				for sign_x in [-1,1]:window(b,Vector3(x+sign_x*shift,mid,0),pane,wh)
				# The photographed lowest window row is clear; shallow open cages begin above it.
				if f>0:equipment_balcony(b,Vector3(x,low+.76,.05),cell-.20)
			else:
				var pane:=minf(1.12,cell*.42);var pier: float=(cell-pane)/2
				for sign_x in [-1,1]:K.box(b,Vector3(x+sign_x*(pane/2+pier/2),mid,-.15),Vector3(pier,wh,.32),"b3b7ac",true,22)
				window(b,Vector3(x,mid,0),pane,wh)
				K.box(b,Vector3(x-cell/2+.13,mid,.015),Vector3(.26,wh,.06),"c8c9bf",false,22)
	K.finish(b)
