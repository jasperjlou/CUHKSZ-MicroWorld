"""Run the milestone to completion with a retained log; no interactive game is closed."""
import subprocess
import argparse
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--script',default='LowerCampusExpansionCapture')
parser.add_argument('--log',default='lower-expansion-engine')
parser.add_argument('--headless',action='store_true',help='Physics-only drivers without screenshot calls')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
engine = root / '.tools/godot/Godot_v4.5.1-stable_win64.exe'
info = subprocess.STARTUPINFO()
info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
info.wShowWindow = 0
output = root / 'tests/artifacts' / (args.log+'.log')
with output.open('w',encoding='utf-8') as log:
    run = subprocess.run([str(engine)]+(['--headless'] if args.headless else [])+['--path',str(root),'--script',
        'res://tests/'+args.script+'.gd','--fixed-fps','60',
        '--resolution','1440x900','--position','-1600,0'],
        cwd=root,stdout=log,stderr=subprocess.STDOUT,startupinfo=info,timeout=600)
log_text = output.read_text(encoding='utf-8')
print(log_text[-18000:])
# Godot can keep running a capture after a builder script aborts and still exit 0.
# Treat the actual engine diagnostics as failure, even if the remaining routes pass.
if run.returncode == 0 and any(line.startswith(('SCRIPT ERROR:', 'ERROR:')) for line in log_text.splitlines()):
    print('Milestone failed: engine errors are present in the retained log.')
    raise SystemExit(1)
raise SystemExit(run.returncode)
