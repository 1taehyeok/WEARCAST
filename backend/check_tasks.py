import mediapipe as mp
try:
    from mediapipe.tasks import python
    from mediapipe.tasks.python import vision
    print("Tasks API imported successfully")
except ImportError as e:
    print(f"Tasks API import failed: {e}")
