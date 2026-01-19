import datetime
from http.client import HTTPException

from app.requests.api_schemas import PeakCravingRequest


def _calculate_daily_risk(req: PeakCravingRequest) -> Dict:
    sess = ai_models.onnx_session_craving
    if sess is None:
        raise HTTPException(status_code=503, detail="Craving Model not loaded")

    # Normalize Day
    current_day = (
        req.day_of_week if req.day_of_week is not None else datetime.now().weekday()
    )
    if current_day > 6:
        current_day = 6

    batch_input = []
    time_labels = []

    # Generate 96 points (00:00, 00:15, ... 23:45)
    for step in range(0, 96):
        hour_float = step / 4.0
        hour_part = int(hour_float)
        minute_part = int((hour_float - hour_part) * 60)
        time_labels.append(f"{hour_part:02d}:{minute_part:02d}")

        batch_input.append(
            [
                float(hour_float),
                float(current_day),
                float(req.ftnd_score),
                float(req.smoke_avg_per_day),
                float(req.age),
                float(req.gender_code),
                float(req.mood_level),
                float(req.anxiety_level),
            ]
        )

    # Inference
    input_name = sess.get_inputs()[0].name
    predictions = sess.run(None, {input_name: np.array(batch_input, dtype=np.float32)})[
        0
    ]
    preds_flat = predictions.flatten().tolist()

    # Find Peak
    max_val = max(preds_flat)
    peak_index = preds_flat.index(max_val)

    return {
        "predictions": preds_flat,
        "time_labels": time_labels,
        "peak_val": max_val,
        "peak_time": time_labels[peak_index],
        "peak_index": peak_index,
    }
