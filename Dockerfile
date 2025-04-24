ARG SDK_VERSION=latest
FROM huggingface/hfendpoints-sdk:${SDK_VERSION} AS sdk

FROM vllm/vllm-openai:v0.8.4
RUN --mount=type=bind,from=sdk,source=/opt/hfendpoints/dist,target=/usr/local/endpoints/dist \
    --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    python3 -m pip install -r /tmp/requirements.txt && \
    python3 -m pip install /usr/local/endpoints/dist/*.whl

COPY handler.py /usr/local/endpoint/

ENV INTERFACE=0.0.0.0
ENV PORT=80

EXPOSE 80
ENTRYPOINT ["python3"]
CMD ["/usr/local/endpoint/handler.py"]
