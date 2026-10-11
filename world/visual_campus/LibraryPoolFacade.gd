extends RefCounted
## Pool-facing edges only. Official mall panorama + anniversary photo with 2023 sign.
## Front curve is edges22..24, NOT the oblique end wall21. Dimensions remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const COLOR="626b6b"

static func openings(length:float,grouped:bool)->Array[Vector2]:
	var out:Array[Vector2]=[]
	if grouped:
		# Short windows cluster through the middle; opaque margins remain at both ends.
		for group in 5:
			var center:float=length*(.18+.16*group)
			for slot in 3:
				var x:float=center+(slot-1)*.63
				out.append(Vector2(x-.225,x+.225))
	else:
		for i in 15:
			var x:float=(i+.5)*length/15
			out.append(Vector2(x-.37,x+.37))
	return out

static func panel(n:Node3D,p:Vector3,width:float,yaw:float,y:float,height:float)->void:
	var basis:=Basis(Vector3.UP,yaw)
	K.box(n,p+basis*Vector3(0,y,-.28),Vector3(width+.006,height,.56),COLOR,true,13,yaw)
	K.box(n,p+basis*Vector3(0,y,-.605),Vector3(width+.006,height,.065),"d4d4c8",false,22,yaw)

static func chain(n:Node3D,boundary:PackedVector2Array,start:int,end:int,grouped:bool)->void:
	var total:float=0
	for i in range(start,end):total+=boundary[i].distance_to(boundary[i+1])
	var windows:=openings(total,grouped);var offset:float=0
	var height:float=1.65 if grouped else 2.28
	for edge in range(start,end):
		var a:=boundary[edge];var b:=boundary[edge+1];var length:=a.distance_to(b)
		var yaw:float=-atan2(b.y-a.y,b.x-a.x)+PI;var basis:=Basis(Vector3.UP,yaw)
		var cuts:Array[float]=[0,length]
		for window in windows:
			for x in [window.x,window.y]:
				if x>offset and x<offset+length:cuts.append(x-offset)
		cuts.sort()
		for k in range(cuts.size()-1):
			var center:float=(cuts[k]+cuts[k+1])/2;var width:float=cuts[k+1]-cuts[k]
			if width<.001:continue
			var q:=a.lerp(b,center/length);var p:=Vector3(q.x,0,q.y);var index:int=-1
			for j in windows.size():
				if offset+center>windows[j].x and offset+center<windows[j].y:index=j;break
			for row in 3:
				var y:float=14.8+row*4
				if index<0:
					panel(n,p,width,yaw,y,4)
					continue
				var above:float=(4-height)/2
				for side in [-1,1]:panel(n,p,width,yaw,y+side*(height/2+above/2),above)
				# Closed, recessed glazing with collision, unlike the previous visual-only slit.
				K.box(n,p+basis*Vector3(0,y,-.52),Vector3(width,height,.08),"465c64",true,5,yaw)
				for side in [-1,1]:
					K.box(n,p+basis*Vector3(side*(width/2-.025),y,-.245),Vector3(.05,height,.53),"65716c",false,11,yaw)
				K.box(n,p+basis*Vector3(0,y-height/2-.025,-.24),Vector3(width+.04,.05,.55),"929990",false,11,yaw)
				if grouped and (index+row)%3==1:
					K.box(n,p+basis*Vector3(width/2-.09,y,-.18),Vector3(.18,height,.38),"b87953",false,11,yaw)
				else:
					for rail_y in [-.28,.26]:K.box(n,p+basis*Vector3(0,y+rail_y,-.465),Vector3(width,.028,.025),"a3aaa0",false,11,yaw)
		# Thin panel joints follow each local wall tangent, avoiding world-axis stripes.
		var count:=maxi(1,int(ceil(length/.95)))
		for j in range(1,count):
			var q:=a.lerp(b,float(j)/count);var center:float=offset+length*j/count;var in_window:bool=false
			for window in windows:
				if center>window.x-.025 and center<window.y+.025:in_window=true;break
			for row in 3:
				var y:float=14.8+row*4;var p:=Vector3(q.x,y,q.y)
				if not in_window:K.box(n,p+basis*Vector3(0,0,.005),Vector3(.008,3.98,.008),"4e5857",false,11,yaw)
		offset+=length

static func build(n:Node3D,boundary:PackedVector2Array)->void:
	chain(n,boundary,22,25,true)
	chain(n,boundary,25,30,false)
