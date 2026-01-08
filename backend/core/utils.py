import math

def calculate_center(bbox):
    """
    Calculate the center (cx, cy) of a bounding box.
    bbox: [x1, y1, x2, y2]
    """
    x1, y1, x2, y2 = bbox
    return ((x1 + x2) / 2, (y1 + y2) / 2)

def calculate_detailed_euclidean_distance(p1, p2):
    """
    Calculate Euclidean distance between two points p1(x, y) and p2(x, y).
    """
    return math.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)
