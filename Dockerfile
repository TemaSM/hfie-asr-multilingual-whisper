FROM vllm/vllm-openai:v0.8.4

RUN --mount=type=bind,from=huggingface/endpoints-sdk:v1.0.0-beta-py312-manylinux,source=/opt/endpoints/dist,target=/opt/endpoints/dist \
    --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    python3 -m pip install -r /tmp/requirements.txt && \
    python3 -m pip install /opt/endpoints/dist/*.whl

COPY handler.py /opt/endpoints/

ENV HFENDPOINT_INTERFACE=0.0.0.0
ENV HFENDPOINT_PORT=80

EXPOSE 80
ENTRYPOINT ["python3"]
CMD ["/opt/endpoints/handler.py"]
