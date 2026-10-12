"""Reproduce historical plan registration from eight manually matched column symbols."""
from pathlib import Path
import json
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
target = np.array([[97,154],[303,235],[426,154],[508,154],[118,460],[303,460],[303,563],[118,685]], dtype=float)
source = {
    '3F': np.array([[103,160],[307,240],[429,159],[510,159],[118,464],[307,464],[307,566],[118,691]], dtype=float),
    '5F': np.array([[97,148],[295,228],[414,148],[494,148],[116,445],[295,445],[295,545],[116,663]], dtype=float),
}
held_out = {
    '3F': [([178,60],[175,55]), ([151,138],[149,132])],
    '5F': [([174,52],[175,55]), ([150,132],[149,132])],
}
fit = {}
for floor, points in source.items():
    rows, values = [], []
    for (u,v),(x,y) in zip(points,target):
        rows.extend([[u,-v,1,0],[v,u,0,1]])
        values.extend([x,y])
    a,b,tx,ty = np.linalg.lstsq(rows, values, rcond=None)[0]
    def transform(point):
        u,v = point
        return np.array([a*u-b*v+tx,b*u+a*v+ty])
    residual = np.linalg.norm(np.array([transform(point) for point in points])-target, axis=1)
    independent = [{'source':s,'target':t,'residual_pixels':float(np.linalg.norm(transform(s)-t))} for s,t in held_out[floor]]
    fit[floor] = {'a':float(a),'b':float(b),'tx':float(tx),'ty':float(ty),
        'source_points':points.tolist(),'target_points':target.tolist(),
        'residual_pixels':residual.tolist(),'rms_pixels':float(np.sqrt(np.mean(residual**2))),
        'max_pixels':float(max(residual)), 'held_out_front_stair_and_lift':independent}
result = {'manual_point_uncertainty_pixels':3, 'fit':fit,
    'source':'architect029/030/031 published2021-05-28, capture/revision unknown',
    'warning':'Visual column-symbol correspondence and two held-out front core picks, not site survey; residual measures selected image features only. 3F transform recorded but manually co-framed court geometry remains approximate.',
    'source_local_folder':'originals/student-rear-20261010',
    'scale_basis':'central_datum_review_v152.json'}
(ROOT/'references/visual_build_20261008/student_shared_grid_v154.json').write_bytes((json.dumps(result,indent=2)+'\n').encode())
print(json.dumps({floor:{'rms':item['rms_pixels'],'held_out':[x['residual_pixels'] for x in item['held_out_front_stair_and_lift']]} for floor,item in fit.items()}))
