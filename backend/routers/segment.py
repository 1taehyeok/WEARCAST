from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import cv2
import numpy as np
import uuid
import os
from core.utils import calculate_center, calculate_detailed_euclidean_distance

router = APIRouter()

# Initialize MediaPipe Tasks ImageSegmenter
model_path = 'selfie_segmenter.tflite'

# Verify model exists
if not os.path.exists(model_path):
    print(f"WARNING: Model {model_path} not found. Segmentation will fail.")

base_options = python.BaseOptions(model_asset_path=model_path)
# output_category_mask=True: returns a uint8 mask where each pixel matches a class index (0=background, 1=person for selfie)
options = vision.ImageSegmenterOptions(base_options=base_options, output_category_mask=True)
segmenter = vision.ImageSegmenter.create_from_options(options)

@router.post("/segment")
async def segment_image(image: UploadFile = File(...)):
    try:
        # Read image
        contents = await image.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image file")

        height, width, _ = img.shape
        image_center = (width / 2, height / 2)

        # Process with MediaPipe
        # MediaPipe Tasks expects mp.Image
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)
        
        segmentation_result = segmenter.segment(mp_image)
        category_mask = segmentation_result.category_mask
        
        if category_mask is None:
             return {
                "image_width": width,
                "image_height": height,
                "persons": [],
                "selected_person_id": None,
                "mask_url": None
            }

        # category_mask is mp.Image, get numpy view
        mask_np = category_mask.numpy_view()
        # mask_np contains class indices (0: background, 1: person, etc.)
        # Selfie segmenter typically has 0=background, 1=person.
        
        # Create binary mask for person (class 1+)
        # If there are multiple people (e.g. hair, body, face split classes?), 
        # Standard selfie segmenter (multiclass) has: 0: background, 1: hair, 2: body, 3: face, 4: clothes, 5: others (depends on model).
        # But 'selfie_segmenter.tflite' (generic) is usually binary or few classes.
        # Let's assume indices > 0 are "person".
        
        binary_mask = (mask_np > 0).astype(np.uint8) * 255

        # Find Connected Components (blobs) to identify different people
        num_labels, labels_im, stats, centroids = cv2.connectedComponentsWithStats(binary_mask, connectivity=8)

        persons = []
        # stats: [left, top, width, height, area]
        # label 0 is background
        for i in range(1, num_labels):
            x, y, w, h, area = stats[i]
            
            # Filter small noise
            if area < 500: 
                continue

            cx, cy = centroids[i]
            distance = calculate_detailed_euclidean_distance((cx, cy), image_center)
            
            persons.append({
                "id": i,
                "bbox": [int(x), int(y), int(x+w), int(y+h)],
                "center_distance": float(distance),
                "area": int(area)
            })

        if not persons:
             return {
                "image_width": width,
                "image_height": height,
                "persons": [],
                "selected_person_id": None,
                "mask_url": None
            }

        # Select Central Person
        persons.sort(key=lambda p: p["center_distance"])
        selected_person = persons[0]
        selected_id = selected_person["id"]

        # specific mask for selected person
        person_mask = (labels_im == selected_id).astype(np.uint8) * 255
        
        # Save Mask
        filename = f"mask_{uuid.uuid4()}.png"
        save_path = os.path.join("static", filename)
        cv2.imwrite(save_path, person_mask)

        # Response
        response_persons = []
        for p in persons:
            response_persons.append({
                "id": p["id"],
                "bbox": p["bbox"],
                "center_distance": p["center_distance"]
            })

        return {
            "image_width": width,
            "image_height": height,
            "persons": response_persons,
            "selected_person_id": selected_id,
            "mask_url": f"/static/{filename}"
        }

    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
