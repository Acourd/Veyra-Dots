# Tema: Nothing OS (Dot-Matrix Hardware Style)

Suite nativa de Rainmeter sin plugins externos inspirada en **Nothing OS**: reloj matricial LED **5×7 real** (`DotClock.lua`), matriz de batería de **50 puntos**, reproductor **Vinyl Disc**, contraste extremo **OLED Black / Chalk Paper** y acento **Nothing Crimson Red**.

## Widgets incluidos (`NothingZen`, 24 widgets)

| Categoría | Widgets |
| :--- | :--- |
| **ThemeSwitcher (1)** | `NothingSwitcher.ini` — Alterna en 1 clic entre **OLED (Oscuro) / Papel (Claro)**, **ES / EN**, **5 acentos** (`Red`, `Amber`, `Cyan`, `Matrix`, `Mono`), **12H/24H** y **Auto Sync**. |
| **ProHub (3) — Telemetría & IA** | `NothingBluetoothHub.ini` (dispositivos BT en vivo), `NothingAIUsageHub.ini` (cuota IA con barras técnicas) y `NothingStorageVault.ini` (bóveda SSD/NVMe/USB). |
| **Clock (4)** | `NothingDotClock.ini` (reloj matriz LED 5×7 auténtico), `NothingAnalog.ini` (esfera con segundero carmesí), `NothingWorldClock.ini` y `NothingSolarGlyph.ini` (arco orbital). |
| **Calendar (3)** | `NothingCalendar.ini` (calendario industrial 6×7), `NothingWeekStrip.ini` (tira semanal 5 días) y `NothingCountdown.ini`. |
| **System (3)** | `NothingTelemetry.ini` (cuadrícula CPU/RAM/C:/Bat), `NothingNetworkPulse.ini` (pulso RX/TX) y `NothingStorageBar.ini`. |
| **Battery & Audio (3)** | `NothingBatteryDots.ini` (matriz LED de 50 puntos), `NothingBatteryRing.ini` y `NothingAudioCard.ini`. |
| **Music & Focus (3)** | `NothingVinylPlayer.ini` (tocadiscos disco vinilo), `NothingMusicMini.ini` y `NothingFocus.ini` (Pomodoro técnico). |
| **Search & Notes (4)** | `NothingSearchBar.ini`, `NothingQuickApps.ini`, `NothingAiMatrix.ini` y `NothingReminders.ini`. |

## Pack de iconos (`icons/nothing-mono/`, 84 iconos)

Incluye **84 iconos** monocromáticos OLED con detalles **Nothing Crimson Red** exportados en **PNG (256×256)** e **ICO multirresolución (16–256px)** para Escritorio, Barra de Tareas y **Muelle**, cubriendo navegadores, juegos, productividad, música/redes, IA y sistema.

![Iconos Nothing OS](icons/preview.png)

## Wallpapers compatibles (4K)

Todos los fondos del repositorio son compatibles y se sincronizan en 1 clic con **Auto Sync** desde `NothingSwitcher`:
- **[Wallpapers One UI 4K (`36 fondos` — Claro y Oscuro)](../one-ui/wallpapers/veyra-oneui-wallpapers-4k/)**
- **[Wallpapers Material You 4K (`23 fondos`)](../material-you/wallpapers/)**

## Instalación rápida

- **Opción más fácil (1 clic, sin terminal):** descarga y haz doble clic en **[`NothingZen-v2.rmskin`](../../releases/NothingZen-v2.rmskin)**.
- **Por PowerShell (desde la raíz de `Veyra-Dots`):**
```powershell
.\scripts\install-rainmeter.ps1 -Theme nothing
```
