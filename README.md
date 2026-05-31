# Rosa Linux для Napi-C (RK3308)

Сборка образа Rosa Linux 13 для платы [Napi-C](https://napilab.ru) на базе SoC Rockchip RK3308.

## Быстрый старт

```bash
# Запустить контейнер сборки
docker run -it --privileged --name rosa-builder \
    -v ~/d400/rosa-data:/work rosalab/rosa13 bash

cd /work/image-builder/device/rockchip/napi-c
bash build.sh
```

Готовый образ появится в `output/images/rosa_napic_DDMMM-HHMM-vendor_611.img.xz`.

Прошивка на карту:
```bash
xz -d rosa_napic_*.img.xz
dd if=rosa_napic_*.img of=/dev/sdX bs=4M status=progress
```

## Структура проекта

```
napi-c/
├── build.sh                  # Обёртка сборки с именованием образа
├── mkosi.conf                # Конфигурация mkosi
├── mkosi.extra/              # Файлы, добавляемые в образ
│   ├── boot/boot.cmd         # U-Boot boot script
│   ├── etc/
│   │   ├── profile.d/term.sh         # TERM=linux для корректной консоли
│   │   ├── ssh/sshd_config           # (изменён через postinst)
│   │   └── systemd/system/
│   │       └── napi-mac.service      # Сервис персистентного MAC
│   └── usr/local/bin/
│       └── napi-set-mac.sh           # Скрипт генерации MAC
├── mkosi.postinst.chroot     # Скрипт настройки внутри chroot
├── mkosi.finalize.d/         # Скрипты финализации образа
│   └── 10-bar.sh.finalyze   # Включение сервисов
├── mkosi.postoutput.d/       # Скрипты после создания образа
│   └── 10-bar.sh.finalyze   # Запись U-Boot в образ
├── mkosi.repart/             # Разметка разделов
└── mkosi/                    # Бинарники U-Boot
    ├── idbloader.bin
    ├── uboot.img
    └── trust.bin
```

## Изменения относительно стандартной сборки Rosa

### 1. Ядро и DTB

- Добавлен `rk3308-napi-c.dtb` в пакет `kernel-6.1-rockchip`
- Исправлен `compatible` в узле GMAC: `rockchip,rk3308-gmac` (вместо неверного значения)
- DTB пересобирается из исходников Rosa-ядра

### 2. U-Boot

Используется mainline U-Boot 2023.10 с патчами для Napi-C. Записывается в образ через `mkosi.postoutput.d/`:

| Файл           | Смещение (секторы 512B) | Смещение      |
|----------------|------------------------|---------------|
| idbloader.bin  | seek=64                | 32 KB         |
| uboot.img      | seek=16384             | 8 MB          |
| trust.bin      | seek=24576             | 12 MB         |

BL31: версия v2.27 (v2.26 давал SMC-ошибки на RK3308).

### 3. Загрузчик (boot.cmd)

- `distro_bootpart=2` — правильный раздел для поиска boot-файлов
- `loglevel=3 audit=0` — уменьшение шума в консоли
- `rockchip.smc_bug_skip=1` — обход SMC-ошибок BL31

### 4. Персистентный MAC-адрес

Стандартный stmmac генерирует случайный MAC при каждой загрузке. Реализован сервис `napi-mac.service`:

- При первом запуске генерирует случайный locally-administered unicast MAC
- Сохраняет в `/etc/napi-mac`
- При следующих загрузках использует сохранённый MAC
- Запускается до `network.target`

### 5. SSH

- `PermitRootLogin yes` в `sshd_config`
- Удалён `root` из `/etc/ssh/denyusers` (в стандартном образе Rosa root заблокирован)

### 6. Пользователи

| Пользователь | Пароль    | Группы        |
|--------------|-----------|---------------|
| root         | root      | —             |
| napi         | napilinux | wheel         |

### 7. Консоль

- `TERM=linux` в `/etc/profile.d/term.sh` — корректное отображение в minicom/picocom
- `unset PROMPT_COMMAND` — убирает escape-последовательности xterm из промпта

### 8. Сборочный скрипт

`build.sh` — обёртка над `mkosi --force`:

- Формирует имя образа в стиле Armbian: `rosa_napic_DDMon-HHMM-vendor_611.img.xz`
- Сохраняет в `output/images/`
- Сжимает через `xz -T0` (все ядра)

## Параметры по умолчанию

| Параметр     | Значение              |
|--------------|-----------------------|
| Дистрибутив  | Rosa Linux 13         |
| Ядро         | kernel-6.1-rockchip   |
| Архитектура  | arm64                 |
| Hostname     | napi-c                |
| Timezone     | Europe/Moscow         |
| Locale       | en_US.UTF-8           |
| Консоль      | ttyS0, 1500000 baud   |
| Корневой ФС  | ext4                  |
