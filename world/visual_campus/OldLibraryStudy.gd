extends RefCounted
## V168 named old-library3F pano25322346: open beams, suspended strips,
## pale concave computer desks and mesh-back task chairs. Fitted arrangement, date unknown.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const CUTS=[Rect2(-22,-3.5,32,7),Rect2(-40,-5.95,10,4.2),Rect2(-40,2.05,10,4.2),Rect2(30,2.05,10,4.2),Rect2(34.15,-5.4,3.3,3.2)]

static func clipped(n:Node3D,r:Rect2,y:float,h:float,color:String,kind:int)->void:
	var parts:Array[Rect2]=[r]
	for hole:Rect2 in CUTS:
		var next:Array[Rect2]=[]
		for p in parts:
			var c:=p.intersection(hole)
			if not c.has_area():next.append(p);continue
			for q:Rect2 in [Rect2(p.position,Vector2(c.position.x-p.position.x,p.size.y)),Rect2(Vector2(c.end.x,p.position.y),Vector2(p.end.x-c.end.x,p.size.y)),Rect2(Vector2(c.position.x,p.position.y),Vector2(c.size.x,c.position.y-p.position.y)),Rect2(Vector2(c.position.x,c.end.y),Vector2(c.size.x,p.end.y-c.end.y))]:
				if q.has_area():next.append(q)
		parts=next
	for p in parts:K.box(n,Vector3(p.get_center().x,y,p.get_center().y),Vector3(p.size.x,h,p.size.y),color,false,kind)

static func luminaire(n:Node3D,x:float,z:float,ceiling:float,length:float)->void:
	K.box(n,Vector3(x,ceiling-.76,z),Vector3(length,.07,.20),"899187",false,11)
	K.box(n,Vector3(x,ceiling-.803,z),Vector3(length-.06,.016,.16),"eee9cf",false,17)
	for side in [-1,1]:K.box(n,Vector3(x+side*(length/2-.18),ceiling-.43,z),Vector3(.013,.60,.013),"6d756d",false,11)

static func chair(n:Node3D,p:Vector3)->void:
	var b:=K.holder(n,"MeshTaskChair",p)
	K.box(b,Vector3(0,.47,0),Vector3(.54,.095,.52),"252b2a",true,25)
	K.box(b,Vector3(0,.27,0),Vector3(.065,.38,.065),"414a47",false,11)
	for i in 5:
		var a:float=i*TAU/5;var v:=Vector3(cos(a)*.20,.12,sin(a)*.20)
		K.box(b,v,Vector3(.40,.045,.045),"333c37",false,11,-a)
		K.box(b,Vector3(cos(a)*.39,.10,sin(a)*.39),Vector3(.09,.10,.06),"252b2a",false,11)
	K.box(b,Vector3(0,.83,.24),Vector3(.53,.62,.065),"303837",true,56)
	for side in [-1,1]:
		K.box(b,Vector3(side*.265,.83,.24),Vector3(.035,.64,.075),"303837",false,11)
		K.box(b,Vector3(0,.83+side*.31,.24),Vector3(.55,.035,.075),"303837",false,11)
	for side in [-1,1]:
		K.box(b,Vector3(side*.30,.68,.04),Vector3(.05,.045,.36),"3b4540",false,11)
		K.box(b,Vector3(side*.30,.57,.13),Vector3(.04,.23,.04),"454e49",false,11)
	K.finish(b)

static func desk(n:Node3D,p:Vector3,yaw:float)->void:
	var b:=K.holder(n,"ConcaveComputerDesk",p);b.rotation.y=yaw
	# Curved waist at the front, using a triangulated tabletop with a visible edge.
	var outline:=PackedVector2Array([Vector2(-.72,-.38),Vector2(.72,-.38),Vector2(.72,.38),Vector2(.48,.38)])
	for i in range(1,12):
		var x:float=.48-i*.96/12;outline.append(Vector2(x,.20+.18*pow(absf(x)/.48,2)))
	outline.append(Vector2(-.48,.38));outline.append(Vector2(-.72,.38))
	var indices:=Geometry2D.triangulate_polygon(outline);var vertices:=PackedVector3Array()
	for i in range(0,indices.size(),3):
		var a:=outline[indices[i]];var c:=outline[indices[i+1]];var d:=outline[indices[i+2]]
		vertices.append_array(K.quad(Vector3(a.x,.78,a.y),Vector3(c.x,.78,c.y),Vector3(d.x,.78,d.y),Vector3(a.x,.78,a.y)))
	K.surface(b,vertices,"dfd4ae",22)
	var underside:=vertices.duplicate();for i in underside.size():underside[i].y-=.064
	underside.reverse();K.surface(b,underside,"c6b98f",22)
	for i in outline.size():
		var a:=outline[i];var c:=outline[(i+1)%outline.size()];var delta:=c-a
		K.box(b,Vector3((a.x+c.x)/2,.748,(a.y+c.y)/2),Vector3(delta.length(),.064,.015),"c6b98f",false,22,-atan2(delta.y,delta.x))
	for side in [-1,1]:K.box(b,Vector3(side*.67,.37,-.035),Vector3(.045,.74,.66),"d6c9a2",true,22)
	K.box(b,Vector3(0,.40,-.34),Vector3(1.40,.62,.05),"d6c9a2",true,22)
	var body:=StaticBody3D.new();var collider:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(1.44,.065,.72);collider.shape=shape;collider.position=Vector3(0,.74,-.03);body.add_child(collider);b.add_child(body)
	K.box(b,Vector3(0,1.04,-.42),Vector3(1.5,.52,.06),"454b48",true,11)
	K.box(b,Vector3(0,1.09,-.382),Vector3(1.37,.18,.012),"adb9ab",false,19)
	K.box(b,Vector3(.53,.93,-.379),Vector3(.10,.11,.012),"d7d8ca",false,22)
	for x:float in [.505,.545]:K.box(b,Vector3(x,.93,-.370),Vector3(.009,.04,.009),"535c54",false,11)
	K.box(b,Vector3(0,.81,-.13),Vector3(.29,.045,.20),"303934",false,11)
	K.box(b,Vector3(0,.93,-.16),Vector3(.05,.23,.045),"303934",false,11)
	K.box(b,Vector3(0,1.11,-.17),Vector3(.57,.35,.045),"242d28",false,11)
	K.box(b,Vector3(0,1.11,-.143),Vector3(.515,.29,.008),"293d42",false,5)
	K.box(b,Vector3(0,.802,.14),Vector3(.46,.035,.15),"29332d",false,11)
	for row in 4:
		for col in 13:K.box(b,Vector3(-.20+col*.032,.824,.09+row*.03),Vector3(.025,.006,.020),"68716a",false,11)
	K.box(b,Vector3(.37,.81,.15),Vector3(.055,.03,.09),"313a34",false,11)
	chair(b,Vector3(0,0,.90));K.finish(b)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"OldLibraryStudyV168",Vector3(0,0,-17.16))
	# Same exposed frame family on retained levels; spacing remains an estimate.
	for ceiling:float in [4.6,8.3,12.,15.7]:
		for x:float in [-38,-32,-26,-20,-14,-8,-2,4,10,16,22,28,34,40]:clipped(n,Rect2(x-.14,-7.0,.28,14),ceiling-.32,.40,"9da69c",22)
		for z:float in [-5.85,0,5.85]:clipped(n,Rect2(-41,z-.14,82,.28),ceiling-.35,.42,"949e93",22)
		for x:float in [-26,-18,-10,-2,6,14,22,28]:
			for z:float in [-5.05,5.05]:luminaire(n,x,z,ceiling,3.0 if x==28 else 4.7)
		for x:float in [16,24]:luminaire(n,x,0,ceiling,4.7)
		# A few broad fill lights support the visible strip fixtures, no global relighting.
		for x:float in [-17,22]:
			var light:=OmniLight3D.new();light.position=Vector3(x,ceiling-1.05,0);light.light_color=Color("ecebd8");light.light_energy=.36;light.omni_range=15;light.omni_attenuation=1.4;n.add_child(light)
	# Only3F has this independently observed pale floor and computer-furniture reference.
	clipped(n,Rect2(-41,-7.0,82,14),8.428,.008,"bbb59d",25)
	for x:float in [17,25]:
		for side in [-1,1]:
			for dx:float in [-.77,.77]:desk(n,Vector3(x+dx,8.432,side*.45),0 if side>0 else PI)
	# Low dark wood reference shelf stays away from the 3F lightwell entry.
	K.box(n,Vector3(12.3,9.10,0),Vector3(.5,1.34,4.2),"76573f",true,22)
	for z:float in [-1.5,-.5,.5,1.5]:
		for y:float in [8.77,9.4]:K.box(n,Vector3(12.03,y,z),Vector3(.025,.52,.82),"473c2e",false,22)
	K.finish(n)
