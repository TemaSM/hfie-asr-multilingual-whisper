FROM python:3.12

ENV ENDPOINT_API_KEY="undefined"
ARG ENDPOINT_URL="http://host.docker.internal:8000"
ARG ENDPOINT_NUM_SAMPLES=50
ARG ENDPOINT_TEST_SEED=31415926

RUN --mount=type=bind,source=.hfjobs/requirements.txt,target=/opt/endpoint/tests/requirements.txt \
    python -m pip install -r /opt/endpoint/tests/requirements.txt

WORKDIR /opt/endpoint
COPY tests/ tests/.

ENTRYPOINT ["pytest"]
CMD ["-v", "--import-mode", "importlib", "tests"]