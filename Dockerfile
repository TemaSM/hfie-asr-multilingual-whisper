ARG SDK_REGISTRY=huggingface
ARG SDK_IMAGE=hfendpoints-sdk
ARG SDK_VERSION=v0.2.0-patched
FROM ${SDK_REGISTRY}/${SDK_IMAGE}:${SDK_VERSION} AS sdk

FROM vllm/vllm-openai:v0.8.4
LABEL org.opencontainers.image.description="OpenAI-compatible Whisper ASR (vLLM 0.8.4), T4-friendly"
RUN --mount=type=bind,from=sdk,source=/opt/hfendpoints/dist,target=/usr/local/endpoints/dist \
    --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    python3 -m pip install --no-cache-dir -r /tmp/requirements.txt && \
    python3 -m pip install --no-cache-dir /usr/local/endpoints/dist/*.whl

COPY handler.py /usr/local/endpoint/

ENV INTERFACE=0.0.0.0
ENV PORT=80

EXPOSE 80
ENTRYPOINT ["python3"]
CMD ["/usr/local/endpoint/handler.py"]
