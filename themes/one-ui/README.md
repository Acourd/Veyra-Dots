# Tema: One UI (Samsung One UI 7 / 8 Style)

Suite nativa de Rainmeter sin plugins externos inspirada en **Samsung One UI 7 / 8**: tarjetas *squircle* limpias en **OLED Obsidian (Oscuro)** o **Pure Snow (Claro)** con acentos vibrantes, modo **Auto Wallpaper** y barras píldora semánticas.

## Widgets incluidos (`OneUIZen`, 54 widgets)

| Categoría | Widgets |
| :--- | :--- |
| **ThemeSwitcher (1)** | `OneUISwitcher.ini` — Alterna en 1 clic entre **Oscuro (OLED) / Claro (Snow)**, **ES / EN**, **5 acentos Samsung** y modo **Auto (Wallpaper)**. |
| **ProHub (3)** | `OneUIBluetoothHub.ini` muestra el estado que informa Windows y la batería cuando está disponible. `OneUIAIUsageHub.ini` cuenta accesos diarios desde los widgets de IA. `OneUIStorageVault.ini` muestra las unidades SSD y USB. |
| **Clock (10)** | Relojes Línea, Baldosa, Columna, Dueto, Pulso y Escritorio junto con Analógico, Dual, Now Bar y Smart Stack. |
| **Calendar (6)** | Mes, tira semanal, cuenta regresiva, agenda local, fecha en píldora y tarjeta Hoy. |
| **Productivity (3)** | Temporizador, Modos de enfoque con sesiones de 25 o 50 minutos y un descanso de 10, y Hábitos diarios. |
| **System (4)** | Device Care en cuadrícula, Device Care clásico con cuatro barras horizontales, almacenamiento y monitor de red. |
| **Battery (4)** | `OneUIBatteryPill.ini`, `OneUIBatteryCircle.ini`, `OneUIBatteryEnergy.ini` (alimentación y autonomía disponible) y `OneUIBatteryTrend.ini` (historial de quince minutos). |
| **Audio (5)** | Sonido, salida, preajustes de volumen (15, 35 y 65 %), controles multimedia de Windows y deslizador. |
| **Music (4)** | `OneUIMusicPlayer.ini`, `OneUIMusicCompact.ini`, `OneUICassette.ini` y `OneUIMediaPanel.ini` (pista, progreso y controles). |
| **Search (2)** | Barra de búsqueda con accesos a Gemini, YouTube y Gmail, y Finder con web, YouTube y Wikipedia. |
| **Shortcuts (5)** | Accesos rápidos, combos Social, Google e IA, y un lanzador de herramientas de Windows. |
| **Notes (3)** | `OneUIReminders.ini`, `OneUIQuote.ini` y `OneUINoteCard.ini` (Cuaderno para recorrer las notas por clic o rueda). |
| **QuickSettings (4)** | Panel de ajustes, barra de seis controles y dos widgets seleccionables mediante la rueda o el menú. |

Los botones de sonido y tema actúan desde el widget. Los accesos de red, notificaciones y pantalla abren su página en Ajustes de Windows. En Combo IA, el menú contextual abre el borrador local. Usa Shortcuts y Search a la vez para tener un lanzador junto al buscador. En Sonido y Deslizador, pulsa el altavoz para silenciar o la pista para ajustar el nivel.

AI Bar, Search Bar y Device Care clásico usan los fondos y el contraste recuperados de Alpha. El selector de tema de OneUIZen cambia también su modo y acento.

Para añadir citas, abre **Editar** en Agenda y escribe una por `EventN` en `@Resources/Agenda.inc` con el formato `AAAA-MM-DD|HH:MM|Título`. Pulsa **↻** en el widget después de guardar.

La tarjeta de energía muestra la autonomía cuando Windows la informa. Tendencia toma una muestra cada 15 segundos y comienza a registrar al cargar el widget.

En Rainmeter, cada categoría admite una variante activa a la vez. En Hábitos diarios, el menú contextual permite editar los cuatro nombres o reiniciar el día. El estado se guarda en `@Resources/Habits.inc` y se reinicia al cambiar la fecha local. Los controles de IA contabilizan aperturas hechas desde la barra o el panel, con reinicio al cambiar de día.

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
  En una instalación nueva abre en **Oscuro (OLED)**. La opción de respaldo de Rainmeter conserva el modo, el acento y las citas existentes al actualizar.
- **Por PowerShell (desde la raíz de `Veyra-Dots`):**
```powershell
.\scripts\install-rainmeter.ps1 -Theme one-ui
```
