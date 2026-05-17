#!/bin/bash
fastboot devices && \
fastboot flash ram 20260504/u-boot-with-spl-lcon4a-16g.bin && \
fastboot reboot && \
fastboot flash uboot 20260504/u-boot-with-spl-lcon4a-16g.bin && \
fastboot flash boot 20260504/boot-console-20260504_080608.ext4 && \
fastboot flash root 20260504/root-console-20260504_080608.ext4 && \
fastboot reboot && \
echo 'ok'

