extends RefCounted
## Architect 1F 960x832: ruler 0/2/4/10m, 13.7857px/m. Historic plan, not as-built.
## Bridge pick (100,458) fixes the existing world (44,-400) interface; north uncalibrated.
const PIXELS_PER_METRE:float=13.785714285714285
const CENTRE_U:float=474.5
const CENTRE_V:float=357.5
static func point(u:float,v:float,y:float=0)->Vector3:
	return Vector3((CENTRE_V-v)/PIXELS_PER_METRE,y,(CENTRE_U-u)/PIXELS_PER_METRE)
static func world(u:float,v:float,y:float=0)->Vector3:
	return Vector3(44+(u-100)/PIXELS_PER_METRE,2.24+y,-400+(458-v)/PIXELS_PER_METRE)
static func polygon(points:Array)->PackedVector2Array:
	var out:=PackedVector2Array()
	for v in points:
		var p:=point(v[0],v[1]);out.append(Vector2(p.x,p.z))
	return out
## V154 eight homologous column symbols: 3F RMS2.09px,5F RMS0.72px; manual picks, not survey.
static func third_to_first(u:float,v:float)->Vector2:
	return Vector2(1.0004181218424546*u-(-0.002646330668105712)*v+(-3.9502184826354556),(-0.002646330668105712)*u+1.0004181218424546*v+(-4.174315821187558))
static func fifth_to_first(u:float,v:float)->Vector2:
	return Vector2(1.0322232799555746*u-(-0.00042441550788219207)*v+(-1.944178877820308),(-0.00042441550788219207)*u+1.0322232799555746*v+(0.8302655288479092))
static func outline()->Array:
	return [[25,24],[924,24],[924,691],[218,691],[218,242],[80,242]]
static func upper_raw_parts()->Array:
	# Five-floor trace: front cantilever, split top-side rooms, continuous opposite wing.
	return [[[25,24],[300,24],[300,548],[218,548],[218,669],[95,669]],[[410,24],[592,24],[592,228],[410,228]],[[688,24],[893,24],[893,228],[688,228]],[[218,548],[410,548],[410,440],[893,440],[893,669],[218,669]],[[300,187],[410,187],[410,240],[300,240]],[[410,228],[592,228],[592,240],[410,240]],[[592,187],[688,187],[688,228],[695,228],[695,240],[592,240]]]
static func upper_parts()->Array:
	var result:Array=[]
	for poly in upper_raw_parts():
		var converted:Array=[]
		for v in poly:
			var p:=fifth_to_first(v[0],v[1]);converted.append([p.x,p.y])
		result.append(converted)
	return result
