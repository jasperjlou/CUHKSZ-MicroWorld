extends RefCounted
## V61 visual section fit from built exterior/interior, not surveyed roof heights.
const UPPER_FLOOR := 9.2
static func roof_height(x: float) -> float:
	if x>22:return lerpf(21.5,17.0,clampf((x-22)/41,0,1))
	if x>5:return lerpf(17.8,21.5,(x-5)/17)
	return lerpf(17.4,17.8,clampf((x+63)/68,0,1))
