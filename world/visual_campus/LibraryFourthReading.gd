extends RefCounted
## 2024-09-06 official update + 2024-11-12 locator; old recovered4F supplies topology only.
## Furniture dimensions/spacing fitted to the current wing; not an as-built registration.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const D := preload("res://world/visual_campus/LibraryDiagonalCore.gd")
const Y := 12.8
const BOOK_COLORS := ["707d80","c0b9a2","887c66","536977","9d846b","c5c3b7","697067","8b9690"]

static func shelf(parent:Node3D,p:Vector3,yaw:float,length:float,section:String) -> void:
	var n:=K.holder(parent,"OakStacks_"+section,p);n.rotation.y=yaw
	# Open shelves, six book levels, solid frame footprint; cornice/panelled ends from image04.
	K.box(n,Vector3(0,1.18,0),Vector3(length,2.36,.72),"a38153",true,4)
	K.box(n,Vector3(0,1.25,0),Vector3(length-.23,2.13,.75),"655b48",false,22)
	for side in [-1,1]:
		K.box(n,Vector3(side*(length/2-.06),1.22,0),Vector3(.12,2.44,.87),"b4935e",false,4)
		# Recessed panel reads from the end, including a raised border and stepped base.
		K.box(n,Vector3(side*(length/2+.007),1.28,0),Vector3(.026,1.84,.64),"927043",false,4)
		K.box(n,Vector3(side*(length/2+.026),1.28,0),Vector3(.026,1.67,.48),"ae8c55",false,4)
	K.box(n,Vector3(0,.12,0),Vector3(length+.13,.24,.94),"947347",false,4)
	K.box(n,Vector3(0,2.40,0),Vector3(length+.15,.11,.96),"bf9f70",false,4)
	K.box(n,Vector3(0,2.48,0),Vector3(length+.24,.05,1.02),"c6ad81",false,4)
	var bays:=maxi(1,int(length/1.05))
	for i in range(1,bays):K.box(n,Vector3(-length/2+length*i/bays,1.27,0),Vector3(.045,2.22,.81),"b29669",false,4)
	for row in 6:
		var base:float=.23+row*.345
		K.box(n,Vector3(0,base,0),Vector3(length-.15,.032,.88),"c4aa7c",false,4)
		var count:=int((length-.28)/.115)
		for j in count:
			if (j+row*11)%23==0:continue
			var h:float=.22+float((j*7+row*3)%9)*.009
			for side in [-1,1]:
				var pos:=Vector3(-length/2+.16+j*.115,base+h/2+.022,side*.421)
				K.box(n,pos,Vector3(.079,h,.08),BOOK_COLORS[(j*3+row+side+8)%8],false,22)
				if j%3==0:K.box(n,pos+Vector3(0,-h*.29,side*.043),Vector3(.052,.032,.006),"e2dfcf",false,22)
	for side in [-1,1]:
		K.box(n,Vector3(side*(length/2+.045),2.13,0),Vector3(.018,.18,.45),"eee9d7",false,22)
		var label:=K.label(n,section,Vector3(side*(length/2+.06),2.13,0),.0021);label.rotation.y=side*PI/2
	K.finish(n)

static func chair(parent:Node3D,p:Vector3,yaw:float) -> void:
	var n:=K.holder(parent,"OakReadingChair",p);n.rotation.y=yaw
	K.box(n,Vector3(0,.43,0),Vector3(.46,.07,.47),"b49b6d",true,4)
	for x in [-.19,.19]:
		for z in [-.19,.19]:K.box(n,Vector3(x,.21,z),Vector3(.044,.42,.044),"a3885c",false,4)
		K.box(n,Vector3(x,.69,-.21),Vector3(.042,.53,.044),"ac9266",false,4)
	K.box(n,Vector3(0,.77,-.21),Vector3(.43,.23,.05),"bfa579",false,4)
	K.finish(n)

static func table(parent:Node3D,p:Vector3,yaw:float=0) -> void:
	var n:=K.holder(parent,"FourSeatWoodTable",p);n.rotation.y=yaw
	K.box(n,Vector3(0,.755,0),Vector3(1.9,.08,1.05),"bca479",true,4)
	for x in [-.82,.82]:
		for z in [-.40,.40]:K.box(n,Vector3(x,.36,z),Vector3(.07,.72,.07),"ab8e60",false,4)
	for side in [-1,1]:
		K.box(n,Vector3(side*.88,1.02,0),Vector3(.024,.50,.024),"929c97",false,11)
		for x in [-.50,.50]:chair(n,Vector3(x,0,side*.88),PI if side>0 else 0)
	K.box(n,Vector3(0,1.25,0),Vector3(1.83,.045,.065),"9da69b",false,11)
	K.box(n,Vector3(0,1.225,0),Vector3(1.63,.012,.045),"e9e0c6",false,17)
	K.box(n,Vector3(.66,.81,.20),Vector3(.17,.035,.08),"6d736a",false,22)
	K.finish(n)

static func cambridge_bay(parent:Node3D) -> void:
	var n:=K.holder(parent,"CambridgeWindowReadingBay",Vector3(0,Y,0))
	# Keep the remote WC/stair corridor x=-33 clear; photo shows timber in this end bay.
	K.box(n,Vector3(-27,.009,-22.5),Vector3(11,.018,7),"b6a077",false,43)
	shelf(n,Vector3(-25.5,0,-25.1),0,5.8,"Cambridge")
	# One-person glass pod, not the large5F group cells. Location within end bay remains fitted.
	var pod:=K.holder(n,"FourthSingleSilenceCell",Vector3(-30,0,-24.2))
	K.box(pod,Vector3(0,1.10,-.55),Vector3(1.12,2.20,.13),"444e4b",true,22)
	for x in [-.56,.56]:
		K.box(pod,Vector3(x,1.10,0),Vector3(.085,2.20,1.12),"4a514d",true,22)
		K.box(pod,Vector3(x*.92,1.12,0),Vector3(.018,1.90,.9),"9cadab",false,19)
	K.box(pod,Vector3(0,2.22,0),Vector3(1.2,.10,1.23),"3f4744",false,22)
	K.box(pod,Vector3(0,.035,0),Vector3(1.2,.07,1.23),"48554f",true,22)
	K.box(pod,Vector3(0,1.12,.57),Vector3(1.00,2.06,.045),"a2b9b3",true,19)
	K.box(pod,Vector3(.35,1.04,.62),Vector3(.038,.25,.045),"b3b8ad",false,11)
	K.box(pod,Vector3(0,1.05,-.18),Vector3(.81,.06,.40),"bba580",false,4)
	K.box(pod,Vector3(0,.54,.10),Vector3(.37,.07,.35),"647974",false,22)
	K.box(pod,Vector3(0,.27,.10),Vector3(.07,.54,.07),"777f77",false,11)
	K.finish(pod)
	var plant:=K.holder(n,"WindowPalmPot",Vector3(-28.6,0,-24.1))
	var pot:=MeshInstance3D.new();var mesh:=CylinderMesh.new();mesh.top_radius=.27;mesh.bottom_radius=.20;mesh.height=.46;mesh.radial_segments=16
	pot.mesh=mesh;pot.position.y=.23;pot.material_override=K.material("c0bbaa",22);plant.add_child(pot)
	K.box(plant,Vector3(0,.24,0),Vector3(.42,.48,.42),"bdb7a7",true,22)
	for i in 14:
		var angle:float=i*2.39996;var direction:=Vector3(cos(angle),0,sin(angle));var across:=Vector3(-direction.z,0,direction.x)*.065
		var base:=Vector3(0,.42,0);var bend:=direction*(.24+i%3*.07)+Vector3.UP*(1.1+i%4*.11);var tip:=direction*(.54+i%3*.09)+Vector3.UP*(.82+i%4*.10)
		K.surface(plant,K.quad(base-across*.25,base+across*.25,bend+across,bend-across),"52715a",22)
		K.surface(plant,K.quad(bend-across,bend+across,tip,tip),"5f7b60",22)
	K.finish(plant)
	K.box(n,Vector3(-25.5,2.31,-24.60),Vector3(3.7,.20,.024),"e6dfca",false,22)
	K.label(n,"Cambridge University Press",Vector3(-25.5,2.31,-24.58),.0025).modulate=Color("4f584f")
	K.finish(n)

static func build(parent:Node3D) -> void:
	var n:=K.holder(parent,"LibraryFourthReading2024")
	# Four collection bands follow the updated map; actual row count is not recoverable from icons.
	for i in 6:shelf(n,Vector3(-31+i*2,Y,-3.8),PI/2,6.4,"H–P")
	for i in 6:shelf(n,Vector3(-30.5+i*3,Y,23.6),PI/2,2.9,"D–H")
	for i in 6:shelf(n,Vector3(19+i*2.5,Y,-3-i*2.5),-PI/4,5.8,"P–Z")
	# V109: retire the four racks fitted to the oversized legacy core. The official-plan
	# front wing is deeper than the current shell; restore A-D after that shell is registered.
	# 20 tables /80 chairs are the documented 2024 additions, not a claimed total inventory.
	for x in [-28.7,-24.2]:
		for z in [-17.8,-13.4,-9.0]:table(n,Vector3(x,Y,z))
	for z in [-3.5,.5,4.5]:table(n,Vector3(-37.8,Y,z),PI/2)
	for p:Vector2 in [Vector2(29,2),Vector2(33,-2),Vector2(35,-6)]:
		# The narrowing rear wing cannot fit another table row without crossing the glass.
		table(n,Vector3(p.x,Y,p.y),PI/4)
	for p:Vector2 in [Vector2(-27,-21.4),Vector2(-22.5,-21.4),Vector2(-21.5,3.8)]:table(n,Vector3(p.x,Y,p.y))
	for x in [-21.0,-16.5,-12.0,-7.5,-3.0]:table(n,Vector3(x,Y,27.05))
	cambridge_bay(n)
	K.finish(n)
