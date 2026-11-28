# Tema: Glass / Mica (Liquid Glass & Frosted Ice v2.0)

Suite nativa de Rainmeter 100% Direct2D sin plugins externos inspirada en **Liquid Glass & Windows 11 Frosted Ice**: tarjetas translúcidas con borde especular diagonal, 3 modos (**Smoked Glass**, **Frosted Ice** y **Liquid Crystal**) y **6 acentos Fluent + Auto Wallpaper**.

## Widgets incluidos (`GlassZen`, 24 widgets)

| Categoría | Widgets |
| :--- | :--- |
| **ThemeSwitcher (1)** | `GlassSwitcher.ini` — Alterna en 1 clic entre **Smoked / Ice / Crystal**, **ES / EN**, **6 acentos Fluent** (`IceBlue`, `MintGlass`, `Lavender`, `Sunset`, `Rose`, `Graphite`) y **Auto Wallpaper**. |
| **ProHub (3) — Hardware & IA** | `GlassBluetoothHub.ini` (dispositivos Bluetooth en vivo + batería), `GlassAIUsageHub.ini` (cuota diaria de ChatGPT, Claude, Gemini y Grok con scroll) y `GlassStorageVault.ini` (bóveda SSD/NVMe/USB). |
| **Clock (5)** | `GlassClockHero.ini`, `GlassFlipClock.ini`, `GlassAnalog.ini` (dial Direct2D de 60 marcas), `GlassWorldClock.ini` y `GlassSolarArc.ini` (arco orbital solar/lunar). |
| **Calendar (3)** | `GlassCalendar.ini` (matriz 6×7), `GlassWeekStrip.ini` (tira semanal de 5 días) y `GlassCountdown.ini` (cuenta regresiva configurable). |
| **System (3)** | `GlassSystemTiles.ini` (cuadrícula 2×2 CPU/RAM/C:/Bat), `GlassNetworkPulse.ini` (sparkline de red en vivo) y `GlassStorageBar.ini`. |
| **Battery & Audio (3)** | `GlassBatteryPill.ini`, `GlassBatteryRing.ini` (anillo Direct2D luminoso) y `GlassAudioCard.ini` (volumen táctil y silencio seguro). |
| **Music & Focus (3)** | `GlassMusicCard.ini`, `GlassMusicMini.ini` y `GlassFocus.ini` (Pomodoro circular Direct2D de 25 min). |
| **Search & Notes (3)** | `GlassLauncher.ini` (búsqueda web), `GlassAiDock.ini` (5 asistentes de IA HD) y `GlassReminders.ini` (lista interactiva con botón `+`). |

## Packs de iconos (`168 iconos` — Oscuro y Claro)

Incluye **2 variantes completas de 84 iconos** estilo **Frosted Ice** en **PNG (256×256)** e **ICO multirresolución (16–256px)** para Escritorio, Barra de Tareas y **Muelle**:
- **Frosted Ice Oscuro (`icons/glass-frosted/`):** vidrio translúcido con glifos blancos luminosos para fondos oscuros.
- **Frosted Ice Claro (`icons/glass-frosted-light/`):** vidrio blanco hielo esmerilado con glifos grafito profundo para fondos claros.

| Frosted Ice — Oscuro (84) | Frosted Ice — Claro (84) |
| :---: | :---: |
| ![Iconos Glass Frosted Oscuro](icons/preview.png) | ![Iconos Glass Frosted Claro](icons/preview-light.png) |

## Wallpapers compatibles (4K)

Todos los fondos 4K del repositorio se sincronizan en 1 clic mediante el botón **Auto** de `GlassSwitcher`:
- **[Wallpapers One UI 4K (`36 fondos` — Claro y Oscuro)](../one-ui/wallpapers/veyra-oneui-wallpapers-4k/)**
- **[Wallpapers Material You 4K (`23 fondos`)](../material-you/wallpapers/)**

## Instalación rápida

- **Opción más fácil (1 clic, sin terminal):** descarga y haz doble clic en **[`GlassZen-v2.rmskin`](../../releases/GlassZen-v2.rmskin)**.
- **Por PowerShell (desde la raíz de `Veyra-Dots`):**
```powershell
.\scripts\install-rainmeter.ps1 -Theme glass
```
