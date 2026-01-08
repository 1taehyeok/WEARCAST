from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class GenerateVideoRequest(BaseModel):
    # In a real app these would be used, but for mock we can ignore specific content
    # person_image: UploadFile ... (handled via multipart usually but for MVP flow checking structure)
    # prompt: str ...
    pass

@router.post("/generate-video")
async def generate_video():
    """
    Mock video generation endpoint.
    Returns a fixed video URL.
    """
    # Mock processing delay could be added here if needed
    return {
        "status": "success",
        "video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    }
