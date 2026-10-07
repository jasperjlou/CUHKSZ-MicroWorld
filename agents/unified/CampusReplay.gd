extends RefCounted
static func replay(environment: Node,record: Dictionary) -> Dictionary:
	await environment.reset(record.task)
	for row: Dictionary in record.trajectory:
		var result: Dictionary=await environment.step(row.action)
		if not result.valid:return {"success":false,"reason":result.reason}
	var actual: Dictionary=environment.get_result();var expected: Dictionary=record.result
	return {"success":actual.success==expected.success and actual.visited==expected.visited and actual.actions==expected.actions and absf(actual.distance-expected.distance)<1.0 and absf(actual.elapsed-expected.elapsed)<.5,"actual":actual,"expected":expected}
