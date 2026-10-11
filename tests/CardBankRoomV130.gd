extends "res://tests/CourtyardRefinementCapture.gd"
var checks:Array=[]
func at(x:float,z:float,y:float=-1.76)->Vector3:return Vector3(-21+z,y,-425-x)
func walk(target:Vector3,label:String)->bool:
	# Indoor door leaves and desk corners need arrival tighter than the outdoor0.8m cutoff.
	var player:CharacterBody3D=world.player;var count:=0;var lowest:=player.position.y
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.18 and count<1800:
		player.navigation_direction=Vector2(target.x-player.position.x,target.z-player.position.z).normalized()
		await physics_frame;count+=1;lowest=minf(lowest,player.position.y)
	player.navigation_direction=Vector2.ZERO;await frames(12)
	var distance:=Vector2(target.x-player.position.x,target.z-player.position.z).length()
	var valid:=count<1800 and distance<.40 and lowest>-2.15 and absf(player.position.y-target.y)<.6
	if not valid:failures.append("physical route "+label)
	legs.append({"goal":label,"valid":valid,"frames":count,"distance":distance,"lowest_y":lowest,"end":[player.position.x,player.position.y,player.position.z]})
	print("CARD_BANK_LEG ",label," ",valid," ",player.position)
	return valid
func probe(label:String,a:Vector3,b:Vector3,expected:bool) -> void:
	var hit:=not world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(a,b,1)).is_empty()
	checks.append({"label":label,"valid":hit==expected,"hit":hit})
	if hit!=expected:failures.append(label)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()!="headless":
		await capture("card-bank-v130-entry",at(0,3,.0),at(-1,-4,.1))
		await capture("card-bank-v130-bank",at(-3.5,-1.5,-.03),at(-3.8,-7.6,-.13))
		await capture("card-bank-v130-card",at(1.6,-1.4,-.06),at(4.7,-6.3,-.15))
		await capture("card-bank-v130-return",at(-3.6,-7.2,.06),at(-4,-.3,-.18))
		FileAccess.open("res://tests/artifacts/card_bank_v130_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	await fixture(at(0,4,-1.46),[
		[at(0,-1.8),"shared glass entry"],[at(-3.6,-1.8),"bank arrival aisle"],
		[at(-3.6,-4.5),"waiting bench and counter aisle"],[at(-3.6,-7.0),"teller approach"],
		[at(-3.6,-4.5),"bank aisle return"],[at(-3.6,-1.4),"self service frontage"],
		[at(1.6,-1.4),"shared arrival to card side"],[at(1.6,-4.8),"card customer aisle"],
		[at(1.6,-8.0),"card rear passage"],[at(6.8,-8.0),"behind last partition"],
		[at(6.8,-4.8),"cabinet side aisle"],[at(6.8,-1.4),"cabinet aisle front"],
		[at(1.6,-1.4),"front cross aisle"],[at(0,-1.8),"shared entry return"],
		[at(0,4),"public concourse exit"],[Vector3(-12,-1.76,-425),"main hall aisle"],
		[Vector3(-12,-1.76,-443),"gift shop approach retained"],[Vector3(-17,-1.76,-443),"gift shop forecourt"],
		[Vector3(-12,-1.76,-443),"gift forecourt return"],[Vector3(-12,-1.76,-425),"card bank hall return"]])
	probe("teller boundary remains solid",at(-4,-7.1,-.2),at(-4,-8.7,-.2),true)
	probe("new deep floor supported",at(1.6,-8.7,-1.2),at(1.6,-8.7,-2.1),true)
	probe("back wall closed",at(1.6,-9,-.2),at(1.6,-10,-.2),true)
	probe("shared door headroom",at(0,1,.6),at(0,-1,.6),false)
	FileAccess.open("res://tests/artifacts/card_bank_v130_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"fixtures":1,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
