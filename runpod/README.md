# Деплой в Runpod (Pods)

Этот образ запускает OpenAI‑совместимый Whisper ASR на Runpod Pods аналогично HF Inference Endpoints.

Документация Runpod: https://docs.runpod.io/

## Сборка и публикация образа

```bash
# Сборка с SDK v0.2.0-patched
docker build \
  --build-arg SDK_REGISTRY=huggingface \
  --build-arg SDK_IMAGE=hfendpoints-sdk \
  --build-arg SDK_VERSION=v0.2.0-patched \
  -f runpod/Dockerfile \
  -t ghcr.io/temasm/hfie-asr-multilingual-whisper:runpod .

# Публикация в Docker Hub
docker push ghcr.io/temasm/hfie-asr-multilingual-whisper:runpod
```

## Запуск локально для проверки

```bash
docker run --rm -it -p 8080:80 \
  -e MODEL_ID=openai/whisper-large-v3 \
  -e VLLM_ATTENTION_BACKEND=XFORMERS \
  -e VLLM_USE_FLASHINFER=0 \
  -e DTYPE=half \
  -e VLLM_KV_CACHE_DTYPE=float16 \
  ghcr.io/temasm/hfie-asr-multilingual-whisper:runpod
```

## Настройка Pod на Runpod

1) Создайте Pod (GPU) и выберите ваш образ `ghcr.io/temasm/hfie-asr-multilingual-whisper:runpod`.
2) Переменные окружения (минимум):
```
MODEL_ID = openai/whisper-large-v3
VLLM_ATTENTION_BACKEND = XFORMERS
VLLM_USE_FLASHINFER = 0
# Для T4
DTYPE = half
VLLM_KV_CACHE_DTYPE = fp16
# Опционально
WHISPER_SAMPLING_RATE = 16000
WHISPER_SEGMENT_DURATION_SEC = 30
MAX_AUDIO_SECONDS = 0
LANGUAGE_FORCE = 
TIMESTAMPS = auto
```
3) Откройте порт 80.
4) Запустите Pod.

## Маршрут и проверка

OpenAI‑совместимый маршрут: `/v1/audio/transcriptions`

Пример запроса:
```bash
curl -s -X POST "http://<POD_PUBLIC_IP>:80/v1/audio/transcriptions" \
  -H "Authorization: Bearer dummy" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@sample.wav" \
  -F "model=whisper"
```

## Рекомендации
- Для T4 используйте `DTYPE=half` и `VLLM_KV_CACHE_DTYPE=float16`.
- Для Ampere+ (A10/A100) можно не указывать `DTYPE` — будет auto `bfloat16`.
- Рекомендуется backend внимания XFormers (`VLLM_ATTENTION_BACKEND=XFORMERS`) и отключённый FlashInfer (`VLLM_USE_FLASHINFER=0`).

Ссылки:
- Runpod Docs: https://docs.runpod.io/
- GHCR (проект): https://github.com/temasm/hfie-asr-multilingual-whisper/pkgs/container/hfie-asr-multilingual-whisper
- SDK‑образ: https://hub.docker.com/r/huggingface/hfendpoints-sdk/tags


