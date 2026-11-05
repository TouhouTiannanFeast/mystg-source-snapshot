"""Extract the original firing sound bank entries used by every source phase.

Every source game in NinaStage6Normal (TH08/10/11/13/17/20) ships the same
se_tan00.wav (enemy shot) and se_lazer00.wav (laser) bytes, so one pair of
original files covers all phases.  The script proves that equality before
copying the pair into the mod.
"""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(r"G:/MySTG")
MOD = ROOT / "aex-0.8.22/game/mod/NinaStage6Normal"
SCRATCH = ROOT / "work/nina-stage6/se06"
THDAT = Path(r"G:/TouHou/MLforDanmu/work/research/thtk-nightly-x64/thtk-bin-ci/thdat.exe")
BASE = Path(r"G:/TouHou")
GAMES = {
    "th08": (8, BASE / "[th08] 东方永夜抄 (日文版)/th08.dat"),
    "th10": (10, BASE / "[th10] 东方风神录 (汉化版+日文版)/th10.dat"),
    "th11": (11, BASE / "[th11] 东方地灵殿 (汉化版+日文版)/th11.dat"),
    "th13": (13, BASE / "[th13] 东方神灵庙 (汉化版+日文版)/th13.dat"),
    "th17": (17, BASE / "[th17] 东方鬼形兽（汉化版+日文版）/th17.dat"),
    "th20": (20, BASE / "th20/th20/th20.dat"),
}
FILES = ("se_tan00.wav", "se_lazer00.wav")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    evidence, hashes = {}, {name: set() for name in FILES}
    commands = []
    for game, (version, archive) in GAMES.items():
        assert archive.is_file(), archive
        out = SCRATCH / game
        out.mkdir(parents=True, exist_ok=True)
        args = [str(THDAT), "-x", str(version), str(archive), "-C", str(out), *FILES]
        subprocess.run(args, check=True, stdout=subprocess.DEVNULL)
        commands.append(" ".join(f'"{a}"' if " " in a else a for a in args))
        for name in FILES:
            value = digest(out / name)
            hashes[name].add(value)
            evidence.setdefault(name, {})[game] = value
    assert all(len(v) == 1 for v in hashes.values()), hashes

    MOD.joinpath("se").mkdir(parents=True, exist_ok=True)
    copied = {}
    for name in FILES:
        source = SCRATCH / "th13" / name
        target = MOD / "se" / name
        shutil.copy2(source, target)
        copied[name] = {"target": f"se/{name}", "sha256": digest(target)}
        assert digest(target) in hashes[name]
    reference = {
        "request": "original firing sound sources for every phase",
        "source_archive": "th13.dat (identical bytes in all six games)",
        "tool": str(THDAT),
        "commands": commands,
        "files": copied,
        "per_game_sha256": evidence,
        "conclusion": "se_tan00.wav and se_lazer00.wav are byte-identical across TH08-TH20; "
                      "one original pair covers every source phase.",
    }
    (MOD / "source" / "se06.json").write_text(
        json.dumps(reference, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(reference, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
