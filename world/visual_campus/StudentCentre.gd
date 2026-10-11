extends RefCounted
## Built form from WWJ's completed central-courtyard aerial, not the canteen interior palette.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const L := preload("res://world/visual_campus/LandmarkBuildings.gd")
const Public := preload("res://world/visual_campus/StudentPublicSpaces.gd")
const STONE := "b7bab5"

static func elevation(b: Node3D,p: Vector3,width: float,levels: Array,yaw: float=0.0,stone: String=STONE,openings: Array=[]) -> void:
	var wall:=K.holder(b,"RecessedStoneElevation",p);wall.rotation.y=yaw
	var count:=maxi(1,int(width/1.85));var pitch:=width/count;var opening:=pitch*.43
	var trim: String="727a78" if stone=="5d6262" else "ccd0c9"
	var sill: String="6e7570" if stone=="5d6262" else "d4d5cd"
	var wall_kind: int=7 if stone==STONE else (21 if stone in ["bfa65e","bea757"] else 15)
	for j in range(levels.size()-1):
		var low: float=levels[j];var high: float=levels[j+1];var h:=high-low;var mid: float=(low+high)/2
		for i in count:
			var x: float=-width/2+(i+.5)*pitch
			var doorway:=false
			for opening_rect: Rect2 in openings:
				if opening_rect.has_point(Vector2(x,mid)):doorway=true
			if doorway:continue
			K.box(wall,Vector3(x,low+.43,-.25),Vector3(pitch,.86,.5),stone,false,wall_kind)
			K.box(wall,Vector3(x,high-.27,-.25),Vector3(pitch,.54,.5),stone,false,wall_kind)
			K.window(wall,Vector3(x,mid+.16,-.38),opening,h-1.42)
			for side in [-1,1]:
				K.box(wall,Vector3(x+side*(opening/2+(pitch-opening)/4),mid,-.25),Vector3((pitch-opening)/2,h,.5),stone,false,wall_kind)
				K.box(wall,Vector3(x+side*(opening/2+.045),mid+.16,-.09),Vector3(.09,h-1.26,.22),trim)
			K.box(wall,Vector3(x,low+.83,-.02),Vector3(opening+.16,.09,.48),sill)
			K.box(wall,Vector3(x,mid,-1.15),Vector3(pitch,h,.24),"6a716e",true)
	K.finish(wall)

static func roof(b: Node3D,p: Vector3,w: float,d: float,top: float) -> void:
	K.box(b,p+Vector3(0,top,0),Vector3(w,.26,d),"8a9288",true,18)

static func parapet(b: Node3D,a: Vector3,c: Vector3) -> void:
	var yaw: float=-atan2(c.z-a.z,c.x-a.x);var length:=a.distance_to(c)
	K.box(b,(a+c)/2+Vector3.UP*.38,Vector3(length,.74,.24),STONE,false,6,yaw)
	K.box(b,(a+c)/2+Vector3.UP*.79,Vector3(length+.10,.08,.36),"c4cbc0",false,11,yaw)

static func build(b: Node3D,r: Dictionary,builder: RefCounted) -> void:
	var w: float=r.width;var d: float=r.depth;var levels: Array=r.floor_levels
	var top: float=levels[-1]
	# V49: preserve the mall facade; depth follows the published plan's proportions.
	for side in [-1,1]:
		var x: float=side*24
		for y in levels.slice(1):K.box(b,Vector3(x,y-.15,0),Vector3(22,.30,d),"b9bdb6",true,22)
		var doors: Array=[Rect2(-39,0,8,8.8),Rect2(30,0,10,8.8)]
		elevation(b,Vector3(side*35,0,0),d,levels,side*PI/2,STONE,doors)
		# Two independent gallery edges, with openings into the stepped central courts.
		for j in range(2,levels.size()-1):
			var low: float=levels[j];var high: float=levels[j+1]
			elevation(b,Vector3(side*13,0,0),d-14,[low,high],-side*PI/2,"a88175" if side<0 else "bfa65e",[Rect2(-40,low,80,high-low)] if j in [2,3] else [])
		roof(b,Vector3(x,0,0),22,d,top)
	# A tall front opening reaches 5F. The former 3F lintel made the portal too low.
	for side in [-1,1]:
		var x: float=side*24
		elevation(b,Vector3(x,0,d/2),22,levels)
		elevation(b,Vector3(side*13,0,d/2-4),8,[0,4.4,8.8,12.4,16],-side*PI/2,"a27568")
	for y in [16.0,19.6,23.2]:K.box(b,Vector3(0,y-.15,d/2-4),Vector3(26,.30,8),"bbbfb5",true,22)
	elevation(b,Vector3(0,0,d/2),26,[16,19.6,23.2])
	# Rear bar and its ground doorway keep the building connected to the hillside walk.
	for y in levels.slice(1):K.box(b,Vector3(0,y-.15,-d/2+4),Vector3(26,.30,8),"b9bdb6",true,22)
	elevation(b,Vector3(0,0,-d/2),70,levels,PI,STONE,[Rect2(-3,0,6,4.4)])
	# High cross wing frames the next courtyard while preserving the lower passage.
	for y in [16.0,19.6,23.2]:K.box(b,Vector3(0,y-.15,1),Vector3(26,.30,8),"b9bdb6",true,22)
	for z in [-3,5]:elevation(b,Vector3(0,0,z),26,[16,19.6,23.2],0 if z>0 else PI,"bea757")
	for rect: Rect2 in [Rect2(-35,-d/2,70,d),Rect2(-13,5,26,d/2-13),Rect2(-13,-d/2+8,26,d/2-11)]:
		var pts: Array[Vector3]=[Vector3(rect.position.x,top,rect.position.y),Vector3(rect.end.x,top,rect.position.y),Vector3(rect.end.x,top,rect.end.y),Vector3(rect.position.x,top,rect.end.y)]
		for i in 4:parapet(b,pts[i],pts[(i+1)%4])
	preload("res://world/visual_campus/StudentTerracedCourts.gd").build(b,builder)
