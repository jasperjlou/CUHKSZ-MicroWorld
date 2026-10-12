extends RefCounted
## V169: architect section establishes open lower circulation and rising stairs.
## Opening placement, flight dimensions and retained 0/5.5/11.5 datums are fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/ShawEastPodium.gd")
const WELL=Rect2(-18,-8,8,20)

static func panels(n:Node3D,r:Rect2,y:float,solid:bool,color:String,kind:int,hole:bool=true)->void:
	var xs:Array[float]=[r.position.x,r.end.x];var zs:Array[float]=[r.position.y,r.end.y]
	if hole:
		for x in [WELL.position.x,WELL.end.x]:
			if x>r.position.x and x<r.end.x:xs.append(x)
		for z in [WELL.position.y,WELL.end.y]:
			if z>r.position.y and z<r.end.y:zs.append(z)
	xs.sort();zs.sort()
	for i in range(xs.size()-1):
		for j in range(zs.size()-1):
			var centre:=Vector2((xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2)
			if hole and WELL.has_point(centre):continue
			K.box(n,Vector3(centre.x,y-(.14 if solid else 0),centre.y),Vector3(xs[i+1]-xs[i],.28 if solid else .025,zs[j+1]-zs[j]),color,solid,kind)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"ResearchLowerCirculationV169")
	# First flight starts beneath the front wing, turns at the rear-side intermediate deck.
	P.stair(n,Vector3(-16,0,12),Vector3(-16,5.5,-8),3,true,true)
	P.stair(n,Vector3(-12,5.5,-8),Vector3(-12,11.5,12),3,true,true)
	# Existing slabs own both landings. Guards follow actual openings, leaving exit throats.
	for y:float in [5.5,11.5]:
		for x:float in [-18,-10]:P.rail(n,Vector3(x,y,-8),Vector3(x,y,12),true)
		if y<6:
			P.rail(n,Vector3(-18,y,12),Vector3(-10,y,12),true)
		else:
			P.rail(n,Vector3(-18,y,-8),Vector3(-10,y,-8),true)
			P.rail(n,Vector3(-18,y,12),Vector3(-13.65,y,12),true)
		# A narrow stone coping defines the lightwell without projecting into its stairs.
		for x:float in [-18.16,-9.84]:K.box(n,Vector3(x,y+.012,2),Vector3(.24,.024,20),"cbcabc",false,26)
	# Pale public circulation paving and a darker joint band, rather than default grass.
	for y:float in [0,5.5]:
		panels(n,Rect2(-22,-12,25,28),y+.018,false,"b2b3a8",26,y>0)
		for z:float in [-10.5,14.5]:K.box(n,Vector3(-10,y+.037,z),Vector3(24,.012,.09),"737d73",false,11)
	# Short garden apron connects the stair landing to the existing axial path.
	K.box(n,Vector3(-6,11.523,13.4),Vector3(18,.024,2.7),"b3b5a8",false,26)
	# Exposed soffit ribs stop outside the lightwell; no fictitious rooms or extra basement.
	for y:float in [5.5,11.5]:
		for x:float in [-23,4,18]:
			K.box(n,Vector3(x,y-.40,0),Vector3(.32,.26,70),"c8cdc1",false,22)
			for z:float in [-24,-2,22]:K.box(n,Vector3(x+1.2,y-.30,z),Vector3(.16,.045,2.6),"e1e5cb",false,17)
	# Low-energy fill keeps the lower walkway readable under the retained deep podium.
	for pos:Vector3 in [Vector3(-10,4.8,14),Vector3(-14,10.8,-9),Vector3(0,4.8,-10)]:
		var light:=OmniLight3D.new();light.position=pos;light.light_color=Color("f1efda");light.light_energy=.5;light.omni_range=17;light.shadow_enabled=false;n.add_child(light)
	K.finish(n)
