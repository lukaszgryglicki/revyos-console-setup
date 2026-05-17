Lichee Console 4A:
0) sudo
1) Get the u-boot YYYY-MM-DD from: https://fast-mirror.isrc.ac.cn/revyos/extra/images/lcon4a/20260504/
    - wget https://fast-mirror.isrc.ac.cn/revyos/extra/images/lcon4a/20260504/u-boot-with-spl-lcon4a-16g.bin
    - wget https://fast-mirror.isrc.ac.cn/revyos/extra/images/lcon4a/20260504/boot-console-20260504_080608.ext4.zst
    - wget https://fast-mirror.isrc.ac.cn/revyos/extra/images/lcon4a/20260504/root-console-20260504_080608.ext4.zst
2) Some instructions here: https://wiki.sipeed.com/hardware/en/lichee/th1520/lcon4a/4_burn_image.html
3) zstd -d file.zst ...
4) Open the NVMe bay; the BOOT (and RST) buttons are inside that compartment.
5) Hold BOOT, then press the laptop’s power button to enter fastboot. Keep power button until fan starts but before audible click that resets (not too long). Keep BOOT pressed longer until you already release power.
6) On your host PC, lsusb should show: ID 2345:7654 T-HEAD USB download gadget. Known config is: USB-C on RV64 and USB-B on tuxi (the faster port).
7) fastboot flash ram u-boot-with-spl-lcon4a-16g.bin
8) fastboot reboot
9) fastboot flash uboot u-boot-with-spl-lcon4a-16g.bin
10) fastboot flash boot boot-console-20260504_080608.ext4
11) fastboot flash root root-console-20260504_080608.ext4
12) After flashing, boot the machine. Default accounts used by RevyOS images for Console 4A are: sipeed / licheepi, debian / debian, (root has no password)

--

ALT: copy root & boot files onto SD card, boot Lichee, dd them out into root & boot partitions:
sudo dd if=/mnt/usb/boot-console-20251115_072637.ext4 of=/dev/mmcblk0p1 bs=4M conv=fsync
sudo dd if=/mnt/usb/root-console-20251115_072637.ext4 of=/dev/mmcblk0p2 bs=4M conv=fsync
sync

DisK:

By default the internal SSD disk on M.2 slot on the Lichee Console 4A (an ASMedia USB↔SATA bridge 174c:1153 ASM1153) is not working, fix it via:
```
cat >/usr/local/sbin/lcon4a-ssd-power-cycle.sh <<'EOF'
#!/bin/sh
set -eu

GPIO=679
GPIOPATH="/sys/class/gpio/gpio${GPIO}"

[ -d "$GPIOPATH" ] || echo "$GPIO" > /sys/class/gpio/export

echo out > "$GPIOPATH/direction"
echo 0 > "$GPIOPATH/value"
sleep 1
echo 1 > "$GPIOPATH/value"

# give USB/SATA bridge time to enumerate
sleep 5

exit 0
EOF

chmod +x /usr/local/sbin/lcon4a-ssd-power-cycle.sh


cat >/etc/systemd/system/lcon4a-ssd-power-cycle.service <<'EOF'
[Unit]
Description=Power-cycle Lichee Console 4A internal SATA SSD bridge
DefaultDependencies=no
After=sysinit.target
Before=local-fs-pre.target
Wants=local-fs-pre.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/lcon4a-ssd-power-cycle.sh
RemainAfterExit=yes

[Install]
WantedBy=local-fs-pre.target
EOF

systemctl daemon-reload
systemctl enable lcon4a-ssd-power-cycle.service


systemctl start lcon4a-ssd-power-cycle.service
sleep 5
lsusb | grep -i '174c:1153\|asmedia'
lsblk


reboot


systemctl status lcon4a-ssd-power-cycle.service --no-pager
lsusb | grep -i '174c:1153\|asmedia'
lsblk

```
