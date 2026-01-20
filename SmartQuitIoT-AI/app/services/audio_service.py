import io

import soundfile as sf
from app.models import (
    stt_pipeline,
    tts_processor,
    tts_model,
    tts_vocoder,
    speaker_embeddings,
)


def transcribe_audio_file(file_path: str) -> str:

    try:
        result = stt_pipeline(file_path)
        return result["text"]
    except Exception as e:
        print(f"Error STT: {e}")
        raise e


def text_to_speech_stream(text: str) -> io.BytesIO:
    if speaker_embeddings is None:
        raise RuntimeError("Speaker embeddings failed to load.")

    try:
        inputs = tts_processor(text=text, return_tensors="pt")
        speech = tts_model.generate_speech(
            inputs["input_ids"], speaker_embeddings, vocoder=tts_vocoder
        )
        memory_buffer = io.BytesIO()
        sf.write(memory_buffer, speech.numpy(), samplerate=16000, format="WAV")
        memory_buffer.seek(0)
        return memory_buffer
    except Exception as e:
        print(f"Error TTS: {e}")
        raise e
