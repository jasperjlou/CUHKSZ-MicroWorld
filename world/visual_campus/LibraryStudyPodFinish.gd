extends RefCounted
## V242:2025 photo and official G panorama: silver frames, translucent film and open leaves.
## All finish parts are non-colliding; metric heights and spacing remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const FILM_Y:float=1.32
const FILM_H:float=.90
static func strip(b:Node3D,a:Vector2,c:Vector2,y:float,h:float,t:float,color:String,kind:int)->void:
	var d:=c-a
	K.box(b,Vector3((a.x+c.x)/2,y,(a.y+c.y)/2),Vector3(d.length()+.012,h,t),color,false,kind,-atan2(d.y,d.x))
static func glass(b:Node3D,a:Vector2,c:Vector2)->void:
	# Retain the former solid box exactly, but render one clear sheet: stacked
	# transparent box side-faces caused false vertical stripes at curved joins.
	var d:=c-a;var body:StaticBody3D
	if b.has_node("Solid"):body=b.get_node("Solid")
	else:body=StaticBody3D.new();body.name="Solid";b.add_child(body)
	var shape:=BoxShape3D.new();shape.size=Vector3(d.length()+.012,3.5,.065)
	var collision:=CollisionShape3D.new();collision.shape=shape
	collision.position=Vector3((a.x+c.x)/2,1.8,(a.y+c.y)/2);collision.rotation.y=-atan2(d.y,d.x);body.add_child(collision)
	var verts:=K.quad(Vector3(a.x,.05,a.y),Vector3(c.x,.05,c.y),Vector3(c.x,3.55,c.y),Vector3(a.x,3.55,a.y))
	var pane:=K.surface(b,verts,"bdcece",80)
	pane.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
static func film(b:Node3D,a:Vector2,c:Vector2)->void:
	strip(b,a,c,FILM_Y,FILM_H,.075,"bac8c7",79)
	# Small square markers sit above the frosted band, seen in the newer photo.
	var count:=maxi(1,ceili(a.distance_to(c)/.22))
	var d:=c-a;var yaw:float=-atan2(d.y,d.x)
	for i in count:
		var p:=a.lerp(c,(i+.5)/count)
		for y in [1.84,1.94]:K.box(b,Vector3(p.x,y,p.y),Vector3(.032,.032,.077),"d2d8d1",false,22,yaw)
static func jambs(b:Node3D,width:float,z:float)->void:
	for x in [-width/2,width/2]:
		K.box(b,Vector3(x,1.8,z),Vector3(.045,3.42,.11),"bbc3bd",false,11)
	K.box(b,Vector3(0,3.52,z),Vector3(width+.045,.065,.11),"bbc3bd",false,11)
	# Flush metal separator between retained timber and public carpet.
	K.box(b,Vector3(0,.114,z),Vector3(width,.008,.045),"a5afa9",false,11)
static func open_leaf(b:Node3D,x:float,z:float,length:float,handle_side:float)->void:
	var a:=Vector2(x,z-length/2);var c:=Vector2(x,z+length/2)
	strip(b,a,c,1.77,3.40,.045,"bdcece",80);film(b,a,c)
	for y in [.10,3.46]:strip(b,a,c,y,.045,.060,"b7c1bb",11)
	for end in [z-length/2,z+length/2]:K.box(b,Vector3(x,1.78,end),Vector3(.06,3.40,.035),"b7c1bb",false,11)
	var free_end:float=z-length/2+.14
	K.box(b,Vector3(x+handle_side*.078,1.13,free_end),Vector3(.025,.34,.025),"c4ccc4",false,11)
	for y in [.98,1.28]:K.box(b,Vector3(x+handle_side*.045,y,free_end),Vector3(.075,.025,.025),"aab6ad",false,11)
	for y in [.36,2.90]:K.box(b,Vector3(x,y,z+length/2-.06),Vector3(.080,.10,.045),"9fac9f",false,11)
