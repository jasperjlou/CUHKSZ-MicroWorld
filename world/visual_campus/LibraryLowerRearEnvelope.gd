extends RefCounted
## Independent2F/3F rear lines; official rear-road panorama supplies grey masonry/slits.
## G service enclosure/door access and all metric dimensions remain a fitted hypothesis.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const U=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")
const Rear=preload("res://world/visual_campus/LibraryRearGlazing.gd")
const SECOND=[[154,40],[698,40],[698,127],[878,277],[935,222],[1017,300],[1090,230],[1238,382]]
const THIRD=[[238,32],[608,32],[608,272],[887,272],[978,361],[1013,329],[1005,280],[1070,341],[1128,293],[1254,420]]

static func point(values:Array,level:int)->Vector3:
	return P.point2(values[0],values[1]) if level==2 else P.point3(values[0],values[1])

static func masonry(n:Node3D,a:Vector3,b:Vector3,y:float,slits:bool=true)->void:
	var delta:=b-a;var length:=delta.length();var mid:Vector3=(a+b)/2
	var h:=K.holder(n,"RearMasonryBay",mid);h.rotation.y=-atan2(delta.z,delta.x)
	var count:=maxi(1,int(round(length/1.85)));var pitch:float=length/count
	if not slits:
		K.box(h,Vector3(0,y+2.2,0),Vector3(length,4.4,.32),"737b78",true,7)
	else:
		for i in count:
			var x:float=-length/2+(i+.5)*pitch;var window:float=minf(.65,pitch*.45)
			K.box(h,Vector3(x,y+.68,0),Vector3(pitch+.018,1.36,.32),"737b78",true,7)
			K.box(h,Vector3(x,y+3.60,0),Vector3(pitch+.018,1.60,.32),"737b78",true,7)
			for side in [-1,1]:K.box(h,Vector3(x+side*(pitch+window)/4,y+2.08,0),Vector3((pitch-window)/2+.015,1.44,.32),"737b78",true,7)
			K.box(h,Vector3(x,y+2.08,.11),Vector3(window,1.44,.08),"3f5860",true,48)
			for side in [-1,1]:K.box(h,Vector3(x+side*window/2,y+2.08,-.07),Vector3(.045,1.50,.30),"74827c",false,11)
			K.box(h,Vector3(x,y+1.34,-.08),Vector3(window+.10,.055,.38),"7d8a81",false,11)
	K.box(h,Vector3(0,y+4.06,0),Vector3(length+.025,.12,.42),"9aa39c",false,22)
	K.finish(h)

static func glazed(n:Node3D,a:Vector3,b:Vector3,door:bool=false)->void:
	var delta:=b-a;var length:=delta.length();var h:=K.holder(n,"RegisteredThirdRearGlazing",(a+b)/2)
	h.rotation.y=-atan2(delta.z,delta.x)
	var opening:float=1.8 if door else 0
	if door:
		for side in [-1,1]:K.box(h,Vector3(side*(length+opening)/4,10.65,0),Vector3((length-opening)/2,3.7,.10),"8ca09d",true,19)
		K.box(h,Vector3(0,12.15,0),Vector3(opening,.7,.10),"8ca09d",true,19)
		for x in [-.94,.94]:K.box(h,Vector3(x,10.3,0),Vector3(.08,3.0,.16),"788b85",true,11)
		h.set_meta("terrace_door",true)
	else:K.box(h,Vector3(0,10.65,0),Vector3(length+.02,3.7,.10),"8ca09d",true,19)
	for y in [8.9,12.5]:K.box(h,Vector3(0,y,0),Vector3(length+.02,.18,.22),"99a69f",false,22)
	var count:=maxi(1,int(ceil(length/1.5)))
	for i in range(count+1):
		var x:float=-length/2+i*length/count
		if door and absf(x)<1:continue
		K.box(h,Vector3(x,10.65,0),Vector3(.06,3.7,.14),"889c94",false,11)
	K.finish(h)

static func rear_door()->Vector3:
	var a:=point(SECOND[0],2);var b:=point(SECOND[1],2)
	return a.lerp(b,(-30-a.x)/(b.x-a.x))
static func door_point(p:Vector3)->Vector3:
	var d:=point(SECOND[1],2)-point(SECOND[0],2)
	return rear_door()+Basis(Vector3.UP,-atan2(d.z,d.x))*p

static func ground_portal(n:Node3D)->void:
	var a:=point(SECOND[0],2);var b:=point(SECOND[1],2);var d:=b-a;var centre:=rear_door()
	var h:=K.holder(n,"RegisteredRearGroundPortalV150",centre);h.rotation.y=-atan2(d.z,d.x)
	# Keep the existing fitted G identity/0.48m porch until road-grade evidence resolves it.
	var local_a:=h.basis.inverse()*(a-centre);var local_b:=h.basis.inverse()*(b-centre)
	for ends in [[local_a.x,-2.4],[2.4,local_b.x]]:
		masonry(h,Vector3(ends[0],0,0),Vector3(ends[1],0,0),0)
	K.box(h,Vector3(0,3.97,0),Vector3(4.8,.86,.32),"737b78",true,7)
	for x in [-2.4,2.4]:K.box(h,Vector3(x,1.98,-.10),Vector3(.10,3.1,.18),"788b85",true,11)
	for x in [-1.95,1.95]:K.box(h,Vector3(x,1.98,-.10),Vector3(.76,3.0,.08),"8baba6",true,19)
	K.box(h,Vector3(0,3.51,-.10),Vector3(4.8,.10,.18),"788b85",false,11)
	Rear.slab(h,-2.5,4,-3.3,.5,.48);Rear.slab(h,-2,2,.5,2.1,.48)
	K.surface(h,K.quad(Vector3(-2,.48,2.1),Vector3(2,.48,2.1),Vector3(2,.106,4.5),Vector3(-2,.106,4.5)),"a8aaa0",26,true)
	for i in 3:
		var height:float=.16*(i+1)
		K.box(h,Vector3(0,height/2,-5.4+(i+.5)*.7),Vector3(3.2,height,.71),"a8aaa0",false,26)
	K.surface(h,K.quad(Vector3(-1.6,0,-5.4),Vector3(1.6,0,-5.4),Vector3(1.6,.48,-3.3),Vector3(-1.6,.48,-3.3)),"a8aaa0",26,true).hide()
	K.surface(h,K.quad(Vector3(4,.48,-3.3),Vector3(12,0,-3.3),Vector3(12,0,-1.5),Vector3(4,.48,-1.5)),"a8aaa0",26,true)
	preload("res://world/visual_campus/LibraryRearAccessDetail.gd").build(h)
	# A straight access vestibule joins the retained G toilet/public aisle; unseen service
	# rooms behind the staff wing stay enclosed without fabricated furnishings.
	# Match the retained G finish level; the terrain must not render as asphalt inside.
	Rear.slab(h,-1.9,1.9,4.5,14,.106)
	for side in [-1,1]:K.box(h,Vector3(side*2,2.04,8.6),Vector3(.16,4.08,12.2),"bfc1b7",true,22)
	K.box(h,Vector3(0,4.07,8.6),Vector3(4.1,.10,12.2),"c8cbc1",false,22)
	for z in [4,8,12]:K.box(h,Vector3(0,4.0,z),Vector3(.25,.035,1.3),"e4e5d8",false,17)
	K.finish(h)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryIndependentRearEnvelopeV150")
	for i in range(SECOND.size()-1):
		var a:=point(SECOND[i],2);var b:=point(SECOND[i+1],2)
		masonry(n,a,b,4.4)
		if i in [1,2]:masonry(n,a,b,0,false)
	# Far left2F/G corner closes the old return and registers the staff/WC volume.
	masonry(n,point([154,40],2),point([154,415],2),4.4)
	masonry(n,point([154,40],2),point([154,415],2),0)
	ground_portal(n)
	for i in range(THIRD.size()-1):
		var a:=point(THIRD[i],3);var b:=point(THIRD[i+1],3)
		if i==0 or i>=5:masonry(n,a,b,8.8)
		else:glazed(n,a,b,i==1 or i==3)
	masonry(n,point([238,32],3),point([238,216],3),8.8)
	masonry(n,point([238,216],3),point([154,216],3),8.8)
	masonry(n,point([154,216],3),point([154,415],3),8.8)
	# The staff wing roof and third-floor terrace are distinct from the public interior.
	var roof:PackedVector2Array=P.second_outline()
	var roof_parts:Array[PackedVector2Array]=[roof]
	roof_parts=U.subtract(roof_parts,P.third_outline())
	K.surface(n,U.floor_vertices(roof_parts,8.82),"929a90",18)
	# Reinstate closed safety edges on the mapped outdoor terrace, leaving its glass doors open.
	var terrace:=P.polygon3([[608,74],[764,74],[1013,329],[978,361],[887,272],[608,272]])
	for i in 3:Pods.strip(n,terrace[i],terrace[i+1],9.34,1.08,.085,"9eafa4",19,true)
	K.finish(n)
