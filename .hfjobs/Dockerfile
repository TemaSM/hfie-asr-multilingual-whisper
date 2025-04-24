FROM python:3.12

ENV ENDPOINT_API_KEY="undefined"
ARG ENDPOINT_URL="http://host.docker.internal:8000"
ARG ENDPOINT_NUM_SAMPLES=50
ARG ENDPOINT_TEST_SEED=31415926

ENV NUMBA_CACHE_DIR=/tmp/numba
ENV HF_HOME=/tmp/huggingface

ENV ENDPOINT_URL=$ENDPOINT_URL
ENV ENDPOINT_NUM_SAMPLES=$ENDPOINT_NUM_SAMPLES
ENV ENDPOINT_TEST_SEED=$ENDPOINT_TEST_SEED

RUN --mount=type=bind,source=.hfjobs/requirements.txt,target=/opt/endpoint/tests/requirements.txt \
    python -m pip install -r /opt/endpoint/tests/requirements.txt

WORKDIR /opt/endpoint
COPY tests/ tests/.

ENTRYPOINT ["pytest"]
CMD ["-p", "no:cacheprovider", "--import-mode", "importlib", "tests"]