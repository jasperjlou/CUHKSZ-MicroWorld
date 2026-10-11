extends RefCounted
## V58: 2023 built exterior confirms the open folded end. 2021 design illustrates stairs/screens.
## Exact stair runs, floor heights and local orientation remain visual fits.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")
const SECTION := preload("res://world/visual_campus/SportsSection.gd")

static func slab(b: Node3D,y: float) -> void:
	# Leave the end stairwell open through both public floors.
	for xr: Vector2 in [Vector2(-63,46),Vector2(46,56),Vector2(56,63)]:
		for zr: Vector2 in [Vector2(-16,1),Vector2(1,13),Vector2(13,16)]:
			if xr.x==46 and zr.x==1:continue
			K.box(b,Vector3((xr.x+xr.y)/2,y-.18,(zr.x+zr.y)/2),Vector3(xr.y-xr.x,.36,zr.y-zr.x),"b9c2b9",true,22)

static func member(b: Node3D,a: Vector3,c: Vector3,w: float) -> void:
	var n:=K.holder(b,"FoldedEndFrame",(a+c)/2);n.quaternion=Quaternion(Vector3.UP,(c-a).normalized())
	K.box(n,Vector3.ZERO,Vector3(w,a.distance_to(c),w),"bfc5bc",false,22);K.finish(n)

static func screen(b: Node3D) -> void:
	# Real holes between triangulated strips, not a solid painted panel.
	var v:=PackedVector3Array()
	for iy in 16:
		for iz in 31:
			var a:=Vector3(62.5,4.9+iy*.72,-15.5+iz)
			var c:=a+Vector3(0,.62,.90)
			var m:=a+Vector3(0,.31,.45)
			for tri: Array in [[a,a+Vector3(0,.62,0),m],[a+Vector3(0,0,.90),c,m]]:
				v.append_array(PackedVector3Array([tri[0],tri[1],tri[2],tri[2],tri[1],tri[0]]))
	K.surface(b,v,"a5aaa0",22)

static func build(b: Node3D) -> void:
	for level: Vector2 in [Vector2(0,4.8),Vector2(4.8,9.2)]:
		var mid: float=(level.x+level.y)/2
		P.stair(b,Vector3(48,level.x,13),Vector3(48,mid,4),3.6)
		K.box(b,Vector3(51,mid-.16,2.5),Vector3(10,.32,3),"b1b7ac",true,26)
		P.stair(b,Vector3(54,mid,4),Vector3(54,level.y,13),3.6)
		P.rail(b,Vector3(46,mid,1),Vector3(56,mid,1))
		P.rail(b,Vector3(46,mid,1),Vector3(46,mid,4))
		P.rail(b,Vector3(56,mid,1),Vector3(56,mid,4))
	for y in [4.8,9.2]:
		for x in [46,56]:P.rail(b,Vector3(x,y,1),Vector3(x,y,13))
		P.rail(b,Vector3(46,y,1),Vector3(56,y,1))
		P.rail(b,Vector3(62,y,-16),Vector3(62,y,16))
		K.box(b,Vector3(51,y+.013,14.5),Vector3(22,.025,3),"a7a99c",false,26)
	# Recessed upper gathering terrace, open to the field below the folded canopy.
	P.rail(b,Vector3(34,9.2,-16),Vector3(62,9.2,-16))
	K.box(b,Vector3(47,9.215,-6),Vector3(26,.025,18),"95856f",false,4)
	for z in [-9,-3]:
		K.box(b,Vector3(41,9.94,z),Vector3(1.4,.08,1.4),"d1d3c8",true,22)
		K.box(b,Vector3(41,9.57,z),Vector3(.13,.74,.13),"8a948b",false,11)
		for x in [39.5,42.5]:
			K.box(b,Vector3(x,9.64,z),Vector3(.7,.12,.7),"677980",false,22)
			K.box(b,Vector3(x,9.92,z+.32),Vector3(.7,.5,.10),"677980",false,22)
	# The photographed open end has a sloped light perimeter and patterned screen.
	member(b,Vector3(57,0,-16),Vector3(63,4.8,-16),.65)
	var top: float=SECTION.roof_height(63)-.15
	member(b,Vector3(63,4.8,-16),Vector3(63,top,-16),.65)
	member(b,Vector3(63,top,-16),Vector3(63,top,16),.65)
	screen(b)
	# Ground end doorway is open, with a sign, bulletin panel and a clear stair approach.
	for z in [-3.1,3.1]:K.box(b,Vector3(61.8,2.05,z),Vector3(.35,4.1,.35),"adb5ad",true,22)
	K.box(b,Vector3(61.8,4.04,0),Vector3(.4,.30,6.5),"bfc6bc",false,22)
	var sign:=K.label(b,"综合运动馆\nSPORTS COMPLEX",Vector3(62.05,3.50,0),.007);sign.rotation.y=PI/2;sign.modulate=Color("3c4851")
	K.box(b,Vector3(59.5,1.7,-6),Vector3(.15,1.9,3),"443a51",false,22)
	K.box(b,Vector3(59.60,1.7,-6),Vector3(.05,1.55,2.7),"d1d0c5",false,22)
	for z in [-6.8,-6,-5.2]:K.box(b,Vector3(59.64,1.65,z),Vector3(.03,.75,.6),"eaeadf",false,22)
	K.box(b,Vector3(61,2.8,8),Vector3(.32,.9,3),"d0b73d",false,22)
