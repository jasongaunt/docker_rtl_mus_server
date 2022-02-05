#!/usr/bin/env bash

# Trap ctrl+c so we can clean up background tasks
trap "clean_exit" INT TERM ERR EXIT
clean_exit() {
	echo "Exit called, cleaning up..."
	pkill -P $$
}

# Default values - do not edit these, read instructions on how to set these when launching the container
DEVICE_INDEX=0
DEVICE_SAMPLE_RATE=2400000
DEVICE_PPM=0
DEVICE_GAIN=0
DEVICE_BIAS_TEE_ENABLE=0
DEVICE_BUFFERS=15
DEVICE_LINKED_LIST_BUFFERS=500

# Read in our environment variables
[[ ! -z "${RTL_DEVICE_INDEX}" ]]               && DEVICE_INDEX="${RTL_DEVICE_INDEX}"
[[ ! -z "${RTL_DEVICE_SAMPLE_RATE}" ]]         && DEVICE_SAMPLE_RATE="${RTL_DEVICE_SAMPLE_RATE}"
[[ ! -z "${RTL_DEVICE_PPM}" ]]                 && DEVICE_PPM="${RTL_DEVICE_PPM}"
[[ ! -z "${RTL_DEVICE_GAIN}" ]]                && DEVICE_GAIN="${RTL_DEVICE_GAIN}"
[[ ! -z "${RTL_DEVICE_BIAS_TEE_ENABLE}" ]]     && DEVICE_BIAS_TEE_ENABLE="${RTL_DEVICE_BIAS_TEE_ENABLE}"
[[ ! -z "${RTL_DEVICE_BUFFERS}" ]]             && DEVICE_BUFFERS="${RTL_DEVICE_BUFFERS}"
[[ ! -z "${RTL_DEVICE_LINKED_LIST_BUFFERS}" ]] && DEVICE_LINKED_LIST_BUFFERS="${RTL_DEVICE_LINKED_LIST_BUFFERS}"

# Start RTL_TCP
echo "Creating service for device ${DEVICE_INDEX} with the following settings:"
echo "  Sample Rate:    ${DEVICE_SAMPLE_RATE}"
echo "  PPM:            ${DEVICE_PPM}"
echo "  Gain:           ${DEVICE_GAIN}"
echo "  Port:           ${DEVICE_PORT}"
echo "  Bias Tee:       ${DEVICE_BIAS_TEE_ENABLE}"
echo "  Buffers:        ${DEVICE_BUFFERS}"
echo "  Linked Lists:   ${DEVICE_LINKED_LIST_BUFFERS}"

rtl_tcp \
	-d "${DEVICE_INDEX}" \
	-b "${DEVICE_BUFFERS}" \
	-n "${DEVICE_LINKED_LIST_BUFFERS}" \
	-s "${DEVICE_SAMPLE_RATE}" \
	-P "${DEVICE_PPM}" \
	-g "${DEVICE_GAIN}" \
	$([[ "${DEVICE_BIAS_TEE_ENABLE}" == "1" ]] && echo -n "-T") &

# Start RTL Multi-User Service
cd /root/rtl_mus/
sleep 2
./rtl_mus.py config_rtl &

# Wait here for background processes to end
wait
echo "RTL MUS script ended"
