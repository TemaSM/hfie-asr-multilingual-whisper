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

| spec               | value                 | description                                                                                                |
|:------------------ |:---------------------:|:-----------------------------------------------------------------------------------------------------------|
| Engine             | vLLM (v0.8.3)         | Underlying inference engine leverages [vLLM](https://docs.vllm.ai/en/latest/)                              |
| Hardware           | GPU (Ada Lovelace)    | Requires the target endpoint to run over NVIDIA GPUs with at least compute capabilities 8.9 (Ada Lovelace) |
| Compute data type  | `bfloat16`            | Computations (matmuls, norms, etc.) are done using `bfloat16` precision                                    |
| KV cache data type | `float8` (e4m3)       | Key-Value cache is stored on the GPU using `float8` (`float8_e4m3`) precision to save space                |
| PyTorch Compile    | ✅                    | Enable the use of `torch.compile` to further optimize model's execution with more optimizations            |
| CUDA Graphs        | ✅                    | Enable the use of so called "[CUDA Graphs](https://developer.nvidia.com/blog/cuda-graphs/)" to reduce overhead executing GPU computations | 
