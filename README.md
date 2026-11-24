# Veyra-Dots

Colección minimalista y modular de **dotfiles para Windows 11**, diseñada para personalizar el escritorio y el navegador por estilos visuales sin llenar el equipo de software pesado ni plugins externos.

---

## Showcase

> *Espacio reservado en `showcase/` para capturas de cada estilo.*
>
> `![Material You — Dark](showcase/material-you-dark.png)`
> `![Material You — Light](showcase/material-you-light.png)`

---

## Temáticas y Componentes

| Estilo | Carpeta | Estado | Componentes incluidos |
| :--- | :--- | :--- | :--- |
| **Material You** | [`themes/material-you/`](themes/material-you/README.md) | **Disponible (v1)** | **38 widgets Rainmeter** (Oscuro/Claro, ES/EN, 6 paletas + Auto Wallpaper), **Stylus v4.2** (Dark & Light, 7 paletas), **23 wallpapers**, extensión recomendada **Mynt New Tab** e `icons/` |
| **Glass / Mica** | `themes/glass/` | Planeado | Transparencias esmeriladas nativas de Windows 11 |
| **One UI** | `themes/one-ui/` | Planeado | Tarjetas suaves y controles estilo Samsung One UI |
| **macOS** | `themes/macos/` | Planeado | Barra superior minimalista y widgets estilo Sonoma/Sequoia |
| **Nothing OS** | `themes/nothing/` | Planeado | Estética matricial de alto contraste |

---

## Qué cubre cada capa del escritorio

1. **Escritorio (Rainmeter):** Widgets vectoriales y modulares en `themes/<estilo>/rainmeter/`, instalados en un clic sin `.dll` de terceros.
2. **Navegador (Stylus + Nueva Pestaña):**
   - Estilos web unificados en `themes/<estilo>/stylus/` (Modo Oscuro y Modo Claro).
   - Para **Material You**, se complementa con **[Mynt — Material You New Tab](https://chromewebstore.google.com/detail/mynt-material-you-new-tab/jjpokbgpiljgndebfoljdeihhkpcpfgl)** en Chrome Web Store.
3. **Fondos de Pantalla (`wallpapers/`):** Colecciones curadas acordes a cada paleta.
4. **Iconos (`icons/`):** Espacio dedicado a packs minimalistas para la barra de tareas.

---

## Estructura del repositorio

```text
Veyra-Dots/
├── README.md
├── showcase/                 # Capturas y vistas previas
├── scripts/
│   └── install-rainmeter.ps1 # Instalador 1-clic de cualquier estilo
└── themes/
    ├── material-you/         # Rainmeter (38 widgets), Stylus v4.2, 23 wallpapers, icons
    ├── glass/
    ├── one-ui/
    ├── macos/
    └── nothing/
```

---

## Instalación rápida

```powershell
# 1. Clona el repositorio
git clone https://github.com/Acourd/Veyra-Dots.git
cd Veyra-Dots

# 2. Instala los widgets de Rainmeter del estilo elegido y refresca la app
.\scripts\install-rainmeter.ps1 -Theme material-you
```

Para instalar **Stylus**, la extensión **Mynt** y consultar el catálogo completo de widgets de cada estilo, abre el README correspondiente dentro de `themes/`.

---

## Licencia

Distribuido bajo licencia **MIT**.
