# NixOS для Zenbook

Минимальная flake-конфигурация для ASUS Zenbook 14 OLED UX3405CA-ST1261. Она описывает один хост `zenbook`, одного пользователя `danil`, сессию Niri через greetd и пользовательские настройки через Home Manager.

## Структура

```text
.
├── flake.nix
├── hosts/zenbook/
│   ├── default.nix
│   └── hardware-configuration.nix
├── modules/
│   ├── system/
│   └── home/
├── theme/default.nix
└── config/
    ├── niri/config.kdl
    └── quickshell/
        ├── qmldir
        └── shell.qml
```

`flake.nix` фиксирует `nixpkgs` и Home Manager, создаёт `nixosConfigurations.zenbook` и передаёт обычный attrset `theme` в Home Manager. Системные модули управляют загрузкой, сетью, звуком, локалью, устройствами и login manager. Home Manager-модули управляют только домашним каталогом и пользовательскими программами.

Единый источник цветов, размеров и шрифта находится в `theme/default.nix`. Kitty и тема Helix читают attrset напрямую. Модуль `modules/home/quickshell.nix` умеет генерировать из того же attrset `Theme.qml`, но на время первой установки Quickshell не импортируется, не устанавливается и не запускается автоматически.

Niri остаётся в нативном KDL, а маленькая панель Quickshell — в нативном QML. Так проще сверяться с документацией этих проектов, использовать live reload и не превращать Nix в генератор больших конфигов. Через Nix генерируется только QML-палитра, потому что она должна иметь единый источник.

## Перед первой установкой

Файл `hosts/zenbook/hardware-configuration.nix` — безопасная пустая заглушка. Она позволяет вычислять flake, но **не описывает диски, корневую файловую систему и initrd конкретного ноутбука**. На установочном носителе сначала разметьте и смонтируйте диски в `/mnt`, затем выполните:

```console
sudo nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/zenbook/hardware-configuration.nix
sudo nixos-install --flake .#zenbook
```

Команду `cp` запускайте из корня этого репозитория. До первого входа задайте пароль пользователю `danil`; пароль и его hash намеренно не хранятся в Git. После `nixos-install`, пока `/mnt` ещё смонтирован, можно выполнить:

```console
sudo nixos-enter --root /mnt -c 'passwd danil'
```

После загрузки разместите репозиторий в ожидаемом alias-пути:

```console
mv /путь/к/репозиторию ~/nixos-config
```

Если выбран другой путь, измените только константу `flakeDir` в `modules/home/zsh.nix`.

## Обычная работа

Применить изменения:

```console
sudo nixos-rebuild switch --flake ~/nixos-config#zenbook
```

Обновить зафиксированные входы:

```console
nix flake update ~/nixos-config
```

Команда создаёт `flake.lock`, если его ещё нет, либо обновляет существующий lock-файл. После успешной проверки его следует сохранить в Git.

Проверить до применения:

```console
nix flake check ~/nixos-config
nix build ~/nixos-config#nixosConfigurations.zenbook.config.system.build.toplevel
niri validate
```

Для отката выберите старое поколение в меню systemd-boot или выполните:

```console
sudo nixos-rebuild switch --rollback
```

## Что намеренно оставлено минимальным

Здесь нет файловых систем, разметки диска, Secure Boot, secrets management, контейнеров и игровых настроек. Quickshell временно отключён; его минимальная QML-заготовка сохранена для последующего включения. Здесь также нет notification daemon, tray, Wi-Fi applet или полноценного desktop shell. Специальные параметры ядра для модели ноутбука не добавлены без подтверждённой необходимости. При желании эти части лучше добавлять отдельными небольшими модулями после проверки оборудования.

Раскладки Niri: US, немецкая и украинская; переключение — `Super+Space`. Основные сочетания находятся в `config/niri/config.kdl`.
