IMAGE ?= temasm/hfie-asr-multilingual-whisper
TAG   ?= $(shell git rev-parse --short HEAD)
SDK_REGISTRY ?= ghcr.io/huggingface
SDK_IMAGE    ?= hfendpoints-sdk
SDK_VERSION  ?= v0.2.0-patched

build:
	docker build \
	  --build-arg SDK_REGISTRY=$(SDK_REGISTRY) \
	  --build-arg SDK_IMAGE=$(SDK_IMAGE) \
	  --build-arg SDK_VERSION=$(SDK_VERSION) \
	  -t $(IMAGE):$(TAG) .

push:
	docker push $(IMAGE):$(TAG)

tag-latest:
	docker tag $(IMAGE):$(TAG) $(IMAGE):latest
	docker push $(IMAGE):latest

run-local:
	docker run --rm -it -p 8080:80 \
	  -e MODEL_ID=openai/whisper-large-v3 \
	  -e VLLM_ATTENTION_BACKEND=XFORMERS \
	  -e VLLM_USE_FLASHINFER=0 \
	  -e DTYPE=half \
	  -e VLLM_KV_CACHE_DTYPE=fp16 \
	  $(IMAGE):$(TAG)

