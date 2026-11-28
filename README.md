# Veyra-Dots

**English** | [Español](README.es.md)

Windows 11 desktop setups — Rainmeter widgets, custom icons, wallpapers, and browser styles — grouped by visual theme. No bloatware and no third-party Rainmeter `.dll` plugins.

---

## Showcase

https://github.com/user-attachments/assets/689d621e-6450-416e-b4cd-c3631081fab4

> Source for the animation above: [`showcase/teaser.html`](showcase/teaser.html) (open locally in any Chromium browser).

### Material You (Dark & Light)
| Amber — Dark | Amber — Light |
| :---: | :---: |
| ![Material You Amber Dark](showcase/material-you-amber-dark.jpg) | ![Material You Amber Light](showcase/material-you-amber-light.jpg) |
| **Sage — Dark** | **Sage — Light** |
| ![Material You Sage Dark](showcase/material-you-sage-dark.jpg) | ![Material You Sage Light](showcase/material-you-sage-light.jpg) |

### Samsung One UI 7 / 8 (OLED Dark & Pure Snow)
| Blue — OLED Dark | Blue — Pure Snow Light |
| :---: | :---: |
| ![One UI Blue Dark](showcase/one-ui-blue.jpg) | ![One UI Blue Light](showcase/one-ui-blue-light.jpg) |
| **Coral — OLED Dark** | **Coral — Pure Snow Light** |
| ![One UI Coral Dark](showcase/one-ui-coral.jpg) | ![One UI Coral Light](showcase/one-ui-coral-light.jpg) |

### macOS Sonoma / Sequoia
| Graphite — Dark | Graphite — Light |
| :---: | :---: |
| ![macOS Graphite Dark](showcase/macos-graphite-dark.png) | ![macOS Graphite Light](showcase/macos-graphite-light.jpg) |
| **Magenta — Auto Wall Dark** | **Magenta — Auto Wall Light** |
| ![macOS Magenta Dark](showcase/macos-magenta-darkwall.jpg) | ![macOS Magenta Light](showcase/macos-magenta-lightwall.jpg) |

---

## Themes

| Theme | Folder | Status | What's inside |
| :--- | :--- | :--- | :--- |
| **Material You** | [`themes/material-you/`](themes/material-you/README.md) | Ready (v2) | 44 Rainmeter widgets (Dark/Light, EN/ES, 6 palettes + Auto Wallpaper), Stylus v4.2.1 web styles (Dark & Light), 23 wallpapers, 84 Expressive Pastel icons (`m3-pastel`) + 12 tonal palettes (`m3-palettes`) |
| **One UI** | [`themes/one-ui/`](themes/one-ui/README.md) | Ready (v3.1) | 54 Rainmeter widgets (`OneUIZen`, OLED Dark / Pure Snow Light, 5 accents + Auto Wallpaper, Retro Cassette, Smart Stack), 36 4K wallpapers, 168 icons (`oneui-vibrant` + `oneui-dark`) |
| **macOS** | [`themes/macos/`](themes/macos/README.md) | Ready (v2) | 28 Rainmeter widgets (`MacOSZen`, Sonoma/Sequoia): Menu Bar, Control Center, StandBy Clock, Dynamic Notch Hub, iStat Hub, Storage, Power Menu, Activity Rings, 6 accents, 84 icons (`macos-sequoia`) |
| **Glass / Mica** | [`themes/glass/`](themes/glass/README.md) | Ready (v2) | 24 Direct2D Rainmeter widgets (`GlassZen`, Smoked Glass / Frosted Ice / Liquid Crystal, 6 Fluent accents + Auto Wallpaper, ProHub), 168 Frosted Ice icons (`glass-frosted` Dark + `glass-frosted-light` Light) |
| **Nothing OS** | [`themes/nothing/`](themes/nothing/README.md) | Ready (v2.1) | 18 Direct2D Rainmeter widgets (`NothingZen`, OLED Matte / Chalk Paper / Wireframe AOD, 5×7 vector dot clock, radial tick dials, dot-matrix telemetry), 168 icons (`nothing-mono` OLED + `nothing-chalk` Light) |

### Companion Tools & Icons

- **Widgets:** 142 Rainmeter widgets across all five suites, zero external `.dll` files, sharpness-audited with integer Direct2D strokes.
- **Dock:** Screenshots use **[Muelle](https://github.com/crafter-station/Muelle)**. Both Muelle and the default Windows 11 Taskbar/Desktop have reversible icon scripts under `scripts/`.
- **Browser:** Stylus v4.2.1 userstyles (`themes/material-you/stylus/`) for Google, YouTube, Reddit, GitHub, WhatsApp Web, Linear, Wikipedia, X, Twitch, and AI apps (ChatGPT, Gemini, Claude, Grok, Perplexity, DeepSeek, AI Studio, NotebookLM), paired with **[Mynt New Tab](https://chromewebstore.google.com/detail/mynt-material-you-new-tab/jjpokbgpiljgndebfoljdeihhkpcpfgl)**.
- **Icons (672 core icons across 8 style packs + 12 Material You tonal palettes — 84 daily apps each in PNG 256×256 + multi-res 6-frame ICO):** Browsers (`Chrome`, `Edge`, `Firefox`, `Brave`, `Opera GX`, `Vivaldi`, `Zen Browser`, `Helium`), Games (`Steam`, `Epic`, `Riot`, `Valorant`, `GTA V`, `Minecraft`, `Roblox`, `CS2`, `League of Legends`, `Fortnite`, `Genshin`, `Xbox`, `Terraria`, etc.), Productivity (`VS Code`, `Notion`, `Obsidian`, `Linear`, `Figma`, `Blender`, `Word`, `Excel`, `PowerPoint`, etc.), Media/Social (`Spotify`, `YouTube Music`, `YouTube`, `VLC`, `OBS`, `Discord`, `WhatsApp`, `Telegram`, `Reddit`), AI & Utilities — built on **[Graphite-Elegance](https://github.com/Acourd/Graphite-Elegance)** silhouettes + custom 512px vectors.

| Material You — Expressive Pastel (84) | One UI — Vibrant (84) | One UI — OLED Dark (84) |
| :---: | :---: | :---: |
| ![Material You Icons](themes/material-you/icons/preview.png) | ![One UI Vibrant Icons](themes/one-ui/icons/preview.png) | ![One UI Dark Icons](themes/one-ui/icons/preview-dark.png) |
| **Glass — Frosted Ice Dark (84)** | **Glass — Frosted Ice Light (84)** | **macOS — Sequoia Glass (84)** |
| ![Glass Dark Icons](themes/glass/icons/preview.png) | ![Glass Light Icons](themes/glass/icons/preview-light.png) | ![macOS Icons](themes/macos/icons/preview.png) |
| **Nothing OS — OLED Matte (84)** | **Nothing OS — Chalk Paper Light (84)** | |
| ![Nothing OLED Icons](themes/nothing/icons/preview.png) | ![Nothing Chalk Icons](themes/nothing/icons/preview-chalk.png) | |

---

## Quick Start

Pick the method that fits your setup — click any option to expand:

<details>
<summary><strong>Option 1 — Double-click <code>.rmskin</code> packages (easiest, no terminal)</strong></summary>

Download and double-click any Rainmeter package in [`releases/`](releases/):
- [`MaterialYZen-v2.rmskin`](releases/MaterialYZen-v2.rmskin) (44 widgets)
- [`OneUIZen-v2.rmskin`](releases/OneUIZen-v2.rmskin) (54 widgets)
- [`MacOSZen-v2.rmskin`](releases/MacOSZen-v2.rmskin) (28 widgets)
- [`GlassZen-v2.rmskin`](releases/GlassZen-v2.rmskin) (24 widgets)
- [`NothingZen-v2.rmskin`](releases/NothingZen-v2.rmskin) (24 widgets)

</details>

<details>
<summary><strong>Option 2 — Full setup via PowerShell (Widgets + Muelle dock icons)</strong></summary>

```powershell
# 1. Clone the repo
git clone https://github.com/Acourd/Veyra-Dots.git
cd Veyra-Dots

# 2. Install Rainmeter widgets (material-you, one-ui, macos, glass, nothing, or all)
.\scripts\install-rainmeter.ps1 -Theme material-you
# Or install all 5 suites (157 widgets) at once:
.\scripts\install-rainmeter.ps1 -Theme all

# 3. (Optional) Apply custom icons to Muelle dock (auto-backs up originals; -Scale 0.90–1.08, default 1.05)
.\scripts\apply-muelle-icons.ps1 -Theme material-you
.\scripts\apply-muelle-icons.ps1 -Theme one-ui -Variant vibrant
.\scripts\apply-muelle-icons.ps1 -Theme one-ui -Variant dark
.\scripts\apply-muelle-icons.ps1 -Theme macos
.\scripts\apply-muelle-icons.ps1 -Theme glass
.\scripts\apply-muelle-icons.ps1 -Theme nothing

# Restore original Muelle icons anytime:
.\scripts\apply-muelle-icons.ps1 -Restore
```

</details>

<details>
<summary><strong>Option 3 — Default Windows 11 Desktop & Taskbar icons (no Muelle needed)</strong></summary>

Applies the `.ico` packs directly to Desktop shortcuts and pinned Windows 11 Taskbar apps. Originals are backed up automatically to `%LOCALAPPDATA%\VeyraDots\` so you can revert anytime.

```powershell
# Apply to Desktop & pinned Taskbar (-Scope All | Desktop | Taskbar)
.\scripts\apply-windows-icons.ps1 -Theme material-you -RestartExplorer
.\scripts\apply-windows-icons.ps1 -Theme one-ui -Variant dark -RestartExplorer
.\scripts\apply-windows-icons.ps1 -Theme one-ui -Variant vibrant -Scope Taskbar -RestartExplorer

# Restore original Windows shortcut icons anytime:
.\scripts\apply-windows-icons.ps1 -Restore -RestartExplorer
```

</details>

For **Stylus v4.2.1**, **Mynt New Tab**, and the full widget list for each theme, check the README inside each folder under `themes/`.

---

## Credits, Disclaimer & License

- Icon silhouette base: **[Graphite-Elegance](https://github.com/Acourd/Graphite-Elegance)** by Acourd.
- Dock in screenshots: **[Muelle](https://github.com/crafter-station/Muelle)** by Crafter Station.
- New Tab extension: **[Mynt — Material You New Tab](https://chromewebstore.google.com/detail/mynt-material-you-new-tab/jjpokbgpiljgndebfoljdeihhkpcpfgl)**.
- **Trademark Disclaimer:** Veyra-Dots is an independent, non-commercial, open-source project. It is **not** affiliated with, endorsed by, or sponsored by Google LLC, Samsung Electronics, Apple Inc., or any app/game publisher represented in the optional icon packs. All product names, trademarks, and logos belong to their respective owners and are used solely for nominative identification on the user's desktop.
- License: **MIT**.
