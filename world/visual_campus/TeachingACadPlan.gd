extends RefCounted
## Historical teaching A CAD, rotated 47.063775 degrees into its drawing axes.
## CAD 1F title origin (131789175.836,36211595.440) mm; u/v remain metres below.
## Outer site translation is fitted, not a survey. Upper rooms are simplified shells.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const S := preload("res://world/visual_campus/TeachingASite.gd")
const D := preload("res://world/visual_campus/TeachingAArcadeDetail.gd")
const F := preload("res://world/visual_campus/TeachingAFrontEnvelope.gd")
const ROOT_X:=-79.5
const ROOT_Z:=-115.0
const U0:=10.75
const V0:=54.5
const PIT_LOW:=-5.15

static func cutout(x: float,z: float) -> bool:
	var u:float=ROOT_Z-z+U0;var v:float=x-ROOT_X+V0
	return u>-2 and u<14.5 and v>37.5 and v<71.5

static func slab(n: Node3D,u0: float,u1: float,v0: float,v1: float,y: float) -> void:
	if absf(y)<.001:y=.06
	K.box(n,Vector3((u0+u1)/2,y-.12,(v0+v1)/2),Vector3(u1-u0,.24,v1-v0),"8f968e",true,41)

static func wing(n: Node3D,t,id: String,u0: float,u1: float,v0: float,v1: float,levels: Array,axis: int,side: int,columns: bool=true) -> void:
	var style:Dictionary={"stone":"b7ad9e","inner_color":"b7ad9e","screened":false,"finish":15,"window_width":.82,"long_columns":columns,"ground_columns":columns,"floor_top_level":true}
	if id=="FrontLectureRooms":
		style["omitted_faces"]=[[0,1,1]]
		style["additional_doors"]=[[0,1,0,7.75]]
	if id=="FrontLobbyWing":style["omitted_faces"]=[[0,1,0]]
	if id=="TallOpenArcadeWing":
		style["base_opening"]=Rect2(20-(u0+u1)/2,v0-(v0+v1)/2,12.5,7.5)
		style["back_door_floor"]=0;style["back_door_center"]=22-(u0+u1)/2
	if id=="RearSeminarWing":
		style["omit_inner_floor"]=0;style["omit_west_floor"]=0;style["inner_door_floor"]=1;style["inner_door_center"]=-5.0
	t.wing(n,id,Vector3((u0+u1)/2,0,(v0+v1)/2),Vector2(u1-u0,v1-v0),levels,axis,side,1.95,style)

static func ground_rooms(n: Node3D,u0: float,u1: float,v0: float,v1: float) -> void:
	K.box(n,Vector3((u0+u1)/2,2.1,(v0+v1)/2),Vector3(u1-u0,4.2,v1-v0),"b7ad9e",true,15)
	for u in range(ceili(u0+1.2),floori(u1),3):
		for v in [v0-.08,v1+.08]:K.window(n,Vector3(u,2.15,v),.85,2.7,PI if v<v0 else 0)

static func stair(n: Node3D,p,a: Vector3,c: Vector3,width: float) -> void:
	D.stair(n,a,c,width)

static func build(b: Node3D,t) -> void:
	var p=load("res://world/visual_campus/ShawEastPodium.gd")
	var n:=K.holder(b,"TeachingACad",Vector3(-U0,0,-V0))
	# Low classroom wing/lecture rooms and taller teaching wing are not equal-height bars.
	wing(n,t,"LowClassroomWing",-15.0,-5.5,27,75,[4.2,8.7,13.05],1,1)
	ground_rooms(n,-15,-5.5,27,75)
	wing(n,t,"FrontLectureRooms",-15,14.5,75,91,[4.2,8.7,13.05],0,-1)
	ground_rooms(n,-15,14.5,75,91)
	wing(n,t,"RearTeachingWing",-15,37,17,26,[4.2,8.7,13.2,17.4,21.6],0,1)
	ground_rooms(n,-15,-2,17,26);ground_rooms(n,14.5,37,17,26)
	wing(n,t,"TallOpenArcadeWing",14.5,37,37.5,72,[8.7,13.2,17.4,21.6],1,-1)
	wing(n,t,"FrontLobbyWing",14.5,37,72,91,[8.7,13.2,17.4,21.6],0,-1,false)
	wing(n,t,"RearSeminarWing",17,37,26,37.5,[4.2,8.7,13.2,17.4,21.6],0,1)
	wing(n,t,"RearCourtUpper",-2,17,28,37.5,[8.7,13.2,17.4,21.6],0,1,false)
	ground_rooms(n,-2,17,28,37.5);ground_rooms(n,24,37,28,37.5)
	# Dedicated observed metal upper body and glazed open gallery replace generic slit walls.
	F.build(n)
	# Public floor rings: no full slab or terrain remains over the two central courts.
	for r:Rect2 in [Rect2(-18,13,16,83),Rect2(14.5,13,25.5,83),Rect2(-2,13,16.5,24.5),Rect2(-2,51.5,16.5,1.5),Rect2(-2,71.5,16.5,24.5)]:
		slab(n,r.position.x,r.end.x,r.position.y,r.end.y,0)
	slab(n,-2,14.5,53,71.5,-.15)
	# The CAD court is 150mm below datum; fitted bevels join the raised paving ring.
	# A vertical slab lip traps the walking capsule when returning out of the court.
	var outer:Array[Vector3]=[Vector3(-2,.065,53),Vector3(14.5,.065,53),Vector3(14.5,.065,71.5),Vector3(-2,.065,71.5)]
	var inner:Array[Vector3]=[Vector3(-.6,-.145,54.4),Vector3(13.1,-.145,54.4),Vector3(13.1,-.145,70.1),Vector3(-.6,-.145,70.1)]
	for i in 4:K.surface(n,K.quad(outer[i],outer[(i+1)%4],inner[(i+1)%4],inner[i]),"8f968e",41,true)
	slab(n,-2,14.5,37.5,51.5,PIT_LOW)
	# Retaining faces bound the light well without sealing its public stair entry.
	for u in [-2.0,14.5]:K.box(n,Vector3(u,PIT_LOW/2,44.5),Vector3(.28,-PIT_LOW,14),"9a9f93",true,15)
	for v in [37.5,51.5]:K.box(n,Vector3(6.25,PIT_LOW/2,v),Vector3(16.5,-PIT_LOW,.28),"9a9f93",true,15)
	for a:Array in [[Vector3(-2,0,37.5),Vector3(14.5,0,37.5)],[Vector3(14.5,0,37.5),Vector3(14.5,0,51.5)],[Vector3(14.5,0,51.5),Vector3(-2,0,51.5)],[Vector3(-2,0,37.5),Vector3(-2,0,48.5)]]:D.rail(n,a[0],a[1])
	# Two runs fit the CAD's corner stair position; exact treads/landings are fitted.
	slab(n,-4.5,-.5,48.7,51.4,0)
	stair(n,p,Vector3(6,-2.575,50),Vector3(-.5,0,50),2.5)
	slab(n,5.9,9,48.5,51.4,-2.575)
	stair(n,p,Vector3(7.5,PIT_LOW,40),Vector3(7.5,-2.575,48.5),2.5)
	# Drain strips above are relocated to the lower floor rather than floating at datum zero.
	var low:=K.holder(n,"LowerCourtDrain",Vector3(0,PIT_LOW,0))
	S.drain(low,Vector2(-.7,38.2),Vector2(13,38.2));K.finish(low)
	for u in [16.0,23.0,36.0]:
		for v in [73.0,89.5]:K.column(n,Vector3(u,0,v),8.7,.55)
	# Ground lobby opens to the front promenade and the inner cross-corridor.
	for v in [72.0]:
		for span:Vector2 in [Vector2(14.5,26),Vector2(31,37)]:
			K.box(n,Vector3((span.x+span.y)/2,2.05,v),Vector3(span.y-span.x,4.1,.08),"819b9f",true,19)
		K.box(n,Vector3(28.5,4.12,v),Vector3(5,.15,.2),"737f75",false,11)
	# 2F lobby ring leaves the stair opening clear; no invisible solid slab across the flight.
	slab(n,14.5,26,72,91,4.2);slab(n,35,37,72,91,4.2);slab(n,26,35,72,79,4.2);slab(n,26,35,88,91,4.2)
	stair(n,p,Vector3(28,0,79.5),Vector3(28,2.1,86),2.5)
	slab(n,26.5,33.5,86,88,2.1)
	stair(n,p,Vector3(32,2.1,86),Vector3(32,4.2,79),2.5)
	D.rail(n,Vector3(26,4.2,79),Vector3(30.5,4.2,79))
	D.rail(n,Vector3(33.5,4.2,79),Vector3(35,4.2,79))
	D.rail(n,Vector3(26,4.2,79),Vector3(26,4.2,88))
	D.build(n)
	# Front arcade and court columns follow the actual long open wing, not the old front bar.
	for v in range(42,71,7):
		K.box(n,Vector3(25.5,8.45,v),Vector3(21.8,.3,.34),"a4ada0",false,15)
	S.drain(n,Vector2(-4.5,28),Vector2(-4.5,74))
	S.drain(n,Vector2(38.5,18),Vector2(38.5,90))
	# Perimeter and gate/B connections replace the former 114m-deep footprint paths.
	S.paving(n,-21,-18,13,100);S.paving(n,40,44,13,100);S.paving(n,-21,44,13,16);S.paving(n,-21,44,96,100)
	var site:=K.holder(b,"TeachingACadWorldLinks");site.transform=b.transform.affine_inverse()
	# Low rear road and rising gate link are owned by TeachingABRearRoad. Keep
	# only the upper perimeter outside its cut and the mall-side bridge continuation.
	# V197 gate promenade slopes upward from the rear; discard its old flat overlays.
	for r:Rect2 in [Rect2(-54,-76,19,5),Rect2(-121,-147,3,58),Rect2(-121,-150,86,5)]:
		K.box(site,Vector3(r.get_center().x,2.30,r.get_center().y),Vector3(r.size.x,.035,r.size.y),"a2a69d",false,40)
	K.finish(site);K.finish(n)
