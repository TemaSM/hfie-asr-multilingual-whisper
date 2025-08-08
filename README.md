---
license: apache-2.0
pipeline_tag: automatic-speech-recognition
base_model:
- openai/whisper-large-v3
tags:
- inference_endpoints
- audio
- transcription
---

# Многоязычная транскрибация с Whisper для Inference Endpoints

**OpenAI-совместимый Whisper ASR**, оптимизированный для NVIDIA T4 (FP16) и Ampere+ (BF16).

Развёртывание поднимает HTTP‑эндпоинт, совместимый с [OpenAI Audio Transcriptions](https://platform.openai.com/docs/api-reference/audio/createTranscription), который можно вызывать клиентами OpenAI или напрямую через cURL.

## Возможности
- Поддержка T4 из коробки: auto‑dtype (FP16 для CC 7.5, BF16 для CC ≥ 8.0)
- Корректный аудиопайплайн: 16 000 Hz, чанкинг по 30 с (настраивается)
- OpenAI‑совместимый маршрут `/v1/audio/transcriptions`
- Настройки через ENV: `DTYPE`, `VLLM_KV_CACHE_DTYPE`, `TIMESTAMPS`, `LANGUAGE_FORCE`, `MAX_AUDIO_SECONDS` и т. д.
- Стабильный backend внимания: XFormers; FlashInfer по умолчанию отключаем через ENV

## Доступные маршруты (OpenAI‑совместимость)

| Маршрут                   | Описание                                  |
|:--------------------------|:-------------------------------------------|
| `/v1/audio/transcriptions`| Транскрибация аудио (OpenAI‑совместимый)   |
| `/docs`                   | Swagger UI                                 |

## Быстрый старт

- **Текстовый ответ**

```bash
curl -s -X POST "http://localhost:8080/v1/audio/transcriptions" \
  -H "Authorization: Bearer dummy" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@</path/to/audio.wav>" \
  -F "model=whisper" \
  -F "response_format=text"
```

- **JSON ответ**

```bash
curl -s -X POST "http://localhost:8080/v1/audio/transcriptions" \
  -H "Authorization: Bearer dummy" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@</path/to/audio.wav>" \
  -F "model=whisper" \
  -F "response_format=json"
```

- **Verbose JSON с сегментами и таймкодами**

```bash
curl -s -X POST "http://localhost:8080/v1/audio/transcriptions" \
  -H "Authorization: Bearer dummy" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@</path/to/audio.wav>" \
  -F "model=whisper" \
  -F "response_format=verbose_json"
```


## Спецификации и поддержка GPU

- **Движок**: vLLM 0.8.4
- **T4 (CC 7.5)**: dtype FP16 (`half`), KV cache `fp16`, backend внимания XFormers
- **Ampere+ (A10/A100, CC ≥ 8.0)**: dtype BF16 по умолчанию, KV cache `fp16`/`fp8`
- Сэмплинг аудио: 16,000 Hz

### Переменные окружения
- `MODEL_ID` (обязательно на Hugging Face Inference Endpoints)
- `DTYPE`/`VLLM_DTYPE`: `half|float16|fp16` → `half`, `bfloat16|bf16` → `bfloat16`. Если не указано, авто-детект по CC
- `VLLM_KV_CACHE_DTYPE`: `fp8|fp16|fp32` (по умолчанию `fp16`)
- `VLLM_ATTENTION_BACKEND=XFORMERS`
- `VLLM_USE_FLASHINFER=0`
- `WHISPER_SAMPLING_RATE=16000`
- `WHISPER_SEGMENT_DURATION_SEC=30`
- `MAX_AUDIO_SECONDS` (0 — без ограничения)
- `LANGUAGE_FORCE` (например, `fa`)
- `TIMESTAMPS`: `auto|none|segments`

### Деплой в Hugging Face Inference Endpoints
- Образ: `temasm/hfie-asr-multilingual-whisper`
- Порт: `80`
- Переменные окружения:

```
MODEL_ID = MohammadGholizadeh/whisper-large-v3-persian-common-voice-17
VLLM_ATTENTION_BACKEND = XFORMERS
VLLM_USE_FLASHINFER = 0
DTYPE = half
VLLM_KV_CACHE_DTYPE = fp16
```

## Сборка Docker‑образа

Вариант через Docker CLI (c параметрами SDK).  
Актуальные теги SDK: https://hub.docker.com/r/huggingface/hfendpoints-sdk/tags

```bash
docker build \
  --build-arg SDK_REGISTRY=huggingface \
  --build-arg SDK_IMAGE=hfendpoints-sdk \
  --build-arg SDK_VERSION=v0.2.0-patched \
  -t temasm/hfie-asr-multilingual-whisper:dev .
docker push temasm/hfie-asr-multilingual-whisper:dev
```

Либо через Makefile (использует `IMAGE=temasm/hfie-asr-multilingual-whisper`):

```bash
make build
make push
```

Полезные ссылки:
- Исходники на GitHub: https://github.com/<owner>/<repo>
- Образ на Docker Hub: https://hub.docker.com/r/temasm/hfie-asr-multilingual-whisper
- SDK‑образ на Docker Hub: https://hub.docker.com/r/huggingface/hfendpoints-sdk/tags

## Архитектура и как дорабатывать

- **Движок**: vLLM 0.8.4 (`AsyncLLMEngine`) с задачей `task="transcription"`. Параметры через `AsyncEngineArgs`, auto‑dtype и настраиваемый `kv_cache_dtype`.
- **Обработчик**: `WhisperHandler` в `handler.py` реализует OpenAI‑совместимый маршрут `/v1/audio/transcriptions`.
- **Аудиопайплайн**: загрузка через `librosa.load(..., sr=16000, mono=True)`, разбиение на фрагменты по `WHISPER_SEGMENT_DURATION_SEC` секунд, параллельная генерация.
- **Промпт**: аудио в `multi_modal_data` энкодера; декодер получает язык и маркер таймштампа согласно `TIMESTAMPS` и `LANGUAGE_FORCE`.
- **Таймштампы**: безопасная обработка `<|0.00|>`; режимы `auto|none|segments` управляют `<|notimestamps|>`/`<|0.00|>`.
- **Dtype и KV cache**: 
  - ENV: `DTYPE`/`VLLM_DTYPE` (`half|bfloat16`), `VLLM_KV_CACHE_DTYPE` (`fp8|fp16|fp32`)
  - Без ENV: авто‑детект по CC (≥8.0 → `bfloat16`, иначе `half`)
- **Оптимизации**: `VLLM_ATTENTION_BACKEND=XFORMERS`, `VLLM_USE_FLASHINFER=0` (особенно для T4)
- **Ограничение длительности**: `MAX_AUDIO_SECONDS` отсекает слишком длинный вход

### Рекомендации по доработкам

- **Новые ENV‑переменные**: инициализируйте в `__init__` `WhisperHandler`, задавайте безопасные значения по умолчанию
- **Аудио‑предобработка**: меняйте централизованно — `librosa.load` и `chunk_audio_with_duration`
- **Таймштампы/язык**: расширяйте вычисление `ts_token` и выбор `lang_tag`
- **Стабильность**: на T4 используйте `DTYPE=half` и `VLLM_KV_CACHE_DTYPE=fp16`