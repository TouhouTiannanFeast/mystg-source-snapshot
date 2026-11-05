# Compatibility entry for the superseding rotating-star check.
import runpy
from pathlib import Path
runpy.run_path(str(Path(__file__).with_name('verify05.py')),run_name='__main__')
