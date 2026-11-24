# Material You Web v4.2.1 — Modo Dark & Modo Claro (Stylus)

Dos suites unificadas listas para arrastrar al Gestor de Stylus con **7 paletas** sincronizadas con Veyra-Dots (Azul, Gris, Rojo, Verde, **Amarillo**, Morado y Rosado):
- `material-you-web-dark.user.css` (**Modo Dark**)
- `material-you-web-light.user.css` (**Modo Claro**)

## Correcciones en v4.2.1
- **GitHub:** Excluido `.BtnGroup-item` del redondeo completo para preservar botones divididos (Star / Watch / Fork).
- **Claude:** Añadido token `--bg-500` para superficies elevadas recientes.
- **Metadatos UserStyle:** Añadidos `@homepageURL`, `@supportURL` y autor oficial de **Veyra-Dots**.

## Correcciones en v4.2
- **Gmail:** Corregido el icono oscuro del lápiz dentro del botón *Redactar* en Modo Dark para que mantenga contraste nítido.
- **Google Maps:** Eliminados los rectángulos negros sobre paneles claros y la barra negra detrás de los chips superiores.
- **Gemini:** Añadidos tokens `--gem-sys-color--*` y `--bard-color-sidenav-background` para teñir también el panel lateral con la paleta activa.
- **Selector de cuenta y 9 puntos (`ogs.google.com`):** Añadidos tokens `--gm3-sys-color-*` completos.

## Correcciones previas (v4.1)
- **GitHub:** Eliminado `[class*="Box-sc"]` para preservar el UI moderno en React.
- **YouTube:** Reproductor protegido en pantalla completa (`:not(.ytp-fullscreen)`) y Shorts.
- **Google Search, ChatGPT, WhatsApp Web, Claude, Linear, Wikipedia y Quora:** Escapes corregidos, tokens modernos, iconos blancos protegidos y soporte para **Grok (`grok.com`)**.
