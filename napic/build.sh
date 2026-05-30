#!/bin/bash

if [ -z "$BASH_VERSION" ]; then
    echo "ERROR: запускай через bash: bash build.sh" >&2
    exit 1
fi

set -e

DISTRO=rosa
BOARD=napic
KERNEL=vendor_611
OUTDIR=output/images

DATE=$(date +%d%b)
TIME=$(date +%H%M)
NAME="${DISTRO}_${BOARD}_${DATE}-${TIME}-${KERNEL}"

mkdir -p "$OUTDIR"

echo "=== Building ${NAME} ==="
mkosi --force --output image

echo "=== Packing ==="
xz -T0 -kf image.raw
mv image.raw.xz "${OUTDIR}/${NAME}.img.xz"

echo "=== Done ==="
ls -lh "${OUTDIR}/${NAME}.img.xz"
