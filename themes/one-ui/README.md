# Tema: One UI (Samsung One UI 7 / 8 Style)

Suite nativa de Rainmeter sin plugins externos inspirada en **Samsung One UI 7 / 8**: tarjetas *squircle* limpias en **OLED Obsidian (Oscuro)** o **Pure Snow (Claro)** con acentos vibrantes, modo **Auto Wallpaper** y barras píldora semánticas.

## Widgets incluidos (`OneUIZen`, 28 widgets)

| Categoría | Widgets |
| :--- | :--- |
| **ThemeSwitcher (1)** | `OneUISwitcher.ini` — Alterna en 1 clic entre **Oscuro (OLED) / Claro (Snow)**, **ES / EN**, **5 acentos Samsung** y modo **Auto (Wallpaper)**. |
| **ProHub (3) — Subsección Productividad & Hardware** | `OneUIBluetoothHub.ini` (dispositivos Bluetooth conectados/emparejados + batería), `OneUIAIUsageHub.ini` (porcentaje de consumo diario de ChatGPT, Claude, Gemini y Grok con iconos HD) y `OneUIStorageVault.ini` (bóveda multi-unidad SSD/USB en vivo). |
| **Clock (5)** | `OneUIFlipClock.ini`, `OneUINowBar.ini` (Now Bar), `OneUIAnalog.ini`, `OneUIDualClock.ini` y `OneUISmartStack.ini` (Smart Widget Stack interactivo de 3 páginas). |
| **Calendar (3)** | `OneUICalendar.ini` (mes completo 6×7), `OneUICalendarStrip.ini` (tira semanal de 7 días con píldora del día actual) y `OneUICountdown.ini` (cuenta regresiva con días restantes). |
| **Productivity (1)** | `OneUIFocus.ini` — Temporizador Pomodoro / Focus de 25 min con anillo circular, inicio/pausa y reinicio. |
| **System (3)** | `OneUIDeviceCare.ini` (4 barras semánticas: Batería, Disco, RAM, CPU), `OneUIStoragePill.ini` y `OneUINetworkMonitor.ini` (tráfico de red en vivo con sparkline dual de 16 barras). |
| **Battery (2)** | `OneUIBatteryPill.ini` (cápsula con rayo vectorial) y `OneUIBatteryCircle.ini` (dial circular con anillo dinámico verde/coral). |
| **Audio (1)** | `OneUIAudioCard.ini` — Volumen vertical táctil + acceso a Bluetooth. |
| **Music (3)** | `OneUIMusicPlayer.ini`, `OneUIMusicCompact.ini` y `OneUICassette.ini` (reproductor Retro Cassette estilo Samsung Good Lock con carretes animados). |
| **Search & AI (3)** | `OneUISearchBar.ini`, `OneUIAiBar.ini` (ChatGPT, Gemini, Claude, Grok, Perplexity) y `OneUIQuickApps.ini` (Google, Gemini, Gmail, Chrome, YouTube, Meet) con iconos oficiales HD. |
| **Notes (2)** | `OneUIReminders.ini` (lista de recordatorios con casillas circulares y botón `+`) y `OneUIQuote.ini` (tarjeta de frase diaria de alto contraste editable al hacer clic). |
| **QuickSettings (1)** | `OneUIQuickPanel.ini` — Panel 2×2 (Wi-Fi, Bluetooth, Audio reactivo y Modo Oscuro/Claro). |

## Pack de iconos (`icons/`, 168 iconos)

Incluye **84 iconos diarios** con la superelipse (*squircle*) oficial de Samsung One UI 7 / 8 en dos variantes (**`oneui-vibrant/`** con degradados de color y **`oneui-dark/`** en OLED Obsidian), cada uno exportado en **PNG (256×256)** e **ICO multirresolución (16–256px)**, listos para el escritorio y **Muelle**:
- **Sistema:** `explorer`, `downloads`, `trash-empty`, `trash-full`, `rainmeter`, `settings`, `notepad`, `7-zip`, `mem-reduct`, `malwarebytes`
- **Navegadores:** `chrome`, `edge`, `firefox`, `brave`, `opera-gx`, `vivaldi`, `zen-browser`, `helium`
- **IA:** `chatgpt`, `claude`, `gemini`, `perplexity`, `notebooklm`, `ai-studio`
- **Dev & Productividad:** `vscode`, `antigravity`, `github`, `git`, `terminal`, `docker`, `python`, `notion`, `obsidian`, `linear`, `figma`, `blender`, `gimp`, `canva`, `word`, `excel`, `powerpoint`, `acrobat`, `dropbox`, `google-drive`, `gmail`, `slack`, `teams`, `zoom`
- **Música, Media & Social:** `spotify`, `youtube-music`, `youtube`, `vlc`, `audacity`, `obs-studio`, `fxsound`, `nvidia`, `netflix`, `twitch`, `discord`, `whatsapp`, `telegram`, `instagram`, `tiktok`, `reddit`
- **Gaming & Optimización:** `steam`, `epic-games`, `riot-client`, `valorant`, `gta-v`, `minecraft`, `roblox`, `cs2`, `league-of-legends`, `fortnite`, `genshin`, `xbox`, `terraria`, `kovaaks`, `repo`, `thunderstore`, `exitlag`, `hone`, `lossless-scaling`, `wallpaper-engine`

### Aplicar los iconos en Muelle (1 clic y reversible)

```powershell
# Variante Vibrant (degradados One UI)
.\scripts\apply-muelle-icons.ps1 -Theme one-ui -Variant vibrant

# Variante OLED Dark (a juego con el modo oscuro)
.\scripts\apply-muelle-icons.ps1 -Theme one-ui -Variant dark

# Restaurar iconos originales de Muelle
.\scripts\apply-muelle-icons.ps1 -Restore
```

## Wallpapers 4K ([`wallpapers/veyra-oneui-wallpapers-4k/`](wallpapers/veyra-oneui-wallpapers-4k/), 36 fondos)

Incluye **36 wallpapers 4K** organizados en [`modo-claro/`](wallpapers/veyra-oneui-wallpapers-4k/modo-claro/) (18) y [`modo-oscuro/`](wallpapers/veyra-oneui-wallpapers-4k/modo-oscuro/) (18) en 6 paletas (Amarillo, Azul, Gris, Rojo, Rosado y Verde) y 3 estilos geométricos (`prisma`, `scurva` y `squircle`), listos para sincronizar con el modo **Auto Wallpaper**.

## Instalación rápida

- **Opción más fácil (1 clic, sin terminal):** descarga y haz doble clic en **[`OneUIZen-v2.rmskin`](../../releases/OneUIZen-v2.rmskin)**.
- **Por PowerShell (desde la raíz de `Veyra-Dots`):**
```powershell
.\scripts\install-rainmeter.ps1 -Theme one-ui
```
