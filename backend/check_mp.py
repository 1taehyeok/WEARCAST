import mediapipe as mp
print("MediaPipe imported")
print(f"File: {mp.__file__}")
try:
    print(f"Solutions: {mp.solutions}")
except AttributeError as e:
    print(f"Error accessing solutions: {e}")
    print(f"Dir(mp): {dir(mp)}")
