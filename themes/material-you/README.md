# Tema: Material You (Material Design 3)

Personalización minimalista para Windows 11 y navegador basada en **Material Design 3**, sin plugins externos de Rainmeter.

## Contenido

- `rainmeter/Skins/MaterialYZen/` — **44 widgets** con selector rápido en pantalla (`ThemeSwitcher.ini`):
  - **Modo Oscuro / Claro** y **ES / EN** en un clic.
  - **6 paletas manuales** (Gris, Azul, Rojo, Rosa, Amarillo, Verde) + **modo Auto** que extrae el color real de tu wallpaper (con detección monocromática para fondos grises/negros/blancos).
  - **Categorías:** `ThemeSwitcher`, `Clock` (14, incluye `ClockSunArc` y `ExpressiveBento`), `Calendar` (3), `Battery` (3), `Audio` (3), `System` (2, incluye `NetworkPulse`), `Search` (3 con iconos oficiales HD), `Music` (4), `Notes` (1), `Productivity` (4), `QuickSettings` (1), `MeterialYouLab` (2) y la nueva subsección **`ProHub` (3)** (`BluetoothHub`, `AIUsageHub`, `StorageVault`).
- `stylus/material-you-web-v4-dark-light/` — Suites **Modo Dark** y **Modo Claro** (**v4.2.1**) con 7 paletas sincronizadas para Google, YouTube, Reddit, GitHub, WhatsApp Web, Linear, Wikipedia, X, Twitch y toda la suite de IA (ChatGPT, Gemini, Claude, Grok, Perplexity, DeepSeek, AI Studio y NotebookLM).
- [`wallpapers/`](wallpapers/) — **23 fondos de pantalla 4K** Material You.
- [`icons/m3-pastel/`](icons/m3-pastel/) — **84 iconos Pastel Tonal** (PNG 256×256 + ICO multirresolución) para navegadores, juegos, productividad, música, IA y utilidades del día a día, listos para escritorio, barra de tareas y el dock **[Muelle](https://github.com/crafter-station/Muelle)**.

## Extensión recomendada para el navegador

- **Nueva Pestaña:** [Mynt — Material You New Tab](https://chromewebstore.google.com/detail/mynt-material-you-new-tab/jjpokbgpiljgndebfoljdeihhkpcpfgl) (Chrome Web Store) — armoniza la pantalla de nueva pestaña con las mismas paletas Material You.

## Instalación rápida

### 1. Rainmeter (doble clic `.rmskin` o PowerShell)
- **Opción más fácil (1 clic, sin terminal):** descarga y haz doble clic en **[`MaterialYZen-v2.rmskin`](../../releases/MaterialYZen-v2.rmskin)**.
- **Por PowerShell (desde la raíz de `Veyra-Dots`):**
```powershell
.\scripts\install-rainmeter.ps1 -Theme material-you
```
- **Wallpapers 4K:** explora y descarga los 23 fondos en **[`wallpapers/`](wallpapers/)**.

### 2. Stylus
1. Instala la extensión **Stylus** en tu navegador.
2. Arrastra `material-you-web-dark.user.css` y/o `material-you-web-light.user.css` desde `stylus/material-you-web-v4-dark-light/` al Gestor de Stylus.
3. Si actualizaste desde una versión previa, recarga la pestaña con `Ctrl + F5` para limpiar caché visual.
