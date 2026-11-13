# Upstream Design Skills Registry

Este registro documenta todas las skills de diseño instaladas en `home/giks/skills/software-design/`, sus repositorios oficiales de origen, los commits/versiones descargados y las instrucciones para actualizarlas si quedan desactualizadas.

Última sincronización: **Noviembre 2026**

---

## 1. Inventario de Skills Upstream

| Skill (Carpeta) | Repositorio Oficial | Subcarpeta en Origen | Versión / Commit SHA | Propósito / Enfoque |
|---|---|---|---|---|
| **`impeccable`** | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | `.pi/skills/impeccable` | `v4.8.2`<br>`b4bff1626c344067788c2679f048a20057c7cc5a` | Linter determinista (62 detectores), live browser, comandos (`audit`, `polish`, `shape`, `critique`) y 40+ guías de craft. |
| **`hallmark`** | [Nutlope/hallmark](https://github.com/Nutlope/hallmark) | `skills/hallmark` | `v2.0.0`<br>`04977e15f3dfd6ee4b74c887dac3eb52665d6c92` | Generación web anti-AI-slop (The Floor de 16 reglas duras), `sloplint`, 50 temas visuales completos y macroestructuras. |
| **`frontend-design`** | [anthropics/skills](https://github.com/anthropics/skills) | `skills/frontend-design` | Official Anthropic<br>`2c5958ecac7cee2b583967a2c4981d0f4a75c579` | Baseline estándar de Anthropic para forzar dirección estética distintiva y evitar defaults. |
| **`animate`** | [emilkowalski/skills](https://github.com/emilkowalski/skills) | `skills/animate` | Emil Kowalski<br>`f7ce8c02d6e3c8f0d980a44c57bcc41a40254349` | Implementación y física de animaciones (springs, curvas, duraciones, accesibilidad) estilo Linear/Vercel. |
| **`emil-design-eng`** | [emilkowalski/skills](https://github.com/emilkowalski/skills) | `skills/emil-design-eng` | Emil Kowalski<br>`f7ce8c02d6e3c8f0d980a44c57bcc41a40254349` | Filosofía de ingeniería de diseño de Emil Kowalski sobre pulido de componentes y microinteracciones invisibles. |
| **`landing-page-design`** | [elayadesign/ai-design-skills](https://github.com/elayadesign/ai-design-skills) | `skills/landing-page-design` | Elaya Design<br>`456d9e0d3e2d84c748bb143c6ca3d90c45e16213` | Sistema de conversión para landing pages: intake estratégico, copy CRO, layouts y sistema visual estricto. |
| **`material-3`** | [hamen/material-3-skill](https://github.com/hamen/material-3-skill) | `skills/material-3` | Google I/O 2026<br>`14385f2bf3804d8779f8b4db2604211f1e70b4c1` | Jetpack Compose (principal) + Flutter + Web. Tokens MD3, componentes, adaptive layouts y auditoría. |
| **`material-design-3-ui`** | [skydashnet/material-design-3-ui-skill](https://github.com/skydashnet/material-design-3-ui-skill) | Raíz del repositorio | `v1.1.1`<br>`82783f76de4a5b08a60421cae935cf8de7ca1ee8` | Decisiones semánticas de Material 3, accesibilidad, layouts adaptativos y revisión de interfaces multiplataforma. |
| **`m3-expressive`** | [abhixv/m3-expressive-design-skill](https://github.com/abhixv/m3-expressive-design-skill) | `skills/m3-expressive` | Abhixv<br>`797764c24eb5f96d601f022bb9d3c8167140af7f` | Tokens exactos de M3 Expressive, springs de motion, shape morphing y biblioteca visual con referencias completas. |

---

## 2. Guía rápida para actualizar una skill si queda desactualizada

Si necesitas actualizar cualquiera de estas skills en el futuro, ejecuta estos comandos en tu terminal:

### Para `impeccable`:
```bash
git clone --depth 1 https://github.com/pbakaus/impeccable.git /tmp/update-impeccable
rm -rf /home/giks/nixos-config/home/giks/skills/software-design/impeccable
cp -r /tmp/update-impeccable/.pi/skills/impeccable /home/giks/nixos-config/home/giks/skills/software-design/impeccable
rm -rf /tmp/update-impeccable
```

### Para `hallmark`:
```bash
git clone --depth 1 https://github.com/Nutlope/hallmark.git /tmp/update-hallmark
rm -rf /home/giks/nixos-config/home/giks/skills/software-design/hallmark
cp -r /tmp/update-hallmark/skills/hallmark /home/giks/nixos-config/home/giks/skills/software-design/hallmark
rm -rf /tmp/update-hallmark
```

### Para `frontend-design`:
```bash
git clone --depth 1 https://github.com/anthropics/skills.git /tmp/update-anthropic
rm -rf /home/giks/nixos-config/home/giks/skills/software-design/frontend-design
cp -r /tmp/update-anthropic/skills/frontend-design /home/giks/nixos-config/home/giks/skills/software-design/frontend-design
rm -rf /tmp/update-anthropic
```

### Para las de `emilkowalski/skills` (`animate`, `emil-design-eng`):
```bash
git clone --depth 1 https://github.com/emilkowalski/skills.git /tmp/update-emil
cp -r /tmp/update-emil/skills/animate /home/giks/nixos-config/home/giks/skills/software-design/
cp -r /tmp/update-emil/skills/emil-design-eng /home/giks/nixos-config/home/giks/skills/software-design/
rm -rf /tmp/update-emil
```

### Para `landing-page-design`:
```bash
git clone --depth 1 https://github.com/elayadesign/ai-design-skills.git /tmp/update-elaya
rm -rf /home/giks/nixos-config/home/giks/skills/software-design/landing-page-design
cp -r /tmp/update-elaya/skills/landing-page-design /home/giks/nixos-config/home/giks/skills/software-design/landing-page-design
rm -rf /tmp/update-elaya
```

### Para `material-3` (Hamen):
```bash
git clone --depth 1 https://github.com/hamen/material-3-skill.git /tmp/update-hamen-m3
rm -rf /home/giks/nixos-config/home/giks/skills/software-design/material-3
cp -r /tmp/update-hamen-m3/skills/material-3 /home/giks/nixos-config/home/giks/skills/software-design/material-3
rm -rf /tmp/update-hamen-m3
```

### Para `material-design-3-ui` (Skydash):
```bash
git clone --depth 1 https://github.com/skydashnet/material-design-3-ui-skill.git /tmp/update-skydash-m3
rm -rf /home/giks/nixos-config/home/giks/skills/software-design/material-design-3-ui
mkdir -p /home/giks/nixos-config/home/giks/skills/software-design/material-design-3-ui
rsync -av --exclude=".git" /tmp/update-skydash-m3/ /home/giks/nixos-config/home/giks/skills/software-design/material-design-3-ui/
rm -rf /tmp/update-skydash-m3
```

### Para `m3-expressive` (Abhixv):
```bash
git clone --depth 1 https://github.com/abhixv/m3-expressive-design-skill.git /tmp/update-abhixv-m3
rm -rf /home/giks/nixos-config/home/giks/skills/software-design/m3-expressive
cp -r /tmp/update-abhixv-m3/skills/m3-expressive /home/giks/nixos-config/home/giks/skills/software-design/m3-expressive
rm -rf /tmp/update-abhixv-m3
```
