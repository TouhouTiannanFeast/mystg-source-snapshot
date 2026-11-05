"""Extract only TH20's sixth-stage boss BGM to NinaStage6Normal/music06.

Source is the local retail TH20 thbgm.dat.  Each 0x34-byte thbgm.fmt row
carries: name[16], data offset, data size, loop start, loop end, then the
standard 16-bit stereo 44.1 kHz format words.  musiccmt.txt identifies the
row as No.13 / the sixth-stage boss (Iwanaga Aariya), because the retail
filename order is not sequential (th20_12.wav is No.13).

The table files are extracted from th20.dat by thdat.exe here, so a rerun
only needs the retail game directory.
"""
from __future__ import annotations

import hashlib
import json
import struct
import subprocess
import wave
from pathlib import Path

ROOT = Path(r"G:/MySTG")
MOD = ROOT / "aex-0.8.22/game/mod/NinaStage6Normal/music06"
LOG = ROOT / "work/logs/nina-stage6/fix06-music-source"
GAME = Path(r"G:/TouHou/th20/th20")
THDAT = Path(r"G:/TouHou/MLforDanmu/work/research/thtk-nightly-x64/thtk-bin-ci/thdat.exe")
FMT = LOG / "thbgm.fmt"
COMMENT = LOG / "musiccmt.txt"
DAT = GAME / "thbgm.dat"
ARCHIVE = GAME / "th20.dat"
TRACK = b"th20_12.wav"
OUT = MOD / "th20-12-stone-goddess.wav"
ROW = 0x34


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def extract_tables() -> None:
    LOG.mkdir(parents=True, exist_ok=True)
    if FMT.is_file() and COMMENT.is_file():
        return
    subprocess.run(
        [str(THDAT), "-x", "20", str(ARCHIVE), "-C", str(LOG), "thbgm.fmt", "musiccmt.txt"],
        check=True,
        stdout=subprocess.DEVNULL,
    )


def main() -> None:
    assert DAT.is_file() and ARCHIVE.is_file(), "local retail TH20 is required"
    extract_tables()
    assert FMT.is_file() and COMMENT.is_file()

    comment = COMMENT.read_bytes().decode("cp932")
    section = comment.split("@bgm/th20_12", 1)[1].split("@bgm/", 1)[0]
    assert "No.13" in section and "最後の一人は慣れてるから" in section and "磐永 阿梨夜" in section

    table = FMT.read_bytes()
    # The retail table ends with a short NUL terminator after its fixed rows.
    tail = table[len(table) // ROW * ROW:]
    assert len(table) >= ROW and not any(tail)
    row = next(
        (table[i:i + ROW] for i in range(0, len(table) // ROW * ROW, ROW)
         if table[i:i + 16].split(b"\0", 1)[0] == TRACK),
        None,
    )
    assert row is not None, "th20_12.wav row missing from thbgm.fmt"
    offset, size, loop_start, loop_end = struct.unpack_from("<4I", row, 16)
    encoding, channels, rate, byte_rate, align, bits = struct.unpack_from("<HHIIHH", row, 32)
    assert (encoding, channels, rate, byte_rate, align, bits) == (1, 2, 44100, 176400, 4, 16)
    assert 0 < loop_start < loop_end <= size and size % align == 0
    assert loop_end == size, "unexpected trailing non-loop audio"

    with DAT.open("rb") as source:
        source.seek(offset)
        pcm = source.read(size)
    assert len(pcm) == size

    MOD.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT), "wb") as output:
        output.setnchannels(channels)
        output.setsampwidth(bits // 8)
        output.setframerate(rate)
        output.writeframes(pcm)
    with wave.open(str(OUT), "rb") as output:
        assert (output.getnchannels(), output.getsampwidth(), output.getframerate(), output.getnframes()) == (
            channels, bits // 8, rate, size // align)

    # Retain only this entry's authoritative source bytes and comment, never
    # the complete thbgm.dat or comment table in the mod.
    (MOD / "th20_12.fmt-row.bin").write_bytes(row)
    (MOD / "musiccmt-th20_12.txt").write_text(section, encoding="utf-8")
    loop_end_seconds = loop_end / byte_rate
    loop_length_seconds = (loop_end - loop_start) / byte_rate
    lua = (
        "-- TH20 th20_12.wav: No.13 'Stone Goddess' / sixth-stage boss Iwanaga Aariya.\n"
        "-- LoadMusic arguments are loop end and loop length, in seconds.\n"
        "NinaStage6Music={name='nina6.th20.s6boss'}\n"
        "LoadMusic(NinaStage6Music.name,'music06/th20-12-stone-goddess.wav',"
        f"{loop_end_seconds:.15g},{loop_length_seconds:.15g})\n"
    )
    (MOD / "load.lua").write_text(lua, encoding="utf-8")
    reference = {
        "source": str(DAT), "source_sha256": digest(DAT),
        "archive": str(ARCHIVE), "archive_sha256": digest(ARCHIVE),
        "fmt_source": str(FMT), "fmt_sha256": digest(FMT),
        "track": TRACK.decode(), "title": "最後の一人は慣れてるから　～ Stone Goddess",
        "role": "TH20 No.13 sixth-stage boss / 磐永 阿梨夜",
        "offset_bytes": offset, "size_bytes": size,
        "loop_start_bytes": loop_start, "loop_end_bytes": loop_end,
        "sample_rate": rate, "channels": channels, "bits_per_sample": bits,
        "byte_rate": byte_rate, "loop_end_seconds": loop_end_seconds,
        "loop_length_seconds": loop_length_seconds, "output": OUT.name,
        "output_sha256": digest(OUT),
    }
    (MOD / "reference.json").write_text(json.dumps(reference, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(reference, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
