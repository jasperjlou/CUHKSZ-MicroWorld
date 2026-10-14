extends RefCounted
## V225: chapter cuts to the newly modeled public interiors; routes use real body physics.
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const R=preload("res://world/visual_campus/StudentThirdRooms.gd")
static func p(u:float,v:float,y:float)->Vector3:return P.world(u,v,y)
static func r(u:float,v:float,y:float=8.8)->Vector3:return R.world(u,v,y)
static func entry(id:String,title:String,detail:String,route:Array,eye:Vector3,look:Vector3,outro:Vector3)->Dictionary:
	return {"id":id,"title":title,"detail":detail,"route":route,"eye":eye,"eye_end":eye+Vector3(.12,.04,.08),"look":look,"offset":Vector3(0,1.8,0),"heading_camera":true,"outro_look":outro,"source_space":"registered student plan"}
static func build()->Array[Dictionary]:
	var c:Array[Dictionary]=[]
	c.append(entry("student-serenity","学生中心 · 首层餐厅","从门廊走进灰砖餐厅，经过黑色吊灯，绕看弧形吧台与柱边餐具柜",[
		p(180,438,.075),p(240,438,.075),p(270,438,.075),p(270,365,.075),p(350,365,.075),p(400,365,.075),p(650,365,.075),p(650,445,.075),p(750,447.5,.075),p(650,445,.075),
		p(650,480,.075),p(580,480,.075),p(530,480,.075),p(530,400,.075),p(565,385,.075),p(625,385,.075),p(650,385,.075),p(650,365,.075)],
		p(635,425,1.8),p(565,430,1.7),p(565,430,1.8)))
	c.append(entry("student-lotus","学生中心 · 二层餐厅与庭院","浅木餐桌、黄色卡座与条形吊顶，沿院落梯走向上层",[
		p(400,300,4.4),p(450,300,4.4),p(480,300,4.4),p(480,315,4.4),p(525,315,4.4),p(525,215,4.4),p(650,215,4.4),p(650,306,4.4),p(740,306,4.4),p(650,306,4.4),p(650,400,4.4),p(580,400,4.4),p(580,480,4.4),p(450,480,4.4),p(450,500,4.4),p(400,500,4.4),p(400,440,4.4),p(580,440,8.8),p(650,440,8.8)],
		p(450,315,6.1),p(580,330,6.6),p(690,275,12.4)))
	c.append(entry("student-third-rooms","学生中心 · 三层公共隔间","从共享前厅进入小隔间，回看窗面与柱网",[
		r(469,220),r(469,187),r(469,133),r(442,133),r(442,115),r(442,78),r(442,115),r(484,115),r(484,78),r(484,115),r(526,115),r(526,78),r(526,115),r(564,133),r(564,220)],
		r(687,180,10.5),r(450,120,10.5),r(450,130,11.0)))
	c.append(entry("student-hall301","学生中心 · 301多功能厅","木地板、双层空间与玻璃上廊；抬头观察格栅吊顶",[
		r(720,485),r(749,485),r(749,520),r(730,550),r(650,550),r(500,550),r(470,610),r(445,676),r(405,676),r(445,676),r(530,655),r(720,655),r(760,620),r(760,550)],
		r(750,660,10.5),r(450,530,12.0),r(590,580,15.1)))
	c.append(entry("student-front-west301","学生中心 · 前梯、庭院与 301 西门","从首层前梯上到灰砖院落，再登宽梯穿过西门，回望平台与采光顶",[
		p(150,269,.075),p(320,269,4.4),p(350,350,4.4),p(200,350,4.4),p(200,520,4.4),p(215,520,4.4),p(330,520,8.8),r(400,536),r(450,536),r(500,580),r(450,536),r(400,536),p(400,480,8.8),p(450,480,8.8),p(580,480,8.8),p(580,440,8.8),p(400,440,4.4),p(350,350,4.4),p(320,269,4.4),p(150,269,.075)],
		p(180,310,6.1),p(400,420,5.3),p(285,269,3.4)))
	return c
