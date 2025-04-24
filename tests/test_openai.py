from io import BytesIO
from os import environ
from random import seed

import numpy as np
import soundfile as sf
import pytest

# Global variables defining endpoint targets
ENDPOINT_URL = environ["ENDPOINT_URL"]
ENDPOINT_NUM_SAMPLES = int(environ["ENDPOINT_NUM_SAMPLES"])
ENDPOINT_TEST_SEED = int(environ["ENDPOINT_TEST_SEED"])

# Seed all the rngs
seed(ENDPOINT_TEST_SEED)
np.random.seed(ENDPOINT_TEST_SEED)

from datasets import load_dataset, Dataset
from openai import OpenAI

# Global client to make requests
client = OpenAI(base_url=ENDPOINT_URL)


@pytest.fixture
def dataset():
    dataset = load_dataset("hf-audio/esb-datasets-test-only-sorted", "ami", split="test")
    return dataset.take(ENDPOINT_NUM_SAMPLES)


@pytest.mark.parametrize("response_format", ["text", "json", "verbose_json"])
def test_seq_openai_client_no_params(dataset: Dataset, response_format: str):
    try:
        for sample in dataset:
            with BytesIO() as audio_buffer:
                sf.write(audio_buffer, sample["audio"]["array"], sample["audio"]["sampling_rate"], format="WAV")
                response = client.audio.transcriptions.create(
                    file=audio_buffer, model="whisper-1", response_format=response_format
                )

                if response_format == "verbose_json":
                    assert len(response.segments), "No segments returned"
                    assert all(map(lambda s: s.avg_logprob != float('nan'), response.segments)), "avg_logprob is NaN"
                    assert all(
                        map(lambda s: s.compression_ratio != float('nan'), response.segments)), "avg_logprob is NaN"
                    assert all(map(lambda s: s.temperature == 0.0, response.segments)), "temperature not equals 0.0"

    except Exception as e:
        assert False, f"Caught error while sending audio/transcriptions request: {e}"


@pytest.mark.parametrize("response_format", ["text", "json", "verbose_json"])
def test_seq_openai_client_temperature(dataset: Dataset, response_format: str):
    try:
        for sample in dataset:
            with BytesIO() as audio_buffer:
                sf.write(audio_buffer, sample["audio"]["array"], sample["audio"]["sampling_rate"], format="WAV")
                response = client.audio.transcriptions.create(
                    file=audio_buffer,
                    model="whisper-1",
                    temperature=1.0,
                    response_format=response_format
                )

                if response_format == "verbose_json":
                    assert len(response.segments), "No segments returned"
                    assert all(map(lambda s: s.avg_logprob != float('nan'), response.segments)), "avg_logprob is NaN"
                    assert all(
                        map(lambda s: s.compression_ratio != float('nan'), response.segments)), "avg_logprob is NaN"
                    assert all(map(lambda s: s.temperature == 1.0, response.segments)), "temperature not equals 1.0"

    except Exception as e:
        assert False, f"Caught error while sending audio/transcriptions request: {e}"
