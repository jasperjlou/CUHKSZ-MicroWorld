extends RefCounted
## Public interiors use the same registered frames as their actual model and player routes.
const T=preload("res://world/visual_campus/LibraryTraining209.gd")
const S=preload("res://world/visual_campus/LibrarySecondServices.gd")
const M=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const E=preload("res://world/visual_campus/LibraryEntryLevels.gd")
static func lib(q:Vector3)->Vector3:return Vector3(78-q.z,2.24+q.y,-290+q.x)
static func room(x:float,z:float,y:float=0)->Vector3:return lib(T.local_point(x,y,z))
static func seating(x:float,z:float,y:float=0)->Vector3:return room(z,T.size().y-x,y)
static func svc(x:float,z:float,y:float=0)->Vector3:return lib(S.point(x,y,z))
static func plan(u:float,v:float,y:float=4.4)->Vector3:return lib(M.point2(u,v,y))
static func stair(x:float,z:float)->Vector3:return lib(E.horizontal(Vector3(x,clampf(z/E.RUN,0,1)*4.4,z)))
static func entry(id:String,title:String,detail:String,route:Array,eye:Vector3,look:Vector3,outro:Vector3)->Dictionary:
	return {"id":id,"title":title,"detail":detail,"route":route,"eye":eye,"eye_end":eye+Vector3(.08,.03,.06),"look":look,"offset":Vector3(0,1.8,0),"heading_camera":true,"outro_look":outro,"source_space":"registered library interior"}
static func build()->Array[Dictionary]:
	var c:Array[Dictionary]=[]
	var d:=T.size();var door:float=(435.-326.)/137.*d.x;var w:float=d.y;var rear:float=d.x-.75
	c.append(entry("library-training209","图书馆 · 209 培训室","穿过门廊，沿座席通道观察橙绿墙板、双幕布与条形灯",[
		room(door,d.y+1.4),room(door,d.y+.30),room(door,d.y-.65),seating(.70,rear),seating(w/2,rear),seating(w/2,1.40),seating(.70,1.40),seating(.70,rear),seating(w/2,rear),seating(w-.70,rear),seating(w-.70,1.40),seating(w/2,1.40),seating(w/2,rear),seating(.70,rear),room(door,d.y-.65),room(door,d.y+.30),room(door,d.y+1.4)],
		seating(w-.75,rear,1.75),seating(w*.40,2.5,1.3),room(door,d.y-2.4,2.2)))
	c.append(entry("library-services","图书馆 · 服务大厅","从公共房间前廊走向预约取书柜与咨询台，细看石铺和墙脚收口",[
		plan(500,445),plan(575,445),plan(645,445),plan(715,445),plan(760,470),svc(-3,2.7),svc(-3,1.5),svc(-2,1.5),svc(-1.1,1.5),svc(-1.1,-.25),svc(-1.1,1.5),svc(.7,1.5),svc(2.1,1.5),svc(3.7,1.5),svc(4.5,2.7),svc(0,2.7),svc(-3,2.7)],
		svc(3.8,5,1.65),svc(.8,.1,1.4),svc(.5,-.1,1.4)))
	c.append(entry("library-public-stairs","图书馆 · 石阶与格栅顶","沿两侧公共阶梯上行再返回大厅，观察中央坐席、开口与顶面边缘",[
		stair(0,-1.2),stair(0,1),stair(0,E.RUN*.5),stair(0,E.RUN-.3),stair(0,E.RUN+.85),stair(3.3,E.RUN+.85),stair(6.6,E.RUN+.85),stair(6.6,E.RUN-.3),stair(6.6,E.RUN*.5),stair(6.6,1),stair(6.6,-1.2),stair(3.3,-1.2),stair(0,-1.2)],
		stair(3.3,-4)+Vector3.UP*1.8,stair(3.3,E.RUN*.65)+Vector3.UP*.7,stair(3.3,E.RUN*.4)+Vector3.UP*.5))
	return c
