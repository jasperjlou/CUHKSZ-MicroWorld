extends RefCounted
## Built form from WWJ's completed central-courtyard aerial, not the canteen interior palette.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const L := preload("res://world/visual_campus/LandmarkBuildings.gd")
const Public := preload("res://world/visual_campus/StudentPublicSpaces.gd")
const STONE := "b7bab5"

static func elevation(b: Node3D,p: Vector3,width: float,levels: Array,yaw: float=0.0,stone: String=STONE,openings: Array=[]) -> void:
	var wall:=K.holder(b,"RecessedStoneElevation",p);wall.rotation.y=yaw
	# Keep the old continuous physics envelope, but do not render it over interior window reveals.
	var collision_only:=K.holder(wall,"FacadeCollisionEnvelope");collision_only.hide()
	var count:=maxi(1,int(width/1.85));var pitch:=width/count;var opening:=pitch*.43
	var trim: String="556266"
	var sill: String="909894"
	var wall_kind: int=7 if stone==STONE else (21 if stone in ["bfa65e","bea757"] else 15)
	# Grey brick wraps exposed floor edges on this facade; courtyard soffits remain pale.
	for y in levels:K.box(wall,Vector3(0,y-.14,.025),Vector3(width,.28,.065),stone,false,wall_kind)
	for j in range(levels.size()-1):
		var low: float=levels[j];var high: float=levels[j+1];var h:=high-low;var mid: float=(low+high)/2
		for i in count:
			var x: float=-width/2+(i+.5)*pitch
			var doorway:=false
			for opening_rect: Rect2 in openings:
				if opening_rect.has_point(Vector2(x,mid)):doorway=true
			if doorway:continue
			# Historic010: narrow dark recessed casements, not white projecting window surrounds.
			K.box(wall,Vector3(x,low+.18,-.25),Vector3(pitch,.36,.5),stone,false,wall_kind)
			K.box(wall,Vector3(x,high-.17,-.25),Vector3(pitch,.34,.5),stone,false,wall_kind)
			# V224 official1F/2F dining photos: painted interior reveals, brick remains outside.
			if stone==STONE and low<8.8:
				K.box(wall,Vector3(x,low+.18,-.518),Vector3(pitch,.36,.032),"d7d8cb",false,22)
				K.box(wall,Vector3(x,high-.17,-.518),Vector3(pitch,.34,.032),"d7d8cb",false,22)
			var hall_upper_window:bool=low==12.4 and p.x< -23.0 and width>40.0
			K.box(wall,Vector3(x,mid+.01,-.39),Vector3(opening,h-.70,.09),"536b76",false,19 if low<12.4 or hall_upper_window else 5)
			for side in [-1,1]:
				K.box(wall,Vector3(x+side*(opening/2+(pitch-opening)/4),mid,-.25),Vector3((pitch-opening)/2,h,.5),stone,false,wall_kind)
				if stone==STONE and low<8.8:
					K.box(wall,Vector3(x+side*(opening/2+(pitch-opening)/4),mid,-.518),Vector3((pitch-opening)/2,h,.032),"d7d8cb",false,22)
				K.box(wall,Vector3(x+side*(opening/2-.025),mid+.01,-.27),Vector3(.055,h-.62,.14),trim,false,11)
			for y in [low+.36,low+1.02,high-.87,high-.34]:
				K.box(wall,Vector3(x,y,-.265),Vector3(opening,.055,.15),trim,false,11)
			K.box(wall,Vector3(x,low+.33,-.08),Vector3(opening+.10,.065,.34),sill,false,22)
			K.box(collision_only,Vector3(x,mid,-.45),Vector3(pitch,h,.14),"6a716e",true)
	K.finish(collision_only)
	K.finish(wall)

static func roof(b: Node3D,p: Vector3,w: float,d: float,top: float) -> void:
	K.box(b,p+Vector3(0,top,0),Vector3(w,.26,d),"8a9288",true,18)

static func parapet(b: Node3D,a: Vector3,c: Vector3) -> void:
	var yaw: float=-atan2(c.z-a.z,c.x-a.x);var length:=a.distance_to(c)
	K.box(b,(a+c)/2+Vector3.UP*.38,Vector3(length,.74,.24),STONE,false,6,yaw)
	K.box(b,(a+c)/2+Vector3.UP*.79,Vector3(length+.10,.08,.36),"c4cbc0",false,11,yaw)

static func build(b: Node3D,r: Dictionary,builder: RefCounted) -> void:
	preload("res://world/visual_campus/StudentRegisteredBuilding.gd").build(b,builder,elevation)
