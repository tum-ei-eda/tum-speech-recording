#!/bin/bash
#
# Copyright (C) 2022 Chair of Electronic Design Automation, TUM.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the License); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RECORDINGS_DIR="${SCRIPT_DIR}/recordings"

RAW_DIR_ENDING="-raw"
WAV_DIR_ENDING="-wav"
PROCESSED_DIR_ENDING="-clean"


echo -e "##### Converting to .wav"

for dir in ${RECORDINGS_DIR}/*
do
  if [[ ${dir} == *${RAW_DIR_ENDING} ]]; then
    echo -e "##### Converting files from ${dir} to ${dir%${RAW_DIR_ENDING}}${WAV_DIR_ENDING}"
    rm -rf ${dir%${RAW_DIR_ENDING}}${WAV_DIR_ENDING}
    mkdir ${dir%${RAW_DIR_ENDING}}${WAV_DIR_ENDING}
    cd ${dir}
    find . -iname "*.ogg" -print0 | xargs -0 basename -s .ogg | xargs -I {} ffmpeg -i {}.ogg -ar 16000 ${dir%${RAW_DIR_ENDING}}${WAV_DIR_ENDING}/{}.wav
  fi
done


echo -e "##### Postprocessing wavs"

POSTPROCESS_DIR="${SCRIPT_DIR}/extract_loudest_section"
POSTPROCESS_BIN="${POSTPROCESS_DIR}/build/bin/extract_loudest_section"

cd ${POSTPROCESS_DIR}
make clean all

for dir in ${RECORDINGS_DIR}/*
do
  if [[ ${dir} == *${WAV_DIR_ENDING} ]]; then
    echo -e "##### Postprocessing files from ${dir} to ${dir%${WAV_DIR_ENDING}}${PROCESSED_DIR_ENDING}"
    rm -rf ${dir%${WAV_DIR_ENDING}}${PROCESSED_DIR_ENDING}
    mkdir ${dir%${WAV_DIR_ENDING}}${PROCESSED_DIR_ENDING}
    ${POSTPROCESS_BIN} "${dir}/*.wav" "${dir%${WAV_DIR_ENDING}}${PROCESSED_DIR_ENDING}"
  fi
done


DATE=$(date +"%F-%I-%M-%S")
ZIP_FILE="speech-data-${DATE}.zip"

echo -e "##### Zipping files into ${ZIP_FILE}"

cd ${RECORDINGS_DIR}
TMP_DIR=${RECORDINGS_DIR}/tmp
rm -rf ${TMP_DIR}
mkdir ${TMP_DIR}

for dir in ${RECORDINGS_DIR}/*
do
  if [[ ${dir} == *${PROCESSED_DIR_ENDING} ]] &&
   ! [[ ${dir} == *${WAV_DIR_ENDING} ]] &&
   ! [[ ${dir} == *${RAW_DIR_ENDING} ]] &&
   ! [[ ${dir} == *tmp ]]; then
    new_dir=${TMP_DIR}/$(basename ${dir%${PROCESSED_DIR_ENDING}})
    echo -e "##### Moving ${dir} to ${new_dir}"
    cp -r ${dir} ${new_dir}
  fi
done
cd ${TMP_DIR}
zip -r "../${ZIP_FILE}" *
# unzip -l "../${ZIP_FILE}"
rm -rf ${TMP_DIR}

echo -e "##### Created recordings zipfile ${ZIP_FILE}"
