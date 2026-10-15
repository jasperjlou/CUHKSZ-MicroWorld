extends Node
## Local rule policy: observe -> legal action -> physical execution -> feedback.
signal changed
const FONT=preload("res://systems/ChineseText.gd").FONT
var world:Node3D
var host:Node
var registry:RefCounted
var ui:CanvasLayer
var chooser:OptionButton
var task_kind:OptionButton
var status_label:Label
var log_label:Label
var pause_button:Button
var camera:Camera3D
var active:=false
var paused:=false
var state:="idle"
var selected:=""
var queue:Array[String]=[]
var visited:Array[String]=[]
var trajectory:Array=[]
var route:=PackedInt64Array()
var leg:=0
var stalled:=0.0
var elapsed:=0.0
var best:=INF
var replans:=0
var distance:=0.0
var last_position:=Vector3.ZERO
var camera_yaw:=0.0
var messages:Array[String]=[]

func _ready()->void:
	camera=Camera3D.new();camera.fov=55;camera.near=.08;camera.far=1600;add_child(camera)
	ui=CanvasLayer.new();ui.layer=15;add_child(ui)
	var panel:=PanelContainer.new();panel.position=Vector2(18,18);panel.custom_minimum_size=Vector2(410,0)
	panel.add_theme_stylebox_override("panel",host.style(Color(.035,.10,.09,.94)));ui.add_child(panel)
	var box:=VBoxContainer.new();box.add_theme_constant_override("separation",10);panel.add_child(box)
	host.label(box,"Agent · 目标探索",25,Color("faf7e9"))
	host.label(box,"选择目标，观察途中环境并真实行走到达。",15,Color("c6d3cb"))
	chooser=OptionButton.new();chooser.add_theme_font_override("font",FONT);chooser.custom_minimum_size=Vector2(380,38);box.add_child(chooser)
	task_kind=OptionButton.new();task_kind.add_item("到达并观察所选地点");task_kind.add_item("探索所选地点，再访问附近两处")
	task_kind.add_theme_font_override("font",FONT);box.add_child(task_kind)
	var buttons:=HBoxContainer.new();box.add_child(buttons)
	button(buttons,"开始 / 改换目标",begin_selected)
	pause_button=button(buttons,"暂停",toggle_pause)
	button(buttons,"停止",cancel)
	status_label=host.label(box,"选择目标后开始",16,Color("e4dba5"));status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	log_label=host.label(box,"",14,Color("c6d3cb"));log_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	host.label(box,"本地规则 Agent · 遇阻重规划 · Esc 返回菜单",13,Color("a5b7ad"))
	button(box,"观看建筑编排导览",host.start_showcase)
	ui.hide()

func button(parent:Node,text:String,action:Callable)->Button:
	var b:=Button.new();b.text=text;b.add_theme_font_override("font",FONT);b.pressed.connect(action);parent.add_child(b);return b

func start()->void:
	if registry==null:
		registry=preload("res://world/product/CampusGoalGraph.gd").new();registry.build(world)
		for g:Dictionary in registry.goals.values():chooser.add_item(g.name);chooser.set_item_metadata(chooser.item_count-1,g.id)
	active=true;paused=false;state="idle";ui.show();camera.current=true
	world.player.agent_controlled=true;world.player.human_camera_enabled=false;world.player.show();world.player.model.show()
	world.player.set_physics_process(true);GameState.set_flag("paused",false)
	last_position=world.player.global_position;messages.clear();note("从当前位置出发；选择地点或建筑内部空间。")
	update_camera(1.0)

func stop()->void:
	cancel();active=false;ui.hide()

func cancel()->void:
	if state in ["walking","observing"]:record({"type":"cancel"},false,"CANCELLED")
	state="idle";paused=false;queue.clear();world.player.navigation_direction=Vector2.ZERO
	world.player.velocity=Vector3.ZERO
	if is_instance_valid(pause_button):pause_button.text="暂停"
	if active:note("已停止，保留当前位置。")

func begin_selected()->void:
	if chooser.item_count==0:return
	begin_goal(str(chooser.get_item_metadata(chooser.selected)),task_kind.selected==1)

func begin_goal(id:String,explore:bool=false)->bool:
	if not active or not registry.goals.has(id):return false
	cancel();visited.clear();trajectory.clear();distance=0;replans=0;selected=id;queue=[id]
	registry.refresh_obstacles()
	if explore:
		var nearby:Array=[]
		for g:Dictionary in registry.goals.values():
			if g.id!=id:nearby.append([g.position.distance_to(registry.goals[id].position),str(g.id)])
		nearby.sort_custom(func(a,b):return a[0]<b[0])
		for pair:Array in nearby.slice(0,2):queue.append(pair[1])
	last_position=world.player.global_position;start_next();return true

func observe()->Dictionary:
	var visible:Array=[]
	if registry!=null:
		for g:Dictionary in registry.goals.values():
			var d:float=world.player.global_position.distance_to(g.position)
			if d<25 and registry.visible(world.player.global_position,g.position):visible.append({"id":g.id,"name":g.name,"distance":snappedf(d,.1)})
	var p:Vector3=world.player.global_position
	return {"position":[p.x,p.y,p.z],"nearby_visible":visible,"visited":visited.duplicate(),"state":state,"target":selected,"legal_actions":legal_actions()}

func legal_actions()->Array:
	if not active:return []
	if state=="walking":return ["pause","cancel","change_goal"]
	if state=="observing":return ["observe","pause","cancel","change_goal"]
	return ["navigate_to"]

func get_available_actions()->Array:
	var actions:Array=[]
	if not active:return actions
	if state in ["idle","complete","failed"]:
		for id:String in registry.goals:actions.append({"type":"navigate_to","target":id})
	if state=="observing":actions.append({"type":"observe","target":selected})
	return actions

func step(action:Dictionary)->Dictionary:
	# Invalid/remote interactions cannot update success flags. Accepted movement is pending.
	if action not in get_available_actions():return {"accepted":false,"reason":"ILLEGAL_ACTION"}
	if action.type=="observe":
		if world.player.global_position.distance_to(registry.goals[selected].position)>.9:return {"accepted":false,"reason":"NOT_AT_TARGET"}
		visited.append(selected);record(action,true,"OBSERVED")
		return {"accepted":true,"done":true}
	selected=action.target;route=registry.plan(world.player.global_position,selected)
	if route.is_empty():fail("NO_PATH","当前没有可行连接，已保留目标和现场位置。");return {"accepted":false,"reason":"NO_PATH"}
	leg=0;best=INF;stalled=0;elapsed=0;state="walking"
	record(action,true,"STARTED")
	note("前往 "+registry.goals[selected].name+" · 已规划 %d 个路点"%route.size())
	return {"accepted":true,"done":false}

func record(action:Dictionary,valid:bool,reason:String="")->void:
	var item:Dictionary={"action":action,"valid":valid,"reason":reason,"observation":observe(),"distance_walked":distance,"time_ms":Time.get_ticks_msec()}
	trajectory.append(item);EventBus.emit_event("CAMPUS_AGENT_ACTION","agent",{"action":action,"valid":valid,"reason":reason})
	var dir:="user://agent-runs";DirAccess.make_dir_recursive_absolute(dir)
	FileAccess.open(dir+"/latest.json",FileAccess.WRITE).store_string(JSON.stringify({"policy":"local_rule","trajectory":trajectory,"rejected_edges":registry.rejected},"\t"))

func start_next()->void:
	if queue.is_empty():state="complete";note("目标完成 · 已到达并观察 %d 处"%visited.size());return
	selected=queue[0];queue.remove_at(0)
	state="idle";step({"type":"navigate_to","target":selected})

func fail(code:String,detail:String)->void:
	state="failed";world.player.navigation_direction=Vector2.ZERO;world.player.velocity=Vector3.ZERO
	record({"type":"navigate_to","target":selected},false,code);note(detail+" 可换目标或从当前位置重试。")

func toggle_pause()->void:
	if state not in ["walking","observing"]:return
	paused=not paused;world.player.navigation_direction=Vector2.ZERO;world.player.velocity=Vector3.ZERO
	pause_button.text="继续" if paused else "暂停";note("已暂停" if paused else "继续当前目标")

func _physics_process(delta:float)->void:
	if not active:return
	var p:Vector3=world.player.global_position
	distance+=p.distance_to(last_position);last_position=p
	if paused:return
	if state=="walking":
		var point:Vector3=registry.graph.get_point_position(route[leg]);var diff:=point-p
		if Vector2(diff.x,diff.z).length()<.42 and absf(diff.y)<.7:
			leg+=1;best=INF;stalled=0;elapsed=0
			if leg>=route.size():
				world.player.navigation_direction=Vector2.ZERO;state="observing";elapsed=0
				record({"type":"navigate_to","target":selected},true,"ARRIVED");note("已到达，观察附近空间……")
			return
		world.player.navigation_direction=Vector2(diff.x,diff.z).normalized()
		elapsed+=delta
		if diff.length()<best-.04:best=diff.length();stalled=0
		else:stalled+=delta
		if stalled>2.5 or elapsed>25:
			world.player.navigation_direction=Vector2.ZERO
			registry.reject(route[maxi(0,leg-1)],route[leg],"physical_stall")
			record({"type":"navigate_to","target":selected},false,"BLOCKED_REPLAN")
			replans+=1
			if replans>8:fail("BLOCKED","连续受阻，已停止。");return
			route=registry.plan(p,selected)
			if route.is_empty():fail("NO_PATH_AFTER_BLOCK","原路线受阻，未找到可行绕行。");return
			leg=0;best=INF;stalled=0;elapsed=0;note("发现障碍，重新规划路线（%d）"%replans)
	elif state=="observing":
		elapsed+=delta;camera_yaw+=delta*.8
		if elapsed>=2.5:
			var result:=step({"type":"observe","target":selected})
			if result.accepted:start_next()
			else:fail("TARGET_DRIFT","角色已离开目标范围，观察未完成。")

func _process(delta:float)->void:
	if active:update_camera(delta)

func update_camera(delta:float)->void:
	var p:Vector3=world.player.global_position;var anchor:=p+Vector3.UP*1.5
	if state=="walking" and not world.player.navigation_direction.is_zero_approx():
		camera_yaw=lerp_angle(camera_yaw,atan2(-world.player.navigation_direction.x,-world.player.navigation_direction.y),minf(1,delta*3))
	var desired:Vector3=world.player.safe_camera_point(anchor,p+Vector3(0,2.6,5.2).rotated(Vector3.UP,camera_yaw))
	camera.global_position=world.player.safe_camera_point(anchor,camera.global_position.lerp(desired,1-exp(-6*delta))) if delta<1 else desired
	if camera.global_position.distance_to(anchor)>.05:camera.look_at(anchor)
	world.player.model.visible=camera.global_position.distance_to(anchor)>1.0
	if state=="walking":status_label.text="前往 %s\n路点 %d / %d · 已走 %.0f m%s"%[registry.goals[selected].name,leg+1,route.size(),distance," · 暂停" if paused else ""]

func note(text:String)->void:
	messages.append(text)
	if messages.size()>4:messages.remove_at(0)
	log_label.text="\n".join(messages);status_label.text=text;changed.emit()
