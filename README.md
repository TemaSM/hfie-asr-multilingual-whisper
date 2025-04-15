---
license: apache-2.0
pipeline_tag: automatic-speech-recognition
base_model:
- openai/whisper-large-v3
tags:
- inference_endpoints
- openai
- audio
- transcription
---

# Inference Endpoint - OpenAI Whisper Large V3

**Deploy OpenAI's Whisper Inference Endpoint to transcribe audio files to text in many languages**

Resulting deployment exposes an [OpenAI Platform Transcription](https://platform.openai.com/docs/api-reference/audio/createTranscription) compatible HTTP endpoint 
which you can query using the `OpenAi` Libraries or directly through `cURL` for instance.

## Available Routes
| path                         |        description                                |
|:-----------------------------|:--------------------------------------------------|
| /api/v1/audio/transcriptions | Transcription endpoint to interact with the model |
| /docs                        | Visual documentation                              | 

## Specifications
- Inference engine: vLLM
- Computation data type: `bfloat16`
- KV cache data type: `float8`
- PyTorch Compile: 🟢
- CUDA Graphs:     🟢
