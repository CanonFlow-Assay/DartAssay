import json
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
from tempfile import TemporaryDirectory
import unittest


SOURCE = Path(__file__).resolve().parents[1]


class PlaygroundTest(unittest.TestCase):
    def setUp(self):
        directory = TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        for name in ("playground/run.py", "eng/try-playground.sh"):
            destination = self.root / name
            destination.parent.mkdir(exist_ok=True)
            shutil.copyfile(SOURCE / name, destination)

    def invoke(self, exit_code, verdict):
        completed = subprocess.run(
            [sys.executable, "playground/run.py", "--output", "evidence"],
            cwd=self.root,
            capture_output=True,
            text=True,
            timeout=10,
        )
        self.assertEqual(completed.returncode, exit_code, completed.stderr)
        receipt = json.loads(completed.stdout)
        self.assertEqual(receipt["schemaVersion"], "canonflow.assay.playground-receipt/v2")
        self.assertEqual(receipt["repository"], "DartAssay")
        self.assertEqual(receipt["verdict"], verdict)
        self.assertEqual(receipt["exitCode"], exit_code)
        return receipt["qualification"]

    def write_qualifier_result(self, result, process_exit):
        result["schemaVersion"] = "canonflow.assay.dart-local-qualification/v1"
        child = self.root / "eng/try-playground.sh"
        child.write_text(
            'mkdir -- "$1"\n'
            f'printf "%s\\n" {shlex.quote(json.dumps(result))} > "$1/qualification.json"\n'
            f"exit {process_exit}\n",
            encoding="utf-8",
        )

    def test_missing_app_cannot_qualify(self):
        qualification = self.invoke(2, "Inconclusive")
        self.assertEqual(qualification["result"]["stage"], "app-inputs")

    def test_producer_fail_is_retained(self):
        self.write_qualifier_result(
            {"verdict": "Fail", "stage": "tests", "commandExitCode": 1}, 1
        )
        qualification = self.invoke(1, "Fail")
        self.assertEqual(qualification["result"]["stage"], "tests")
        self.assertEqual(qualification["exitCode"], 1)

    def test_disagreeing_exit_and_verdict_are_tool_failure(self):
        self.write_qualifier_result(
            {"verdict": "Inconclusive", "stage": "local-complete", "commandExitCode": 0},
            0,
        )
        qualification = self.invoke(3, "ToolFailure")
        self.assertEqual(qualification["exitCode"], 0)
        self.assertIn("disagrees", qualification["error"])


if __name__ == "__main__":
    unittest.main()
