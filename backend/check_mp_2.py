import sys
try:
    import mediapipe.python.solutions as solutions
    print("Explicit import success")
except ImportError as e:
    print(f"Explicit import failed: {e}")
except Exception as e:
    print(f"Explicit import error: {e}")

import mediapipe as mp
print(f"MP dir: {dir(mp)}")
