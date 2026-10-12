extends RefCounted
## V149 registered upper tips: official rear-road panorama shows deep red reveals,
## a pale perimeter frame and a broad central pier. Dimensions remain fitted.
static func registered_end_frame(parent:Node3D,a:Vector2,b:Vector2,index:int)->void:
	var P=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
	var width:float=a.distance_to(b);var mid:Vector2=(a+b)/2
	var n:=K.holder(parent,"LibraryRearTipV149_"+str(index),Vector3(mid.x,0,mid.y))
	n.rotation.y=-atan2(b.y-a.y,b.x-a.x)+PI
	var bottom:float=12.8;var top:float=minf(P.roof_height(a),P.roof_height(b))-.04
	var low:float=bottom+.65;var high:float=top-.80;var height:float=high-low
	var clear:float=width-1.3;var recess:float=1.35
	# Continuous closed glazing behind the frame, not a transparent plane at the facade lip.
	K.box(n,Vector3(0,(high+low)/2,-recess),Vector3(clear,height,.12),"708b98",true,19)
	for side in [-1,1]:
		K.box(n,Vector3(side*(width/2-.325),(bottom+top)/2,-.68),Vector3(.65,top-bottom,1.55),"a8adaa",true,13)
		K.box(n,Vector3(side*(clear/2-.06),(high+low)/2,-.70),Vector3(.12,height,1.3),"925b4b",false,13)
	K.box(n,Vector3(0,bottom+.325,-.68),Vector3(clear,.65,1.55),"a8adaa",true,13)
	K.box(n,Vector3(0,top-.40,-.68),Vector3(clear,.80,1.55),"a8adaa",true,13)
	# The top edge is slightly pitched; close the wedge up to the common roof datum.
	for z in [-1.455,.095]:
		var left:=Vector3(-width/2,P.roof_height(b)+.015,z)
		var right:=Vector3(width/2,P.roof_height(a)+.015,z)
		var l0:=Vector3(-width/2,top-.02,z);var r0:=Vector3(width/2,top-.02,z)
		K.surface(n,PackedVector3Array([l0,left,right,l0,right,r0,l0,right,left,l0,r0,right]),"a8adaa",13)
	K.box(n,Vector3(0,high-.035,-.70),Vector3(clear,.07,1.3),"925b4b",false,13)
	K.box(n,Vector3(0,(high+low)/2,-1.05),Vector3(.58,height,.72),"abb0ab",true,22)
	var bays:=maxi(2,int(round(clear/1.5)))
	for i in range(bays+1):
		var x:float=-clear/2+i*clear/bays
		K.box(n,Vector3(x,(high+low)/2,-1.24),Vector3(.07,height,.19),"9aa9aa",false,11)
	for y in [16.65,20.65]:
		K.box(n,Vector3(0,y,-1.09),Vector3(clear,.44,.72),"aeb4ae",false,22)
	for y in [14.6,18.6,22.6,24.7]:
		if y>=high:continue
		K.box(n,Vector3(0,y,-1.245),Vector3(clear,.055,.19),"91a2a5",false,11)
	K.box(n,Vector3(0,low+.035,-.69),Vector3(clear,.07,1.38),"9da7a3",false,11)
	n.set_meta("fitted_recess",recess);n.set_meta("width",width);n.set_meta("low",low);n.set_meta("high",high)
	K.finish(n)

## Rear reading-room end frames observed opposite the official graffiti-wall panorama.
## Dimensions fit the existing two-wing outline; photo/date are not survey evidence.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func end_frame(b: Node3D,a: Vector2,c: Vector2,upper: bool=true) -> void:
	var length:=a.distance_to(c);var mid: Vector2=(a+c)/2
	var n:=K.holder(b,"RearReadingRoomFrame",Vector3(mid.x,0,mid.y))
	n.rotation.y=-atan2(c.y-a.y,c.x-a.x)
	# Local +Z is outward; the glazing is set back within the projecting metal sleeve.
	var bottom:=12.8;var top:=26.3;var opening:=length-1.5
	K.box(n,Vector3(0,10.7,-1.45),Vector3(length-.3,3.8,.10),"76918f",true,19)
	for x in [-length*.4,-length*.2,0,length*.2,length*.4]:K.box(n,Vector3(x,10.7,-1.30),Vector3(.075,3.8,.15),"8e9a98",false,11)
	if not upper:
		K.finish(n);return
	for side in [-1,1]:
		K.box(n,Vector3(side*(length/2-.38),(bottom+top)/2,-.63),Vector3(.76,top-bottom,1.9),"7c8482",true,13)
		K.box(n,Vector3(side*(length/2-.80),(bottom+top)/2,-.89),Vector3(.12,top-bottom-1.2,1.3),"946857",false,22)
	K.box(n,Vector3(0,bottom+.42,-.63),Vector3(length,.84,1.9),"919991",true,13)
	K.box(n,Vector3(0,top-.47,-.63),Vector3(length,.94,1.9),"919991",true,13)
	var low:=bottom+.84;var high:=top-.94
	K.box(n,Vector3(0,(low+high)/2,-1.45),Vector3(opening,high-low,.10),"64808c",true,19)
	var count:=maxi(5,int(opening/1.65));var pitch:=opening/count
	for i in range(count+1):
		K.box(n,Vector3(-opening/2+i*pitch,(low+high)/2,-1.30),Vector3(.085,high-low,.18),"8e9a98",false,11)
	for y in [16.65,20.85]:
		K.box(n,Vector3(0,y,-.92),Vector3(opening,.30,.9),"abb0a8",false,13)
	for y in [14.7,18.6,22.9,24.8]:
		K.box(n,Vector3(0,y,-1.28),Vector3(opening,.055,.15),"8d9996",false,11)
	K.finish(n)

static func slab(n: Node3D,x0: float,x1: float,z0: float,z1: float,y: float) -> void:
	K.box(n,Vector3((x0+x1)/2,y-.10,(z0+z1)/2),Vector3(x1-x0,.20,z1-z0),"a8aaa0",false,26)
	K.surface(n,K.quad(Vector3(x0,y,z0),Vector3(x1,y,z0),Vector3(x1,y,z1),Vector3(x0,y,z1)),"a8aaa0",26,true)

static func rail(n: Node3D,a: Vector3,c: Vector3) -> void:
	var delta:=c-a
	var holder:=K.holder(n,"RearRampRail",(a+c)/2+Vector3.UP*.94)
	holder.rotation.y=-atan2(delta.z,delta.x)
	holder.rotation.z=atan2(delta.y,Vector2(delta.x,delta.z).length())
	K.box(holder,Vector3.ZERO,Vector3(delta.length(),.045,.045),"929e98",false,11)
	K.finish(holder)
	for i in range(maxi(2,int(delta.length()/.9))+1):
		var t:=float(i)/maxi(2,int(delta.length()/.9))
		K.box(n,a.lerp(c,t)+Vector3.UP*.47,Vector3(.035,.94,.035),"929e98",false,11)

static func lower_entry(b: Node3D) -> void:
	var n:=K.holder(b,"LibraryRearMasonryAndEntry")
	# Two-storey masonry base under the pond-end frame, with actual small slit windows.
	for row in 2:
		var y: float=row*4.4
		for i in 12:
			var x: float=-42.6+(i+.5)*2.1
			if row==0 and x>-32.4 and x<-27.6:continue
			K.box(n,Vector3(x,y+.60,-25.1),Vector3(2.1,1.2,.5),"767d78",true,7)
			K.box(n,Vector3(x,y+3.75,-25.1),Vector3(2.1,1.3,.5),"767d78",true,7)
			for side in [-1,1]:K.box(n,Vector3(x+side*.74,y+2.15,-25.1),Vector3(.62,1.9,.5),"767d78",true,7)
			K.box(n,Vector3(x,y+2.15,-24.94),Vector3(.86,1.9,.1),"4e6870",true,19)
			K.box(n,Vector3(x,y+2.15,-25.40),Vector3(.05,1.9,.06),"929e98",false,11)
	# Door opening faces the road; porch rises 0.48 m by both steps and a side ramp.
	K.box(n,Vector3(-30,3.9,-25.1),Vector3(4.8,1,.5),"767d78",true,7)
	for x in [-32.4,-27.6]:K.box(n,Vector3(x,1.94,-25.4),Vector3(.10,3.2,.18),"7b8984",true,11)
	for x in [-31.95,-28.05]:K.box(n,Vector3(x,1.94,-25.4),Vector3(.75,3.0,.08),"8baba6",true,19)
	K.box(n,Vector3(-30,3.5,-25.4),Vector3(4.8,.10,.18),"7b8984",false,11)
	slab(n,-32.5,-26,-28.4,-24.6,.48)
	slab(n,-32,-28,-24.6,-23,.48)
	K.surface(n,K.quad(Vector3(-32,.48,-23),Vector3(-28,.48,-23),Vector3(-28,0,-20.6),Vector3(-32,0,-20.6)),"a8aaa0",26,true)
	for i in 3:
		var h: float=.16*(i+1)
		K.box(n,Vector3(-30,h/2,-30.5+(i+.5)*.7),Vector3(3.2,h,.71),"a8aaa0",false,26)
	var steps:=K.surface(n,K.quad(Vector3(-31.6,0,-30.5),Vector3(-28.4,0,-30.5),Vector3(-28.4,.48,-28.4),Vector3(-31.6,.48,-28.4)),"a8aaa0",26,true);steps.hide()
	K.surface(n,K.quad(Vector3(-26,.48,-28.4),Vector3(-18,0,-28.4),Vector3(-18,0,-26.6),Vector3(-26,.48,-26.6)),"a8aaa0",26,true)
	for z in [-28.45,-26.55]:rail(n,Vector3(-26,.48,z),Vector3(-18,0,z))
	rail(n,Vector3(-32.5,.48,-28.4),Vector3(-32.5,.48,-25.6))
	K.finish(n)
