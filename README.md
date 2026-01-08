# WearCast MVP

Virtual Try-On MVP using Flutter and FastAPI.

## Project Structure
- `backend/`: Python FastAPI server (Segmentation, Mock Generation).
- `frontend/`: Flutter Mobile App.

## Prerequisites
- Flutter SDK (latest stable)
- Python 3.10+
- Android Emulator or Physical Device

## How to Run

### 1. Backend (FastAPI)
1. Navigate to `backend/`.
   ```bash
   cd backend
   ```
2. Activate Virtual Environment (if not active).
   ```bash
   .\venv\Scripts\activate
   ```
3. Run Server.
   ```bash
   uvicorn main:app --host 0.0.0.0 --reload
   ```
   Server runs at `http://localhost:8000` (or your local IP).

### 2. Frontend (Flutter)
1. Navigate to `frontend/`.
   ```bash
   cd frontend
   ```
2. **Important**: Update API IP Address.
   - Open `lib/core/api/api_client.dart`.
   - Change `baseUrl` to your machine's local IP (e.g., `http://192.168.1.x:8000`) if testing on physical device.
   - Using `http://10.0.2.2:8000` is fine for Android Emulator.
3. Run App.
   ```bash
   flutter run
   ```

## Features
- **Capture/Gallery**: Take a photo of yourself.
- **Segmentation**: Server segments the person and identifies bounding boxes.
- **Clothing Selection**: Choose a shirt from the list.
- **Video Generation**: Simulate video generation (Mock).

## Notes
- Video generation is mocked and returns a sample video.
- Segmentation uses MediaPipe Selfie Segmentation.
