"""Offline task/report contracts. Run with: python -m unittest discover -s tests -p test_rc1_pipeline.py"""
import copy
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'benchmark'))
from run_benchmark import CONDITIONS, load_tasks, safe_environment, infrastructure_result, find_godot
from report import aggregate
from unittest.mock import patch

class PipelineTests(unittest.TestCase):
    def test_suite_complete(self):
        manifest,tasks=load_tasks('journey-v1')
        self.assertEqual(len(tasks),16)
        self.assertEqual(len({t['task_id'] for t in tasks}),16)
        self.assertEqual(set(t['category'] for t in tasks),{'navigation','timing','transport','recovery','information'})
        self.assertEqual(tuple(manifest['conditions']),CONDITIONS)

    def test_required_limits_and_trust_boundary(self):
        for t in load_tasks('journey-v1')[1]:
            self.assertTrue(t['max_steps']>0 and t['max_simulated_duration']>0)
            self.assertIn('verifier',t)
            self.assertFalse({'best_branch','correct_route','shortest_path'}&t.keys())

    def test_bad_endpoints(self):
        for url in ['http://example.test/v1','https://user:password@example.test','https://example.test?token=private','file:///tmp/provider']:
            with patch.dict('os.environ',{'AGENT_BASE_URL':url}):
                with self.assertRaises(ValueError):safe_environment('openai-compatible')

    def test_environment_does_not_reveal_key(self):
        with patch.dict('os.environ',{'AGENT_BASE_URL':'https://example.test/v1','OPENAI_API_KEY':'test-only-never-real'}):
            env=safe_environment('openai-compatible')
            self.assertEqual(env['LLM_API_KEY'],'test-only-never-real')
            self.assertEqual(env['LLM_BASE_URL'],'https://example.test/v1')

    def report_fixture(self, evidence='mock', tokens=None):
        return {'run_id':'test','provider':'mock' if evidence=='mock' else 'openai-compatible','model':'fixture','condition':'Reactive','suite_version':'journey-v1','environment_sha256':'test','task_id':'time_missed','success':False,'action_count':1,'invalid_actions':0,'wrong_branch_count':0,'replanning_count':0,'lateness_seconds':100,'total_tokens':tokens,'latency_ms':None,'evidence_kind':evidence}

    def aggregate_fixture(self,rows):
        (ROOT/'tests/artifacts').mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=ROOT/'tests/artifacts') as name:
            root=Path(name)
            for i,row in enumerate(rows):
                p=root/str(i);p.mkdir();(p/'result.json').write_text(json.dumps(row),encoding='utf8')
            return aggregate(root),(root/'report.md').read_text(encoding='utf8')

    def test_mock_missing_metrics_not_zero(self):
        summary,report=self.aggregate_fixture([self.report_fixture()])
        self.assertFalse(summary['real_model_results'])
        self.assertIsNone(summary['groups'][0]['avg_total_tokens'])
        self.assertEqual(summary['groups'][0]['success_rate'],0)
        self.assertIn('Pipeline validation only',report)

    def test_loopback_is_not_real_model(self):
        summary,_=self.aggregate_fixture([self.report_fixture('loopback_contract',86)])
        self.assertFalse(summary['real_model_results'])

    def test_evidence_types_never_mix(self):
        a=self.report_fixture('loopback_contract',86);b=self.report_fixture('real_model',None);b['run_id']='other'
        summary,_=self.aggregate_fixture([a,b]);self.assertEqual(len(summary['groups']),2)

    def test_duplicate_results_rejected(self):
        with self.assertRaises(ValueError):self.aggregate_fixture([self.report_fixture(),self.report_fixture()])

    def test_killed_episode_is_failed_not_zero_metrics(self):
        job={k:'fixture' for k in ('run_id','condition','provider','model','suite_version','source_commit','environment_sha256')}
        job.update(seed=42,task={'task_id':'fixture'},run_config={'evidence_kind':'mock'})
        result=infrastructure_result(job,'wall_timeout')
        self.assertFalse(result['success']);self.assertTrue(result['timeout'])
        self.assertIsNone(result['action_count']);self.assertIsNone(result['arrival_time'])

    @unittest.skipUnless(sys.platform=='win32','Windows console launcher behavior')
    def test_timeout_targets_engine_not_console_wrapper(self):
        with tempfile.TemporaryDirectory(dir=ROOT/'tests/artifacts') as name:
            console=Path(name)/'Godot_console.exe';direct=Path(name)/'Godot.exe'
            console.touch();direct.touch()
            with patch('subprocess.check_output',return_value='4.5.1.stable.fixture') as version:
                selected,_=find_godot(str(console))
                self.assertEqual(Path(selected),direct)
                self.assertEqual(version.call_args.args[0][0],str(direct))

if __name__=='__main__':unittest.main()
