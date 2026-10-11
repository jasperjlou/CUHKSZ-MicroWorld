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
		lib(-35,0,18),lib(-31,0,18),lib(-24,0,18),lib(-17,0,20),lib(-12,0,20)],
		Vector3(-1,33,-226),Vector3(3,29,-236),Vector3(65,8,-290),Vector3(-4,2.8,4)))
	c.append(chapter(world,"library-lower", "图书馆 · 主梯下面", "从下层入口进入馆内，看主入口楼梯下方的公共空间", "", [
		lib(-12,0,20),lib(-12,0,18),lib(-12,0,13),lib(-12,0,10),lib(-12,0,4),lib(0,0,8),lib(6,0,10),lib(8,0,12)],
		lib(-14,1.9,22),lib(-13.5,1.9,21.5),lib(-10,1.7,5),Vector3(-2,1.9,-2)))
	c.append(chapter(world,"library-study", "图书馆 · 学习空间", "玻璃小组室、圆角转弯与窗边过道", "", [
		lib(-18,0,10),lib(-18,0,4.1),lib(-28.13,0,4.1),lib(-28.13,0,1.5),lib(-28.13,0,4.1),lib(-35,0,4.1),lib(-35,0,-3)],
		lib(-19,1.8,4.1),lib(-20,1.8,4.1),lib(-29,1.8,1),Vector3(-2,1.9,1)))
	c.append(chapter(world,"lower-road", "教学组团 · 上桥下路", "沿下层道路穿过桥底，观察两层交通的高差", "", [
		Vector3(-135.12,-2.325,-258.5),Vector3(-135.12,-2.325,-272.5),Vector3(-135.12,-2.325,-286.5),Vector3(-135.12,-2.325,-310)],
		Vector3(-135.12,-.75,-257),Vector3(-135.12,-.65,-259),Vector3(-135.12,-.75,-289),Vector3(0,1.8,4)))
	c.append(chapter(world,"student", "学生中心 · 下沉街巷", "沿店铺廊道行走，再上坡连接逸夫楼前场", "", [
		Vector3(29,-1.76,-446),Vector3(28,-1.76,-453),Vector3(24.45,-1.76,-453),Vector3(28,-1.76,-453),Vector3(28,-1.76,-457),Vector3(24.45,-1.76,-457),Vector3(28,-1.76,-457),Vector3(29,-1.76,-467),Vector3(29,.24,-480),Vector3(29,2.24,-494)],
		Vector3(29,-.03,-447),Vector3(29,.1,-449),Vector3(25,.03,-461),Vector3(2,1.9,4)))
	c.append(chapter(world,"zhang", "张岭彬楼 · 层间连接", "从侧翼步入折返楼梯，抵达下层公共空间", "zhang_lingbin", [
		Vector3(-24.4,.125,12),Vector3(-24.4,.125,-20),Vector3(-21.5,.125,-26.6),Vector3(-19.15,.125,-26.6),Vector3(-19.15,-2.3375,-39.1),Vector3(-21.65,-2.3375,-39.1),Vector3(-21.65,-4.8,-26.6),Vector3(-20.4,-4.8,-20)],
		Vector3(-20.4,1.9,-24),Vector3(-20.4,1.9,-24.5),Vector3(-19.15,-2.1,-33),Vector3(-1.1,1.7,2)))
	# Rear route follows the V74 building-corner detour, then the V51 raised entrance.
	# Terrain-sampled points stay tied to the live model rather than obsolete flat-road heights.
	c.append(chapter(world,"library-rear-shaw", "图书馆后侧 · 沿车道到逸夫", "沥青后场、学生中心后门与逸夫高位入口", "", [
		site(world,120,-322),site(world,131,-322),site(world,137,-322),site(world,127,-350),
		site(world,138,-350),site(world,146,-353),site(world,151,-360),site(world,151,-373),
		site(world,151,-400),site(world,145,-400),Vector3(138,2.24,-400),site(world,145,-400),
		site(world,145,-433),site(world,151,-440),site(world,120,-475),site(world,122,-510),
		site(world,124.5,-533.2),shaw(6.8,4.5,-36),shaw(6.8,4.95,-28),shaw(6.8,4.95,-17)],
		Vector3(135,7,-333),Vector3(134,6.6,-330),Vector3(100,8,-314),Vector3(4,2.8,5)))
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
		Vector3(-8.1,2.24,-700),Vector3(-8.1,2.24,-733),Vector3(-20,2.24,-733),Vector3(-44,2.24,-733),Vector3(-51,2.24,-733),Vector3(-44,2.24,-733),Vector3(-36.5,2.24,-733),Vector3(-36.5,2.24,-700)],
		Vector3(1,4.3,-733),Vector3(-1,4.6,-731),Vector3(-38,10,-733),Vector3(4,3.2,3)))
	c.append(chapter(world,"research", "科研区 · 入口平台", "从主路走近科研楼的入口和长立面", "", [
		Vector3(25,2.24,-845),Vector3(42,7.74,-845),Vector3(56,13.74,-845),Vector3(68,13.74,-845),Vector3(85,13.74,-845),Vector3(100,13.74,-845)],
		Vector3(0,11,-808),Vector3(3,12,-807),Vector3(89,27,-842),Vector3(-4,3.2,5)))
	c.append(chapter(world,"sports", "体育馆 · 馆内与看台层", "从侧门穿过馆内，再沿楼梯走上二层", "", [
		gym(31,0,19),gym(31,0,7),gym(35.2,0,4),gym(35.2,0,0),gym(39,0,0),gym(45,0,0),gym(59,0,0),gym(59,0,14.5),gym(48,0,14.5),gym(48,2.4,2.5),gym(54,2.4,2.5),gym(54,4.8,14.5),gym(43,4.8,14.5),gym(43,4.8,11.2),gym(29.2,4.8,11.2)],
		gym(42,6.45,11),gym(40,6.6,11),gym(7,6.5,12),Vector3(-2,2.2,3)))
	return c

static func lib(x: float,y: float,z: float) -> Vector3: return Vector3(78-z,2.24+y,-290+x)
static func gym(x: float,y: float,z: float) -> Vector3: return Vector3(-10+x,2.24+y,-947+z)

static func site(world: Node3D,x:float,z:float)->Vector3: return Vector3(x,world.builder.height(x,z),z)
static func shaw(x:float,y:float,z:float)->Vector3: return Vector3(84.3-z,2.24+y,-540+x)
