extends RefCounted
## V197: legacy A/B outside is a low continuous apron; gate axis rises inward.
## 57 vertical probes support the rising axis, but metres/registration remain fitted.
const LOW:float=-2.325
const UPPER:float=2.24
static func axis(x:float)->float:
	return lerpf(LOW,UPPER,clampf((x+121.8)/67.8,0,1))
static func fitted_height(x:float,z:float,base:float)->float:
	var along:float=smoothstep(-282,-261,z)*(1-smoothstep(-78,-62,z))
	var edge:float=lerpf(-128.2,-140.62,smoothstep(163.8,181.5,-z))
	var across:float=1-smoothstep(edge,edge+2,x)
	var low:float=lerpf(-1.83,LOW,smoothstep(148,163.8,-z))
	var h:float=lerpf(base,low,along*across)
	# Wide shared rising promenade, not a bridge above the lower rear road.
	if x> -166 and x< -54:
		var band:float=smoothstep(-180,-173,z)*(1-smoothstep(-161,-154,z))
		h=lerpf(h,axis(x),band)
	return h
