extends RefCounted
## Official CITIC panorama25181826; 2024 ITSO confirms shared card/bank use.
## Furniture reflects a historical panorama (2020 decoration), not a current-condition claim.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")

static func upholstered(b:Node3D,p:Vector3,size:Vector3,color:String,vertical:bool=false) -> void:
	# Rounded fabric silhouette, with the same simple box collision used by the route batch.
	var n:=K.holder(b,"RoundedUpholstery",p)
	var shape:=BoxShape3D.new();shape.size=size
	var body:=StaticBody3D.new();var c:=CollisionShape3D.new();c.shape=shape;body.add_child(c);n.add_child(body)
	var render:=K.holder(n,"Fabric")
	var dims:=size
	if vertical:render.rotation.x=PI/2;dims=Vector3(size.x,size.z,size.y)
	var r:=minf(.085,minf(dims.x,dims.z)*.23);var ring:Array[Vector3]=[]
	for corner in 4:
		var angle:float=corner*PI/2
		var centre:=Vector2((dims.x/2-r)*(1 if corner in [0,3] else -1),(dims.z/2-r)*(1 if corner<2 else -1))
		for j in 5:
			var a:float=angle+j*PI/8
			ring.append(Vector3(centre.x+cos(a)*r,0,centre.y+sin(a)*r))
	var vertices:=PackedVector3Array()
	for i in ring.size():
		var a:Vector3=ring[i];var z:Vector3=ring[(i+1)%ring.size()]
		var u:=a+Vector3.UP*dims.y/2;var v:=z+Vector3.UP*dims.y/2
		var l:=a-Vector3.UP*dims.y/2;var m:=z-Vector3.UP*dims.y/2
		vertices.append_array(K.quad(Vector3.UP*dims.y/2,u,v,Vector3.UP*dims.y/2))
		var underside:=K.quad(-Vector3.UP*dims.y/2,l,m,-Vector3.UP*dims.y/2)
		for j in range(0,underside.size(),3):vertices.append_array(PackedVector3Array([underside[j],underside[j+2],underside[j+1]]))
		vertices.append_array(PackedVector3Array([l,u,v,l,v,m,l,v,u,l,m,v]))
	K.surface(render,vertices,color,15)

static func chair(b:Node3D,p:Vector3,color:String,yaw:float=0) -> void:
	var n:=K.holder(b,"ServiceChair",p);n.rotation.y=yaw
	upholstered(n,Vector3(0,.47,0),Vector3(.57,.12,.55),color)
	upholstered(n,Vector3(0,.79,-.245),Vector3(.58,.56,.10),color,true)
	K.box(n,Vector3(0,.23,0),Vector3(.08,.46,.08),"959c96",false,11)
	for a in [0.0,PI/3,2*PI/3]:K.box(n,Vector3(0,.045,0),Vector3(.62,.045,.055),"808b82",false,11,a)
	K.finish(n)

static func terminal(b:Node3D,p:Vector3,red:bool) -> void:
	var n:=K.holder(b,"SelfServiceTerminal",p)
	n.rotation.y=PI # Screens face the room, not the outside glazing.
	K.box(n,Vector3(0,.83,0),Vector3(.78,1.66,.57),"a03938" if red else "b7bcb1",true,22)
	K.box(n,Vector3(0,1.21,.30),Vector3(.57,.50,.025),"35494c",false,5)
	K.box(n,Vector3(0,.84,.32),Vector3(.55,.075,.19),"4b5650",false,11)
	K.box(n,Vector3(0,.64,.30),Vector3(.35,.045,.022),"303b37",false,11)
	K.box(n,Vector3(0,1.56,.305),Vector3(.40,.08,.025),"e0e4d9",false,22)
	K.finish(n)

static func build(parent:Node3D) -> void:
	var n:=K.holder(parent,"SharedCardBankPublicRoomV130")
	# Public hall16x9.6m is fitted to the retained frontage, expanded from the former4.7m stub.
	K.box(n,Vector3(0,.019,-4.85),Vector3(15.9,.032,9.45),"c5c4b0",false,12)
	K.box(n,Vector3(-6.0,.041,-4.15),Vector3(3.5,.012,5.6),"b89e73",false,43)
	K.box(n,Vector3(0,3.52,-4.85),Vector3(15.9,.10,9.45),"d7dbd1",false,22)
	for x in [-6.1,-2.7,2.1,5.6]:
		for z in [-2,-5,-8]:
			K.box(n,Vector3(x,3.456,z),Vector3(.21,.02,.21),"e9e9dc",false,17)
	for x in [-4.2,4.2]:
		K.box(n,Vector3(x,3.452,-4.8),Vector3(1.3,.025,3.6),"e8e9df",false,17)
		for z in [-2,-7.5]:
			K.box(n,Vector3(x,3.45,z),Vector3(.72,.026,.26),"687169",false,11)
			for i in 9:K.box(n,Vector3(x-.32+i*.08,3.432,z),Vector3(.025,.015,.25),"a9b1a5",false,11)
	# A short side partition separates service rows while leaving a broad shared arrival aisle.
	K.box(n,Vector3(.20,1.73,-7.15),Vector3(.18,3.46,4.7),"d0d4c7",true,22)
	K.box(n,Vector3(.20,3.17,-3.05),Vector3(.18,.62,3.5),"d0d4c7",false,22)
	# Two teller windows and a closed staff boundary; staff/security rooms are not invented.
	K.box(n,Vector3(-4,1.72,-8.35),Vector3(7.8,3.44,.18),"cbd0c2",true,22)
	for x in [-5.6,-2.4]:
		K.box(n,Vector3(x,.57,-8.03),Vector3(2.7,1.14,.52),"b0a07e",true,43)
		K.box(n,Vector3(x,1.17,-7.97),Vector3(2.84,.10,.75),"d8dbd0",true,22)
		K.box(n,Vector3(x,2.02,-8.21),Vector3(2.64,1.59,.06),"7eaaa7",false,48)
		for dx in [-1.35,1.35]:K.box(n,Vector3(x+dx,1.99,-8.14),Vector3(.065,1.79,.11),"858f87",false,11)
		K.box(n,Vector3(x,2.86,-8.14),Vector3(2.75,.06,.11),"858f87",false,11)
		chair(n,Vector3(x,0,-6.95),"9a383a")
	var bank:=K.label(n,"中信银行  CITIC BANK",Vector3(-4,2.30,-8.11),.004);bank.modulate=Color("3e5553")
	# Four grey upholstered waiting benches on the inset wood strip.
	for z in [-2.2,-3.35,-4.5,-5.65]:
		upholstered(n,Vector3(-6,.43,z),Vector3(2.65,.27,.67),"a0a59b")
		for x in [-6.95,-5.05]:K.box(n,Vector3(x,.17,z),Vector3(.065,.34,.53),"778077",false,11)
	terminal(n,Vector3(-6.9,0,-.55),false);terminal(n,Vector3(-5.45,0,-.55),true)
	# Low white island counter, with stools tucked to one side and a clear central aisle.
	K.box(n,Vector3(-1.2,.51,-4.5),Vector3(1.18,1.02,3.6),"d2d7cc",true,22)
	K.box(n,Vector3(-1.2,1.07,-4.5),Vector3(1.38,.09,3.8),"e0e3d6",true,22)
	for z in [-3.5,-5.4]:
		K.box(n,Vector3(-2.25,.68,z),Vector3(.49,.07,.43),"a0afa7",true,15)
		K.box(n,Vector3(-2.25,.32,z),Vector3(.065,.64,.065),"929b93",false,11)
		K.box(n,Vector3(-2.25,.055,z),Vector3(.43,.07,.43),"919a93",false,11)
	# Campus card consultation row: purple privacy screens, white desks, rolling chairs.
	for z in [-2.9,-4.8,-6.7]:
		K.box(n,Vector3(4.75,.75,z),Vector3(1.55,.10,1.58),"d8dcd2",true,22)
		for x in [4.03,5.47]:K.box(n,Vector3(x,.36,z),Vector3(.07,.72,1.44),"d2d6cb",true,22)
		K.box(n,Vector3(4.72,1.22,z-.81),Vector3(1.75,.90,.075),"783955",true,15)
		K.box(n,Vector3(4.8,1.0,z),Vector3(.05,.38,.57),"3a4946",false,11)
		K.box(n,Vector3(4.68,.81,z),Vector3(.27,.035,.45),"5b6963",false,11)
		chair(n,Vector3(3.15,0,z),"873e5e",PI/2)
		chair(n,Vector3(6.05,0,z),"a1aaa0",-PI/2)
	# Pale cabinets with a timber top run behind the staff side, as in the panorama.
	K.box(n,Vector3(7.60,.44,-5.1),Vector3(.60,.88,7.8),"d3d5c8",true,22)
	K.box(n,Vector3(7.60,.91,-5.1),Vector3(.64,.08,7.87),"bea57a",true,43)
	for i in 9:
		var z:float=-1.65-i*.86
		K.box(n,Vector3(7.286,.45,z),Vector3(.014,.72,.018),"879082",false,11)
		K.box(n,Vector3(7.261,.54,z-.18),Vector3(.035,.14,.025),"818b80",false,11)
	K.box(n,Vector3(4.5,.38,-8.86),Vector3(2.7,.43,.78),"9d3d3d",true,15)
	K.box(n,Vector3(4.5,.78,-9.18),Vector3(2.7,.62,.12),"9d3d3d",true,15)
	var card:=K.label(n,"校园卡服务",Vector3(7.04,2.1,-5.15),.007);card.rotation.y=-PI/2;card.modulate=Color("68374f")
	for x in [-4.2,4.2]:
		var light:=OmniLight3D.new();light.position=Vector3(x,2.7,-4.8);light.omni_range=10;light.light_energy=.65;light.light_color=Color("eee8d8");n.add_child(light)
	K.finish(n)
