extends RefCounted
## V52: 4F/7F plan cuts remove actual slabs/walls, not painted facade rectangles.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const D:=preload("res://world/visual_campus/ShawEastDetail.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")

static func cut_at(cuts: Array,x: float,z: float,y: float) -> bool:
	for cut: AABB in cuts:
		if x>cut.position.x-.001 and x<cut.end.x+.001 and z>cut.position.z-.001 and z<cut.end.z+.001 and y>cut.position.y+.01 and y<cut.end.y+.01:return true
	return false

static func inside(xs: Array[float],zs: Array[float],cuts: Array,i: int,j: int,y: float) -> bool:
	if i<0 or j<0 or i>=xs.size()-1 or j>=zs.size()-1:return false
	return not cut_at(cuts,(xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2,y)

static func wall(b: Node3D,a: Vector3,c: Vector3,low: float,high: float,side: int,inner: bool,gable: bool=false,door: bool=false) -> void:
	var d:=c-a;var length:=d.length();var n:=K.holder(b,"RecessWall" if inner else "DormElevation",(a+c)/2)
	n.rotation.y=0 if absf(d.x)>absf(d.z) else PI/2
	if inner:
		# Warm recess walls and a ground-level opening connect the sky court to its floor.
		if door and length>3.2:
			var span: float=(length-1.7)/2
			for edge in [-1,1]:K.box(n,Vector3(edge*(.85+span/2),(low+high)/2,0),Vector3(span,high-low,.22),"b3a035",true,21)
			K.box(n,Vector3(0,(low+2.35+high)/2,0),Vector3(1.7,high-low-2.35,.22),"b3a035",true,21)
			for edge in [-1,1]:K.box(n,Vector3(edge*.86,low+1.17,side*.14),Vector3(.07,2.35,.08),"c4c7b9",false,11)
		else:K.box(n,Vector3(0,(low+high)/2,0),Vector3(length,high-low,.22),"b3a035",true,21)
	elif gable:
		K.box(n,Vector3(0,(low+high)/2,0),Vector3(length,high-low,.28),"777d7d",true,22)
		K.box(n,Vector3(-length*.36,low+1.1,side*.17),Vector3(1.1,1.6,.08),"435b62",false,5)
	else:
		D.elevation(n,length,0,[low,high],side,false)
	K.finish(n)

static func boundaries(b: Node3D,xs: Array[float],zs: Array[float],cuts: Array,low: float,high: float,id: String,roof: bool=false) -> void:
	var y: float=(low+high)/2
	# Merge adjacent edges before placing windows, preserving full bays away from cuts.
	for axis in 2:
		var along: Array[float]=xs if axis==0 else zs
		var across: Array[float]=zs if axis==0 else xs
		for line in across.size():
			for side in [-1,1]:
				var start: int=-1;var previous_inner:=false
				for k in range(along.size()):
					var expose:=false;var inner:=line>0 and line<across.size()-1
					if k<along.size()-1:
						var current:=line-1 if side==1 else line
						var other:=line if side==1 else line-1
						var occupied:=inside(xs,zs,cuts,k,current,y) if axis==0 else inside(xs,zs,cuts,current,k,y)
						var neighbor:=inside(xs,zs,cuts,k,other,y) if axis==0 else inside(xs,zs,cuts,other,k,y)
						expose=occupied and not neighbor
					if start>=0 and (not expose or inner!=previous_inner):
						var a:=Vector3(along[start],0,across[line]) if axis==0 else Vector3(across[line],0,along[start])
						var c:=Vector3(along[k],0,across[line]) if axis==0 else Vector3(across[line],0,along[k])
						if roof:
							P.rail(b,a+Vector3.UP*low,c+Vector3.UP*low)
						else:
							var gable:=axis==1 and line==0 and id in ["EastSouthDorm","EastNorthDorm"]
							var door:=false
							for cut: AABB in cuts:
								if absf(low-cut.position.y)>.05:continue
								if axis==0:
									if absf(cut.position.z-zs[0])<.05 and absf(across[line]-cut.end.z)<.05:door=true
									if absf(cut.end.z-zs[-1])<.05 and absf(across[line]-cut.position.z)<.05:door=true
								elif absf(cut.size.z-(zs[-1]-zs[0]))<.05:
									if absf(across[line]-cut.position.x)<.05 or absf(across[line]-cut.end.x)<.05:door=true
							wall(b,a,c,low,high,side,previous_inner,gable,previous_inner and door)
						start=-1
					if expose and start<0:start=k;previous_inner=inner

static func build(parent: Node3D,id: String,p: Vector3,size: Vector2,top: float,yaw: float,cuts: Array) -> void:
	var b:=K.holder(parent,id,p);b.rotation.y=yaw
	var w:=size.x;var d:=size.y;var xs: Array[float]=[-w/2,w/2];var zs: Array[float]=[-d/2,d/2]
	for cut: AABB in cuts:
		for x in [cut.position.x,cut.end.x]:
			if x>-w/2 and x<w/2 and not xs.has(x):xs.append(x)
		for z in [cut.position.z,cut.end.z]:
			if z>-d/2 and z<d/2 and not zs.has(z):zs.append(z)
	xs.sort();zs.sort()
	var levels: Array[float]=[8.4];var floors:=roundi((top-8.4)/3.3)
	for i in floors:levels.append(8.4+(top-8.4)*float(i+1)/floors)
	for y: float in levels:
		for i in range(xs.size()-1):
			for j in range(zs.size()-1):
				if not inside(xs,zs,cuts,i,j,y):continue
				var x: float=(xs[i]+xs[i+1])/2;var z: float=(zs[j]+zs[j+1])/2
				K.box(b,Vector3(x,y-.125,z),Vector3(xs[i+1]-xs[i],.25,zs[j+1]-zs[j]),"a3aaa3",true,22)
				if absf(y-21.6)<.05 or y==top:K.box(b,Vector3(x,y+.009,z),Vector3(xs[i+1]-xs[i],.017,zs[j+1]-zs[j]),"9da194",false,26)
	for f in range(levels.size()-1):boundaries(b,xs,zs,cuts,levels[f],levels[f+1],id)
	boundaries(b,xs,zs,cuts,top,top+.01,id,true)
	# Retain lower podium columns; the public entrances were checked between this grid.
	for side in [-1,1]:
		for x in range(-int(w/2)+2,int(w/2),7):K.column(b,Vector3(x,0,side*(d/2-.65)),8.4,.65)
	for cut: AABB in cuts:
		var r:=Rect2(cut.position.x,cut.position.z,cut.size.x,cut.size.z)
		# Only external edges need guards. Recess backs and sides are real walls.
		if absf(r.position.y+d/2)<.05 and id!="EastFrontReturn":P.rail(b,Vector3(r.position.x,cut.position.y,-d/2),Vector3(r.end.x,cut.position.y,-d/2))
		if absf(r.end.y-d/2)<.05:P.rail(b,Vector3(r.position.x,cut.position.y,d/2),Vector3(r.end.x,cut.position.y,d/2))
		if absf(r.position.x+w/2)<.05 and id!="EastNorthDorm":P.rail(b,Vector3(-w/2,cut.position.y,r.position.y),Vector3(-w/2,cut.position.y,r.end.y))
		if absf(r.end.x-w/2)<.05:P.rail(b,Vector3(w/2,cut.position.y,r.position.y),Vector3(w/2,cut.position.y,r.end.y))
		var centre:=r.get_center()
		K.planter(b,Vector3(centre.x,cut.position.y,centre.y)+Vector3(0,0,-r.size.y*.28))
	if id=="EastSouthDorm":
		var label:=K.label(b,"逸\n夫\n书\n院",Vector3(-w/2-.18,top-5.3,d*.13),.018);label.rotation.y=-PI/2
	# Small roof equipment stays on retained roof, never over an open sky court.
	for x in [-w*.25,0,w*.25]:
		if not cut_at(cuts,x,0,top):K.box(b,Vector3(x,top+.55,0),Vector3(2.5,1.1,2.2),"809184",false,22)
	K.finish(b)
