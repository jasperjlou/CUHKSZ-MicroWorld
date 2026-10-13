extends RefCounted
## Authored, resumable presentation. Coordinates are local to the same live building nodes.
## These are chapter cuts, never claimed to be one uninterrupted campus navigation run.
static func chapter(world: Node3D, id: String, title: String, detail: String, building: String,
		points: Array, eye: Vector3, eye_end: Vector3, look: Vector3, offset: Vector3) -> Dictionary:
	var transform := Transform3D.IDENTITY
	if not building.is_empty(): transform = world.builder.buildings[building].global_transform
	var route: Array[Vector3] = []
	for p: Vector3 in points: route.append(transform * p)
	return {"id":id, "title":title, "detail":detail, "route":route,
		"eye":transform*eye, "eye_end":transform*eye_end, "look":transform*look,
		"offset":transform.basis*offset, "source_space":building if not building.is_empty() else "world"}

static func build(world: Node3D) -> Array[Dictionary]:
	var c: Array[Dictionary] = []
	c.append(chapter(world,"gate", "东门 · 进入校园", "石材铺地、台阶与门楼之间的缓坡", "", [
		Vector3(-18,0,-39.5),Vector3(-17.3,0,-39.5),Vector3(-17.3,1.12,-46),Vector3(-17.3,2.24,-55.5),Vector3(-35,2.24,-57),Vector3(-35,2.24,-98)],
		Vector3(0,3,-18),Vector3(2,3.3,-20),Vector3(0,4,-48),Vector3(4,3,5)))
	c.append(chapter(world,"icc", "会议中心 · 双层入口", "从主轴走上入口平台，观察门厅和侧向连接", "", [
		Vector3(29,2.24,-58),Vector3(24,2.24,-64),Vector3(21.5,2.24,-98),Vector3(21.5,2.24,-105.2),
		world.builder.buildings.conference.to_global(Vector3(-3.2,4.8,47.75)),
		world.builder.buildings.conference.to_global(Vector3(-1.75,4.8,42)),
		world.builder.buildings.conference.to_global(Vector3(-1.75,5,37)),
		world.builder.buildings.conference.to_global(Vector3(-1.75,5,28))],
		world.builder.buildings.conference.to_global(Vector3(-3.2,5.7,80)),world.builder.buildings.conference.to_global(Vector3(0,6.2,75)),world.builder.buildings.conference.to_global(Vector3(-1.75,10,35)),Vector3(-4,3.2,5)))
	c.append(chapter(world,"teaching-b", "教学 B · 廊与台阶", "门厅、院落、上层低翼与开敞楼梯", "teaching_b", [
		Vector3(-13,0,42),Vector3(-13,.125,33),Vector3(-13,.125,25),Vector3(-13,.125,3),Vector3(-19.44,.125,3),Vector3(-19.44,.125,7.04),Vector3(-19.44,4.925,24.04),Vector3(-19.44,4.925,27.04),Vector3(-25,4.925,27.04),Vector3(-25,4.75,20)],
		Vector3(-13,2,42),Vector3(-12,2.4,40),Vector3(-10,2,31),Vector3(-3,2.2,4)))
	c.append(chapter(world,"library-pool", "大学图书馆 · 池岸与格栅", "沿池边走入有顶连廊，靠近立面与柱脚", "", [
		Vector3(14,2.24,-334),Vector3(34,2.24,-334),Vector3(54,2.24,-334),Vector3(60,2.24,-334),Vector3(60,2.24,-330),
		# Swept body clearance follows the gap between rising gallery and grey stair.
		lib(-35,0,16),Vector3(60,2.24,-308.5),lib(-12,0,20)],
		Vector3(43,4.2,-339),Vector3(46,4.2,-339),lib(-27,2.3,20),Vector3(-4,2.8,4)))
	# Use the geometry's smoothed centreline so presentation follows the real inclined deck.
	var gallery_route:Array=[lib(-39,0,18.9)]
	for point:Vector3 in preload("res://world/visual_campus/LibraryOuterGallery.gd").route():
		gallery_route.append(lib(point.x,point.y,point.z))
	var pavilion=preload("res://world/visual_campus/LibraryEntryPavilion.gd")
	for point:Vector3 in [pavilion.dp(0,1),pavilion.dp(0,-2)]:
		gallery_route.append(lib(point.x,point.y,point.z))
	c.append(chapter(world,"library-gallery", "图书馆 · 沿外廊缓步上行", "从灰石地面沿缓坡上行，穿过竖向格栅与圆柱之间，抵达二层入口", "", gallery_route,
		lib(-38,1.8,18.9),lib(-37.4,1.8,18.9),lib(-25,2.5,19.3),Vector3(0,1.8,0)))
	c[-1]["outro_look"]=lib(4,6.1,26)
	var grey_route:Array=[]
	for p:Vector3 in preload("res://world/visual_campus/LibraryGreyEntryStair.gd").points():grey_route.append(lib(p.x,p.y,p.z))
	var grey_last:Vector3=preload("res://world/visual_campus/LibraryGreyEntryStair.gd").points().back()
	grey_route.append_array([lib(-38,4.4,grey_last.z),lib(-38,4.4,21.5),lib(-41,4.4,22),Vector3(56,6.64,-350)])
	c.append(chapter(world,"library-grey-stair","图书馆 · 灰栏梯与连廊","沿两段短梯上行，经过栏杆与平台，转向学生中心连廊","",grey_route,
		grey_route[0]+Vector3(0,1.8,1.5),grey_route[0]+Vector3(0,1.8,1.1),grey_route[2]+Vector3.UP,Vector3(0,1.8,0)))
	c[-1]["heading_camera"]=true;c[-1]["outro_look"]=Vector3(56,8.2,-373)
	c.append(chapter(world,"library-lower", "图书馆 · 主梯下面", "从下层入口进入馆内，看主入口楼梯下方的公共空间", "", [
		lib(-12,0,20),lib(-12,0,18),lib(-12,0,13),lib(-12,0,10),lib(-12,0,4),lib(0,0,8),lib(6,0,10),lib(8,0,12)],
		lib(-13,1.8,17),lib(-12.8,1.8,16.5),lib(-12,1.6,9),Vector3(-2,1.9,-2)))
	c.append(chapter(world,"library-study", "图书馆 · 学习空间", "玻璃小组室、圆角转弯与窗边过道", "", [
		lib(-18,0,10),lib(-18,0,3.1),lib(-28.13,0,3.1),lib(-28.13,0,1.5),lib(-28.13,0,3.1),lib(-35,0,3.1),lib(-35,0,-3)],
		lib(-23,1.8,3.1),lib(-23.5,1.8,3.1),lib(-28,1.5,1.5),Vector3(-2,1.9,1)))
	c[-1]["leg_camera"]={3:{"eye":lib(-28.13,1.7,1.4),"look":lib(-30,1.1,0)},4:{"eye":lib(-28.13,1.7,1.4),"look":lib(-30,1.1,0)}}
	c.append(chapter(world,"library-seating", "图书馆 · 木阶与下层圆柱", "走近低坐席与金属吊顶，绕过圆柱，再沿旁侧木梯上楼", "", [
		lower_stair(5.8,0,-3.4),lower_stair(8.2,0,-3.4),lower_stair(8.2,0,-.9),lower_stair(5.8,0,-.9),lower_stair(5.8,0,-3.4),lower_stair(3,0,-3.4),lower_stair(0,0,-1),lower_stair(0,4.4*6/10.5,6),lower_stair(0,4.4,11.1)],
		lower_stair(10.2,1.75,-5),lower_stair(9.9,1.75,-4.8),lower_stair(5,2.1,2.7),Vector3(0,1.75,0)))
	c[-1]["heading_camera"]=true
	c[-1]["outro_look"]=lower_stair(0,6.1,15)
	c.append(chapter(world,"lower-road", "教学组团 · 上桥下路", "沿下层道路穿过桥底，观察两层交通的高差", "", [
		Vector3(-135.12,-2.325,-258.5),Vector3(-135.12,-2.325,-272.5),Vector3(-135.12,-2.325,-286.5),Vector3(-135.12,-2.325,-310)],
		Vector3(-135.12,-.75,-257),Vector3(-135.12,-.65,-259),Vector3(-135.12,-.75,-289),Vector3(0,1.8,4)))
	c.append(chapter(world,"student", "学生中心 · 下沉街巷", "沿店铺廊道行走，再上坡连接逸夫楼前场", "", [
		Vector3(29,-1.76,-446),Vector3(28,-1.76,-453),Vector3(24.45,-1.76,-453),Vector3(28,-1.76,-453),Vector3(28,-1.76,-457),Vector3(24.45,-1.76,-457),Vector3(28,-1.76,-457),Vector3(29,-1.76,-467),Vector3(29,.24,-480),Vector3(29,2.24,-494)],
		Vector3(29,-.03,-447),Vector3(29,.1,-449),Vector3(25,.03,-461),Vector3(2,1.9,4)))
	c.append(chapter(world,"zhang", "张岭彬楼 · 层间连接", "从侧翼步入折返楼梯，抵达下层公共空间", "zhang_lingbin", [
		Vector3(-24.4,.125,12),Vector3(-24.4,.125,-20),Vector3(-21.5,.125,-20),Vector3(-21.5,.125,-26.6),Vector3(-19.15,.125,-26.6),Vector3(-19.15,-2.3375,-39.1),Vector3(-21.65,-2.3375,-39.1),Vector3(-21.65,-4.8,-26.6),Vector3(-20.4,-4.8,-20)],
		Vector3(-20.4,1.9,-24),Vector3(-20.4,1.9,-24.5),Vector3(-19.15,-2.1,-33),Vector3(-1.1,1.7,2)))
	# V218 starts at the corrected2F exterior porch, then uses the refitted rear street.
	# Terrain-sampled points stay tied to the live model rather than obsolete flat-road heights.
	c.append(chapter(world,"library-rear-shaw", "图书馆后侧 · 沿车道到逸夫", "沥青后场、学生中心后门与逸夫高位入口", "", [
		rear(0,4.4,-2.4),rear(0,3.92,-5.6),rear(0,3.92,-7),site(world,120,-322),site(world,131,-322),site(world,132,-330),site(world,127,-350),site(world,120,-365),
		site(world,116,-372),site(world,116,-399.238),site(world,110.5,-399.238),Vector3(102,2.315,-399.238),site(world,110.5,-399.238),
		site(world,110.5,-428),site(world,116,-428),site(world,120,-475),site(world,122,-510),
		site(world,124.5,-533.2),shaw(6.8,4.5,-36),shaw(6.8,4.95,-28),shaw(6.8,4.95,-17)],
		rear(0,6.1,-7),rear(.3,6.1,-6.7),rear(0,6,-.3),Vector3(0,1.8,0)))
	c[-1]["heading_camera"]=true;c[-1]["outro_look"]=shaw(-15,6.55,-5)
	c.append(chapter(world,"shaw-podium", "逸夫东座 · 门廊与公共台地", "从前场穿过黄色门廊，沿折返梯到开放平台", "", [
		shaw(-20,0,36),shaw(-20,.45,28),shaw(-20,.45,20),shaw(-10,.45,20),shaw(-10,.45,23.3),shaw(-6.1,.45,23.3),
		shaw(-6.1,2.7,15.4),shaw(-3.2,2.7,15.4),shaw(-3.2,4.95,23.3),shaw(0,4.95,23.3),
		shaw(0,4.95,14),shaw(0,8.85,4),shaw(10,8.85,4),shaw(10,8.85,-12)],
		shaw(-23,2.3,41),shaw(-22,2.6,39),shaw(-15,5,19),Vector3(-2.5,2.1,1.5)))
	# On arrival, turn back across the open court instead of ending nose-to-wall.
	c[-1]["outro_look"]=shaw(-10,13,3)
	var west:Node3D=world.builder.buildings.shaw_west.get_node("WestPlanFrameV143")
	var west_route:Array=[]
	for p:Vector3 in [Vector3(9,0,36),Vector3(9,.05,32),Vector3(9,.05,28.7),Vector3(3.6,.05,28.7),Vector3(-2.9,2.225,28.7),Vector3(-2.9,2.225,26),Vector3(4.8,4.4,26),Vector3(7,4.4,26),Vector3(7,4.4,28.7),Vector3(3.6,4.4,28.7),Vector3(-2.9,6.6,28.7),Vector3(-2.9,6.6,26),Vector3(4.8,8.8,26),Vector3(9,8.8,26),Vector3(9,8.8,10),Vector3(7,8.8,5),Vector3(5,8.8,-5),Vector3(-18,8.8,-5),Vector3(-18,8.8,1),Vector3(-18,8.8,-5),Vector3(2.8,8.8,-5),Vector3(2.8,8.8,-9),Vector3(2.8,8.8,-20),Vector3(2.8,8.8,-9),Vector3(2.8,8.8,-5),Vector3(5,8.8,-5),Vector3(8,8.8,-3),Vector3(8,12.1,-13),Vector3(0,12.1,-13),Vector3(0,12.1,-25),Vector3(8,12.1,-25)]:west_route.append(west.to_global(p))
	west_route.append(Vector3(191,14.34,-665))
	c.append(chapter(world,"shaw-west", "逸夫西座 · 折返梯与山桥", "从玻璃雨棚走上公共层，穿过采光井旁的廊道，再到屋顶山桥", "", west_route,
		west.to_global(Vector3(-10,5,37)),west.to_global(Vector3(-8,5.4,35)),west.to_global(Vector3(2,7,26)),Vector3(-2,2.1,2)))
	c[-1]["outro_look"]=west.to_global(Vector3(-4,18,-12))
	c.append(chapter(world,"zhixin", "知新楼 · 旧图书馆前庭", "砖铺人行道、内院与图书馆入口的连续关系", "", [
		Vector3(-8.1,2.24,-700),Vector3(-8.1,2.24,-733),Vector3(-20,2.24,-733),Vector3(-44,2.24,-733),Vector3(-49.3,2.24,-733),Vector3(-44,2.24,-733),Vector3(-36.5,2.24,-733),Vector3(-36.5,2.24,-700)],
		Vector3(1,4.3,-733),Vector3(-1,4.6,-731),Vector3(-38,10,-733),Vector3(4,3.2,3)))
	c.append(chapter(world,"old-gate","旧南门 · 街道与道远前场","从外侧人行道进入旧门，经过石柱与岗亭，沿石铺走向道远楼","",[
		Vector3(-191.7,2.31,-805),Vector3(-191.7,2.275,-790),Vector3(-181,2.275,-790),Vector3(-168,2.42,-790),Vector3(-168,2.34,-782.8),Vector3(-162.5,2.24,-782.8),Vector3(-162.5,2.24,-755)],
		Vector3(-203,4.1,-790),Vector3(-201,4.3,-789),Vector3(-162,10,-794),Vector3(0,1.8,0)))
	c[-1]["heading_camera"]=true;c[-1]["outro_look"]=Vector3(-130,11,-733)
	var research_walk:Array=[];var research_frame:Transform3D=world.builder.buildings.research.global_transform
	for p:Vector2 in [Vector2(-46,-43),Vector2(-52,-43),Vector2(-56,-39),Vector2(-56,15),Vector2(-56,45),Vector2(-53,55),Vector2(-45,63),Vector2(-31,69),Vector2(-12,70)]:
		var q:Vector3=research_frame*Vector3(p.x,0,p.y);q.y=world.builder.height(q.x,q.z)+.065;research_walk.append(q)
	c.append(chapter(world,"research-perimeter","科研区 · 后路与林缘","沿建筑后侧步道转过林缘，观察车道、台地和入口的接续","",research_walk,
		research_frame*Vector3(-59,1.9,-49),research_frame*Vector3(-58.5,2,-48),research_frame*Vector3(-56,2,-20),Vector3(0,1.8,0)))
	c[-1]["heading_camera"]=true;c[-1]["outro_look"]=research_frame*Vector3(0,12,42)
	c.append(chapter(world,"research", "科研区 · 双翼与台地", "沿两级入口台阶走向曲面遮阳、空中庭院和高低双翼", "research", [
		Vector3(0,0,65),Vector3(0,5.5,49),Vector3(0,11.5,37),Vector3(0,11.5,24),Vector3(0,11.5,3)],
		Vector3(76,33,99),Vector3(72,34,97),Vector3(6,26,12),Vector3(-4,3.2,5)))
	var sports_walk:Array=[]
	for p:Vector2 in [Vector2(-131,-1087),Vector2(-127,-1087),Vector2(-119,-1095),Vector2(-109,-1102),Vector2(-106.5,-1108),Vector2(-106.5,-1129.8)]:sports_walk.append(site(world,p.x,p.y)+Vector3.UP*.10)
	c.append(chapter(world,"sports-forecourt","体育区 · 转角前场与过街","从石铺前场沿路缘浅坡过街，回看场馆与欢迎标识","",sports_walk,
		Vector3(-131,.2,-1087),Vector3(-130.5,.3,-1087.5),Vector3(-109,-.7,-1104),Vector3(0,1.8,0)))
	c[-1]["heading_camera"]=true;c[-1]["outro_look"]=Vector3(-98,2,-1092)
	c.append(chapter(world,"sports", "体育馆 · 馆内与看台层", "从侧门穿过馆内，再沿楼梯走上二层", "", [
		gym(31,0,19),gym(31,0,7),gym(35.2,0,4),gym(35.2,0,0),gym(39,0,0),gym(45,0,0),gym(59,0,0),gym(59,0,14.5),gym(48,0,14.5),gym(48,2.4,2.5),gym(54,2.4,2.5),gym(54,4.8,14.5),gym(43,4.8,14.5),gym(43,4.8,11.2),gym(29.2,4.8,11.2)],
		gym(42,6.45,11),gym(40,6.6,11),gym(7,6.5,12),Vector3(-2,2.2,3)))
	c.append(chapter(world,"sports-underpass", "场馆之间 · 走向田径场", "穿过架空层，观察彩色镂空屏、廊下结构和场边铺地", "sports_complex", [
		Vector3(10,0,19),Vector3(10,0,-3),Vector3(10,0,-25),Vector3(10,0,-39)],
		Vector3(38,4,-52),Vector3(36,4.2,-51),Vector3(8,3,-4),Vector3(4,2.8,5)))
	for entry:Dictionary in c:
		if entry.id in ["library-pool","library-gallery","library-study","zhang","shaw-west"]:entry["heading_camera"]=true
	return c

static func lib(x: float,y: float,z: float) -> Vector3: return Vector3(78-z,2.24+y,-290+x)
static func rear(x:float,y:float,z:float)->Vector3:
	var p:=preload("res://world/visual_campus/LibraryLowerRearEnvelope.gd").door_point(Vector3(x,y,z))
	return lib(p.x,p.y,p.z)
static func lower_stair(x:float,y:float,z:float)->Vector3:
	var p:=preload("res://world/visual_campus/LibraryGroundStair.gd").point(Vector3(x,y,z))
	return lib(p.x,p.y,p.z)
static func gym(x: float,y: float,z: float) -> Vector3: return Vector3(-10+x,2.24+y,-947+z)

static func site(world: Node3D,x:float,z:float)->Vector3: return Vector3(x,world.builder.height(x,z),z)
static func shaw(x:float,y:float,z:float)->Vector3: return Vector3(84.3-z,2.24+y,-540+x)
