extends RefCounted
## Independent3F public map1856x1339 to registered4F; three shared core centres.
## RMS5.49 public4F pixels, schematic—not surveying or a north calibration.
const Upper=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
static func point3(x:float,z:float,y:float=0)->Vector3:
	return Upper.point(.8829550434965218*x-.002528195581668058*z+33.0821290112549,.002528195581668058*x+.8829550434965218*z+22.876427747016958,y)
static func point1(x:float,z:float,y:float=0)->Vector3:
	return Vector3(.04977559923487591*x-.0006624529060538255*z-39.90463089502321,y,.0006624529060538255*x+.04977559923487591*z-29.700326258492026)
static func point2(x:float,z:float,y:float=0)->Vector3:
	return Upper.point(.8898224018283948*x+.009429443320101427*z+15.595434315026154,-.009429443320101427*x+.8898224018283948*z+62.500464330004945,y)
static func second_outline()->PackedVector2Array:
	var result:=PackedVector2Array()
	for p in [[154,40],[698,40],[698,127],[878,277],[935,222],[1017,300],[1090,230],[1238,382],[1365,260],[1425,300],[1515,400],[1630,497],[1795,567],[1615,743],[1540,728],[1410,681],[1310,637],[1274,610],[1075,810],[916,1070],[850,993],[790,930],[725,886],[665,855],[606,843],[350,843],[350,685],[154,685]]:
		var q:=point2(p[0],p[1]);result.append(Vector2(q.x,q.z))
	return result
static func front2()->PackedVector2Array:
	var result:=PackedVector2Array()
	for p in [[154,685],[350,685],[350,843],[606,843],[665,855],[725,886],[790,930],[850,993],[916,1070]]:
		var q:=point2(p[0],p[1]);result.append(Vector2(q.x,q.z))
	return result
static func polygon3(points:Array)->PackedVector2Array:
	var result:=PackedVector2Array()
	for p in points:
		var q:=point3(p[0],p[1]);result.append(Vector2(q.x,q.z))
	return result
static func third_outline()->PackedVector2Array:
	return polygon3([[238,32],[608,32],[608,74],[764,74],[987,294],[1005,280],[1070,341],[1128,293],[1254,420],[1378,299],[1488,408],[1600,554],[1682,595],[1785,620],[1608,798],[1507,790],[1459,774],[939,1299],[832,1190],[719,1104],[607,1056],[488,1037],[362,1037],[301,1045],[301,894],[350,894],[350,737],[154,737],[154,216],[238,216]])
static func front3()->PackedVector2Array:
	return polygon3([[154,737],[350,737],[350,894],[301,894],[301,1045],[362,1037],[488,1037],[607,1056],[719,1104],[832,1190],[939,1299],[1459,774]])
static func ground_front()->PackedVector2Array:
	var result:=PackedVector2Array()
	for p in [[14,702],[210,702],[210,874],[480,874],[525,880],[575,895],[620,922],[675,970]]:
		var q:=point1(p[0],p[1]);result.append(Vector2(q.x,q.z))
	return result
static func entrance(y:float=0)->Vector3:return point1(575,895,y)
