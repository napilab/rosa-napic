setenv fdtfile "dtbs/rockchip/rk3308-napi-c.dtb"
setenv bootargs "root=/dev/mmcblk1p3 rw rootwait rootfstype=ext4 console=ttyS0,1500000 console=tty1 consoleblank=0 loglevel=7 rockchip.smc_bug_skip=1 earlycon=uart8250,mmio32,0xff0a0000 cma=256M"
setenv distro_bootpart 2
echo "Boot script loaded from ${devtype} ${devnum}:${distro_bootpart}"
load ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} ${prefix}INITRD_REPLACE
load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} ${prefix}IMAGE_REPLACE
load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${prefix}${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536
printenv bootargs
printenv fdtfile
booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
