#!/usr/bin/env python3
"""Run the local M1 qualifier and retain its reported outcome."""

import argparse
from contextlib import suppress
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
NATIVE_SCHEMA = "canonflow.assay.dart-local-qualification/v1"
EXIT_CODES = {"Fail": 1, "Inconclusive": 2, "ToolFailure": 3}
TIMEOUT_SECONDS = 180


def execute(command, output):
    with (output / "stdout.log").open("wb") as stdout:
        with (output / "stderr.log").open("wb") as stderr:
            process = subprocess.Popen(
                command,
                cwd=ROOT,
                stdout=stdout,
                stderr=stderr,
                start_new_session=True,
            )
            try:
                return process.wait(timeout=TIMEOUT_SECONDS)
            except BaseException:
                with suppress(ProcessLookupError):
                    os.killpg(process.pid, signal.SIGKILL)
                process.wait()
                raise


def read_result(path, observed_exit):
    with path.open(encoding="utf-8") as stream:
        result = json.load(stream)
    if not isinstance(result, dict) or result.get("schemaVersion") != NATIVE_SCHEMA:
        raise ValueError("invalid local qualification result schema")
    verdict = result.get("verdict")
    if not isinstance(verdict, str) or EXIT_CODES.get(verdict) != observed_exit:
        raise ValueError("local qualification verdict disagrees with its process exit")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True, help="fresh evidence directory")
    try:
        args = parser.parse_args()
    except SystemExit as error:
        return 64 if error.code else 0

    output = args.output.absolute()
    try:
        output.mkdir(parents=True, exist_ok=False)
    except FileExistsError:
        print("Choose a fresh evidence directory.", file=sys.stderr)
        return 64
    except OSError as error:
        print(f"Could not create the evidence directory: {error}", file=sys.stderr)
        return 3

    native = output / "native"
    command = ["bash", "eng/try-playground.sh", str(native)]
    qualification = {"command": command, "exitCode": None}
    try:
        observed_exit = execute(command, output)
        qualification["exitCode"] = observed_exit
        result = read_result(native / "qualification.json", observed_exit)
        qualification["result"] = result
        verdict = result["verdict"]
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        qualification["error"] = str(error)
        verdict = "ToolFailure"

    artifacts = {}
    for path in sorted(output.rglob("*")):
        if path.is_file() and not path.is_symlink():
            try:
                with path.open("rb") as stream:
                    artifacts[path.relative_to(output).as_posix()] = hashlib.file_digest(
                        stream, "sha256"
                    ).hexdigest()
            except OSError as error:
                qualification["error"] = str(error)
                verdict = "ToolFailure"

    receipt = {
        "schemaVersion": "canonflow.assay.playground-receipt/v2",
        "repository": "DartAssay",
        "verdict": verdict,
        "exitCode": EXIT_CODES[verdict],
        "qualification": qualification,
        "platforms": {
            "deviceIntegration": "NotRun",
            "androidDebug": "NotRun",
            "iosNoCodesign": "NotRun",
        },
        "artifacts": artifacts,
    }
    print(json.dumps(receipt, indent=2))
    return receipt["exitCode"]


if __name__ == "__main__":
    raise SystemExit(main())
