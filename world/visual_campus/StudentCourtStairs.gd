extends RefCounted
## V157: rectified third-floor stair projections; heights remain fitted, photos011/013 constrain landings.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Core=preload("res://world/visual_campus/StudentFrontCore.gd")
const Finish=preload("res://world/visual_campus/StudentCourtFinish.gd")
static func flights()->Array:
	var out:Array=[]
	for row in [[225,312,459,562,4.4,8.8,0.],[425,558,404,458,4.4,8.8,1.15],[605,710,249,302,8.8,12.4,.95]]:
		var a:=P.third_to_first(row[0],(row[2]+row[3])/2.);var b:=P.third_to_first(row[1],(row[2]+row[3])/2.)
		var c:=P.third_to_first((row[0]+row[1])/2.,row[2]);var d:=P.third_to_first((row[0]+row[1])/2.,row[3])
		out.append({"u0":a.x,"u1":b.x,"v0":c.y,"v1":d.y,"low":row[4],"high":row[5],"landing":row[6]})
	return out
static func panel(n:Node3D,a:Vector3,b:Vector3)->void:
	Core.guard(n,a,b)
	# Opaque side panels from historic photographs, over upright collision guards.
	for side in [-1,1]:
		var offset:=Vector3(side*.045,0,0)
		var face:=K.quad(a+offset,b+offset,b+offset+Vector3.UP*1.03,a+offset+Vector3.UP*1.03) if side>0 else K.quad(b+offset,a+offset,a+offset+Vector3.UP*1.03,b+offset+Vector3.UP*1.03)
		K.surface(n,face,"414a46",11,false)
static func build(parent:Node3D,builder)->void:
	var n:=K.holder(parent,"PlanRegisteredCourtStairsV157")
	# V233:029 has a distinct1F front flight;030 west hall landing is3F.
	# Run continuation past the plan cut line and metric heights remain fitted.
	var fa:=P.point(167,269,.09);var fb:=P.point(303,269,4.415)
	builder.stairs(n,fa,fb,54/P.PIXELS_PER_METRE,28)
	Finish.nosings(n,fa,fb,54/P.PIXELS_PER_METRE,28)
	for side in [-1,1]:panel(n,fa+Vector3(side*(27/P.PIXELS_PER_METRE+.08),0,0),fb+Vector3(side*(27/P.PIXELS_PER_METRE+.08),0,0))
	Core.deck(n,155,242,167,296,.09);Core.deck(n,303,242,325,296,4.415)
	Finish.landing(n,155,242,167,296,.09);Finish.landing(n,303,242,325,296,4.415)
	for s in flights():
		var v:float=(s.v0+s.v1)/2;var width:float=(s.v1-s.v0)/P.PIXELS_PER_METRE
		var a:=P.point(s.u0,v,s.low+.015);var b:=P.point(s.u1,v,s.high+.015)
		var points:Array[Vector3]=[a]
		if s.landing>0:
			var half:float=(s.low+s.high)/2;var mid:float=(s.u0+s.u1)/2;var inset:float=s.landing*P.PIXELS_PER_METRE/2
			points.append(P.point(mid-inset,v,half));points.append(P.point(mid+inset,v,half))
			Core.deck(n,mid-inset,s.v0,mid+inset,s.v1,half)
			Finish.landing(n,mid-inset,s.v0,mid+inset,s.v1,half)
		points.append(b)
		for i in range(points.size()-1):
			if absf(points[i].y-points[i+1].y)>.1:
				builder.stairs(n,points[i],points[i+1],width,14 if s.landing>0 else 28)
				Finish.nosings(n,points[i],points[i+1],width,14 if s.landing>0 else 28)
		var offsets:Array=[-width/2-.08,width/2+.08]
		if s.landing>0:offsets.append(0.)
		for offset in offsets:
			for i in range(points.size()-1):panel(n,points[i]+Vector3(offset,0,0),points[i+1]+Vector3(offset,0,0))
		Core.deck(n,s.u1,s.v0,s.u1+20,s.v1,s.high+.015)
		Core.deck(n,s.u0-12,s.v0,s.u0,s.v1,s.low+.015)
		Finish.landing(n,s.u1,s.v0,s.u1+20,s.v1,s.high+.015)
		Finish.landing(n,s.u0-12,s.v0,s.u0,s.v1,s.low+.015)
		if s.landing>0:Finish.drain(n,P.point(s.u1+5,v,s.high+.015),width-.12)
	K.finish(n)
	Finish.replace_stair_material(n)
