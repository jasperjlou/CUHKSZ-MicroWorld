extends RefCounted
## V83 official aerial92544949 l2_l_03_03: inset glazing, perforated screen,
## transverse braces and roof plant. Visible upper edge only; hidden lower plan remains fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const F:=preload("res://world/visual_campus/StartZoneFacades.gd")

static func build(parent:Node3D,w:float,d:float,levels:Array) -> void:
	var n:=K.holder(parent,"DaoYuanRearWingV83",Vector3(0,0,-d*.33))
	var depth:float=d*.30;var back:float=-depth/2;var inset:float=4.6
	for y:float in levels:
		var trimmed:bool=y>=15.7
		K.box(n,Vector3(0,y,inset/2 if trimmed else 0),Vector3(w,.24,depth-inset if trimmed else depth),"797c74" if y==levels[-1] else "bdc1b6",true,36 if y==levels[-1] else 15)
	# The publicly unseen lower facade keeps its provisional window/column construction.
	F.build(n,w,depth,[4.6,8.3,12.0],0,-1,false,false)
	F.build(n,w,depth,levels,0,1,false,false)
	for side in [-1,1]:
		F.build(n,depth,w,[4.6,8.3,12.0],1,side,false,false)
		var upper:=K.holder(n,"UpperSideReturn",Vector3(0,0,inset/2))
		F.build(upper,depth-inset,w,[12.0,15.7,19.4],1,side,true,false);K.finish(upper)
	var glazing:=K.holder(n,"InsetRearRibbon",Vector3(0,0,inset))
	F.build(glazing,w-4,depth,[12.0,15.7,19.4],0,-1,true,false);K.finish(glazing)
	# Weathered terrace surface is open to the sky, rather than a green roof over the screen.
	K.box(n,Vector3(0,12.14,back+inset/2),Vector3(w,.025,inset),"81847c",false,36)
	var z:float=back-.10
	var left:float=-w/2+2;var right:float=w/2-2
	var cells:=int((right-left)/1.12);var pitch:float=(right-left)/cells
	# Four rows of real openings; no opaque texture pretending to be a perforated wall.
	for row in 5:K.box(n,Vector3(0,12.4+row*.88,z),Vector3(w-3,.22,.34),"c6c8bb",true,22)
	for i in cells+1:K.box(n,Vector3(left+i*pitch,14.16,z),Vector3(.22,3.74,.34),"c6c8bb",true,22)
	for i in 7:
		var x:float=lerpf(left,right,i/6.0)
		K.box(n,Vector3(x,14.16,z+.02),Vector3(.5,4.12,.6),"c8cabd",true,22)
		K.box(n,Vector3(x,16.15,back+inset/2),Vector3(.28,.34,inset+.4),"c8cabd",false,22)
	# Small rooftop end blocks and shallow openings visible in the aerial.
	for side in [-1,1]:
		var x:float=side*(w/2-1.3)
		K.box(n,Vector3(x,16.7,back+2.0),Vector3(2.6,9.4,4.1),"c6c9bd",true,22)
		var face:=K.holder(n,"EndBlockRearFace",Vector3(x,0,back-.09));face.rotation.y=PI
		for y in [13.0,16.6,20.2]:F.window(face,Vector3(0,y,0),.85,.80)
		K.finish(face)
	# Retain the existing open ground columns until lower-level reference is available.
	for x in range(-int(w/2)+2,int(w/2),6):
		for side in [-1,1]:K.column(n,Vector3(x,0,side*(depth/2-.55)),4.6,.6)
	for side in [-1,1]:
		K.box(n,Vector3(0,19.75,depth/2-.12 if side==1 else back+inset),Vector3(w,.7,.24),"c7cabd",false,22)
	for x in [-17,-10,-3,4,11,18]:
		K.box(n,Vector3(x,20.04,1.8),Vector3(1.05,1.05,.6),"b2b9ae",false,11)
		for j in 6:K.box(n,Vector3(x,19.68+j*.12,1.48),Vector3(.85,.04,.025),"58645c",false,11)
	K.finish(n)
