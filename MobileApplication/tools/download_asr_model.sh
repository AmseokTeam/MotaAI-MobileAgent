#!/usr/bin/env bash
set -euo pipefail

MODEL_NAME="sherpa-onnx-streaming-paraformer-bilingual-zh-en"
MODEL_BASE_URL="https://huggingface.co/csukuangfj/${MODEL_NAME}/resolve/main"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_DIR="${PROJECT_ROOT}/assets/asr_models/${MODEL_NAME}"
FILES=(
  "encoder.int8.onnx"
  "decoder.int8.onnx"
  "tokens.txt"
)

mkdir -p "${MODEL_DIR}"

download_file() {
  local filename="$1"
  local target="${MODEL_DIR}/${filename}"
  local url="${MODEL_BASE_URL}/${filename}"

  if [[ -s "${target}" ]]; then
    echo "exists: ${target}"
    return
  fi

  local partial="${target}.part"
  rm -f "${partial}"

  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 -o "${partial}" "${url}"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "${partial}" "${url}"
  else
    echo "curl or wget is required to download ${url}" >&2
    exit 1
  fi

  mv "${partial}" "${target}"
}

for filename in "${FILES[@]}"; do
  download_file "${filename}"
done

for filename in "${FILES[@]}"; do
  if [[ ! -s "${MODEL_DIR}/${filename}" ]]; then
    echo "Downloaded model is missing required file: ${MODEL_DIR}/${filename}" >&2
    exit 1
  fi
done

echo "ASR model ready: ${MODEL_DIR}"
echo "These files are ignored by git and are bundled only in local builds that include assets/asr_models/."
