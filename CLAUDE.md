# CLAUDE.md — Agenda Escolar Adventista

> Contexto del proyecto para Claude Code. Lee este archivo SIEMPRE antes de programar.

---

## ESTRATEGIA ACTUAL: FRONTEND-FIRST

**Estamos construyendo el frontend completo CON DATOS MOCK antes de conectar Firebase.**

Esto significa:
- ❌ NO uses `firebase_auth`, `cloud_firestore`, etc. todavía
- ✅ USA datos hardcodeados (mock data) en repositorios fake
- ✅ Implementa toda la UI/UX completa
- ✅ Implementa toda la lógica de presentación con Riverpod
- ✅ Diseña pensando que ESTO es lo que verá el cliente primero

**Cuando todo el frontend esté listo y aprobado, recién conectamos Firebase**. Por ahora los repositorios devuelven listas hardcodeadas y `Future.delayed` para simular latencia.

---

## Resumen del proyecto

**Nombre**: Agenda Escolar Adventista (AEA)
**Cliente**: Colegio Adventista de Juliaca, Puno, Perú
**Tipo**: Aplicación móvil + panel web administrativo
**Versión SRS**: v2.0
**Fase actual**: Desarrollo de frontend con mock data

### Propósito

Sistema institucional para:
1. Comunicación de eventos del colegio
2. Asistencia de docentes con QR rotativo + GPS + dispositivo único
3. Trámites de documentos de padres
4. Gestión institucional de usuarios (carga masiva, NO auto-registro)
5. Reportes y notificaciones

### Escala
- ~1000 estudiantes
- ~1500 padres
- 50-80 docentes

---

## Stack tecnológico

| Componente | Tecnología |
|---|---|
| Frontend móvil | Flutter 3.19+ (Dart 3.x) |
| Estado | Riverpod 2.x |
| Navegación | go_router |
| Tipografía | Google Fonts (Inter) |
| Animaciones | flutter_animate |
| Iconos | phosphor_flutter (más modernos que Material) |
| QR | mobile_scanner + qr_flutter |
| Persistencia local | Hive |
| **Backend (FUTURO)** | Firebase — NO ahora |

---

## DIRECCIÓN DE DISEÑO: "Sereno y moderno"

El sistema visual combina **minimalismo institucional** con **toques modernos**. Apropiado para un colegio adventista pero contemporáneo.

### Principios visuales

1. **Espacio respira** — generoso padding (24-32px), márgenes amplios, no abigarrar
2. **Tipografía como protagonista** — títulos grandes (28-40pt), pesos contrastantes
3. **Color con intención** — paleta limitada, acentos puntuales, no decorativos
4. **Movimiento sutil** — animaciones de 200-400ms, easing natural
5. **Sin sombras pesadas** — usar bordes finos (0.5-1px) para profundidad
6. **Esquinas con personalidad** — radios de 16-24px en cards, 12px en botones
7. **Gradientes con propósito** — usados solo en headers o featured cards
8. **Iconografía consistente** — `phosphor_flutter` (regular/duotone), no Material default

### Paleta de colores

```dart
// PRIMARIOS — Azul navy adventista, sobrio y profesional
primary       = #0F3D5C   // Color principal de marca
primaryLight  = #2563A0   // Hover, gradientes
primarySoft   = #E6F1FB   // Fondos sutiles, badges
primaryDeep   = #082640   // Modo oscuro

// ACENTO — Dorado adventista, usar con moderación
accent        = #E8A33D   // FAB, links importantes, destacados
accentSoft    = #FAEEDA   // Fondos de chips dorados

// FONDOS — Crema cálido en lugar de blanco frío
background    = #FAF8F3   // Fondo principal
surface       = #FFFFFF   // Cards, inputs
surfaceMuted  = #F5F3EE   // Secciones, divisores

// TEXTO — Jerarquía clara
textPrimary   = #1A1B1E   // Casi negro, no #000
textSecondary = #5F5E5A   // Gris cálido
textTertiary  = #9A9A95   // Para metadata, captions
textOnPrimary = #FFFFFF
textOnAccent  = #1A1B1E   // Sobre dorado siempre oscuro

// CATEGORÍAS DE EVENTOS — vivos pero no saturados
categoryCultural   = #8B5CF6  // Violet suave
categorySpiritual  = #3B82F6  // Blue refinado
categoryAcademic   = #10B981  // Emerald moderno
categorySports     = #F59E0B  // Amber cálido
categoryCampaign   = #EF4444  // Red coral

// SEMÁNTICOS
success     = #10B981
successSoft = #D1FAE5
warning     = #F59E0B
warningSoft = #FEF3C7
error       = #EF4444
errorSoft   = #FEE2E2
info        = #3B82F6
infoSoft    = #DBEAFE

// BORDES Y DIVISORES
border       = #E8E5DD   // Borde de cards
borderActive = #0F3D5C   // Hover, focus
divider      = #F0EDE5   // Líneas separadoras finas
```

### Tipografía (Google Fonts — Inter)

```dart
// DISPLAY — Solo portadas, headers principales
display      = 40pt / FontWeight.w800 / letterSpacing -1.0
displaySmall = 32pt / FontWeight.w700 / letterSpacing -0.5

// HEADINGS
h1 = 28pt / FontWeight.w700 / letterSpacing -0.3
h2 = 22pt / FontWeight.w600 / letterSpacing -0.2
h3 = 18pt / FontWeight.w600
h4 = 16pt / FontWeight.w500

// BODY
bodyLarge  = 16pt / FontWeight.w400 / lineHeight 1.5
bodyMedium = 14pt / FontWeight.w400 / lineHeight 1.5
bodySmall  = 13pt / FontWeight.w400 / lineHeight 1.4

// LABEL Y CAPTION
label    = 12pt / FontWeight.w500 / letterSpacing 0.4 / UPPERCASE
caption  = 12pt / FontWeight.w400 / textTertiary
metadata = 11pt / FontWeight.w400 / textTertiary

// BUTTONS
buttonLarge   = 16pt / FontWeight.w600 / letterSpacing 0.2
buttonRegular = 14pt / FontWeight.w600 / letterSpacing 0.2
```

### Espaciado (escala de 4px)

```
xs   = 4px
sm   = 8px
md   = 12px
base = 16px
lg   = 20px
xl   = 24px
2xl  = 32px
3xl  = 40px
4xl  = 56px
5xl  = 80px
```

Padding interno de pantallas: **24px horizontal**.
Espaciado entre secciones: **32px**.
Espaciado entre cards de una lista: **12px**.

### Bordes redondeados

```
xs   = 6px   // chips pequeños, badges
sm   = 8px   // inputs, chips medianos
base = 12px  // botones, cards pequeños
md   = 16px  // cards principales
lg   = 20px  // cards destacados
xl   = 24px  // hero sections, banners
full = 9999px // pills, avatares
```

### Sombras (suaves)

```dart
// shadowSm — apenas perceptible
BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))

// shadowMd — para hover
BoxShadow(color: Color(0x10000000), blurRadius: 16, offset: Offset(0, 4))

// shadowLg — modales y bottom sheets
BoxShadow(color: Color(0x14000000), blurRadius: 32, offset: Offset(0, 8))
```

### Animaciones

Usar `flutter_animate`. Patrones:

```dart
// Fade in con slide para contenido nuevo
.animate().fadeIn(duration: 400ms).slideY(begin: 0.1, end: 0)

// Stagger para listas
.animate(delay: (index * 60).ms).fadeIn().slideX(begin: -0.05)

// Pulse sutil para elementos importantes
.animate(onPlay: (c) => c.repeat(reverse: true))
  .scale(begin: 1.0, end: 1.02, duration: 2000ms)
```

Curvas:
- `Curves.easeOutCubic` — entradas
- `Curves.easeInOutCubic` — transiciones
- `Curves.elasticOut` — feedback positivo (poco)

---

## Patrones de UI específicos

### Header personalizado (NO AppBar tradicional)

```
┌─────────────────────────────────────────┐
│  ←                              ⋯       │
│                                         │
│  Mis documentos                         │
│  3 pendientes de revisión               │
│                                         │
│  [chip: Todos] [chip: Pendientes] ...   │
└─────────────────────────────────────────┘
```

### Cards de listado

```
┌─────────────────────────────────────────┐
│  [icon]  Título grande                  │
│          Subtítulo en textSecondary     │
│                                  [→]    │
│  ─────────────────────────────────      │
│  metadata · más metadata · estado       │
└─────────────────────────────────────────┘
borderRadius: 16px, border 0.5px, sin sombra
```

### Bottom Navigation moderna (pill flotante)

NO usar `BottomNavigationBar` clásico.

```
   ┌────────────────────────────────┐
   │  🏠   📅   📂   👤             │
   └────────────────────────────────┘
```

Posición: 16px del bottom, mx 24px. Border radius: 24px. Background con leve blur.

### Estados vacíos con personalidad

```
       [ilustración SVG]
       
       Aún no hay eventos
       
   Cuando la administración publique
   nuevos eventos, aparecerán aquí.
   
       [Botón: Configurar notificaciones]
```

### Botones jerarquizados

```dart
PrimaryButton    // fondo primary — acciones principales
AccentButton     // fondo accent dorado — CTA destacado (uno por pantalla)
SecondaryButton  // borde primary — acciones secundarias
TextButton       // solo texto — terciarias
DangerButton     // fondo error — destructivas
GhostButton      // sin borde, hover sutil — contextuales
```

Altura: 48px regular, 56px destacado. Border radius: 12px.

### Estados de carga

Usar `shimmer` package para skeletons que mantengan la forma del contenido final, no spinners genéricos.

---

## Arquitectura

**Clean Architecture por features**.

```
lib/
├── core/
│   ├── constants/           # AppConstants
│   ├── errors/              # Failures, Exceptions
│   ├── theme/               # AppColors, AppTextStyles, AppTheme, AppSpacing
│   ├── router/              # AppRouter, AppRoutes
│   ├── widgets/             # PrimaryButton, ModernHeader, etc.
│   ├── utils/               # Validators, Formatters
│   └── extensions/          # Extensions útiles
├── features/
│   ├── auth/
│   ├── users_management/    # POR CREAR (v2.0)
│   ├── events/
│   ├── attendance/
│   ├── documents/
│   ├── reports/
│   └── notifications/
└── shared/
    └── mock_data/           # ⭐ DATOS MOCK CENTRALIZADOS
        ├── mock_users.dart
        ├── mock_events.dart
        ├── mock_documents.dart
        └── mock_attendance.dart
```

### Estructura por feature

```
features/<nombre>/
├── data/
│   ├── datasources/
│   │   └── <nombre>_mock_datasource.dart   # ⭐ MOCK por ahora
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

### Reglas de capas (NO violar)

- Presentation depende solo de Domain
- Domain NO depende de Flutter ni nada externo
- Data implementa interfaces de Domain
- Cuando migremos a Firebase, solo cambia Data

---

## Cómo manejar mock data

### Patrón

```dart
// shared/mock_data/mock_events.dart
class MockEvents {
  static List<Event> get all => [
    Event(
      id: 'evt_001',
      title: 'Feria cultural adventista',
      description: 'Celebración cultural...',
      category: EventCategory.cultural,
      startDate: DateTime.now().add(Duration(days: 3)),
    ),
    // 10-15 eventos variados de ejemplo
  ];
}

// features/events/data/datasources/events_mock_datasource.dart
class EventsMockDataSource {
  Future<List<EventModel>> getEvents() async {
    await Future.delayed(Duration(milliseconds: 500));
    return MockEvents.all.map(EventModel.fromEntity).toList();
  }
}
```

**Datos mock realistas**: nombres en español, fechas variadas (pasados, hoy, futuros), todas las categorías representadas, estados diversos.

---

## Roles del sistema (5 roles)

| Rol | Plataforma | Cantidad |
|---|---|---|
| `admin` | Panel web | 1-3 |
| `secretary` | Panel web | 2-5 |
| `teacher` | App móvil | 50-80 |
| `parent` | App móvil | hasta 1500 |
| `student` | App móvil | hasta 600 (solo secundaria) |

**Modelo institucional v2.0**:
- ❌ NO existe auto-registro
- ✅ Admin carga usuarios masivamente desde Excel
- ✅ Sistema genera `activationCode` de 8 caracteres (vigencia 90 días)
- ✅ Usuario activa con email + código + nueva contraseña
- ✅ Estados: `preregistered` → `active` → (suspended | graduated)

---

## Convenciones de código

### Idioma
- Código: inglés
- UI strings: español Perú
- Comentarios: español

### Estilo Dart
- `flutter_lints` activado
- `prefer_single_quotes`, `require_trailing_commas`
- Imports siempre con `package:agenda_escolar_adventista/...`
- Nunca imports relativos

### Riverpod
- Providers terminan en `Provider`
- NO `setState` para estado de negocio, usar Riverpod
- `setState` solo para UI temporal trivial

---

## Estado actual del proyecto

### Lo que ya está

- Estructura de carpetas con Clean Architecture
- `pubspec.yaml` con dependencias
- `core/` parcial: theme, router, widgets, utils
- `auth/` con estructura básica (necesita refactor v2.0)
- `events/` parcial
- Pantallas placeholder en otros features
- Tests básicos

### Lo que requiere refactor para alinear con esta guía

1. **Theme**: actualizar `app_colors.dart` con paleta extendida
2. **AppSpacing, AppRadius, AppShadows**: crear constantes
3. **PhosphorIcons**: agregar dependencia, reemplazar Material Icons
4. **Auth**: refactor a v2.0 (activación + 5 roles)

### Lo que falta crear

**Prioridad 1 — Foundation moderna**:
- `core/theme/app_spacing.dart`
- `core/theme/app_radius.dart`
- `core/theme/app_shadows.dart`
- `core/widgets/modern_header.dart` (no AppBar)
- `core/widgets/floating_bottom_nav.dart`
- `core/widgets/category_chip.dart`
- `core/widgets/skeleton_loader.dart`
- `core/widgets/empty_state.dart` mejorado
- `core/extensions/build_context_extension.dart`

**Prioridad 2 — Mock data centralizado**:
- `shared/mock_data/mock_users.dart`
- `shared/mock_data/mock_events.dart`
- `shared/mock_data/mock_documents.dart`
- `shared/mock_data/mock_attendance.dart`

**Prioridad 3 — Feature por feature con mock**:
- Refactor auth (5 roles + activación)
- Eventos completo
- Asistencia completa
- Documentos completo
- Notificaciones
- Pantallas de student

---

## Plan de trabajo (frontend-first)

### Sprint 1: Foundation moderna
1. Actualizar `app_colors.dart` con paleta extendida
2. Crear `app_spacing.dart`, `app_radius.dart`, `app_shadows.dart`
3. Agregar `phosphor_flutter` y `flutter_animate` al pubspec
4. Crear widgets modernos del kit base
5. Pantalla de "Style Guide" para validar el sistema

### Sprint 2: Refactor auth con UI moderna
1. Agregar rol `student`
2. Actualizar entidades v2.0
3. Crear `ActivateAccount` use case (mock)
4. Refactorizar pantallas:
   - Splash con animación elegante
   - Welcome con ilustración hero
   - Onboarding con páginas animadas
   - Login moderno con micro-interacciones
   - Pantalla de activación nueva
5. `student_home_screen.dart`

### Sprint 3: Mock data + Eventos
1. Mock data centralizado
2. Refactor events con UI moderna
3. Filtros con chips animados
4. Detalle de evento con hero image
5. Animaciones stagger

### Sprint 4: Documentos + Asistencia
1. Documentos: drag&drop, estados visuales
2. Asistencia: QR moderna, animación de éxito

### Sprint 5: Notificaciones + Reportes (mock)
### Sprint 6: Panel web admin
### Sprint 7+: Conectar Firebase (recién aquí)

---

## Comandos útiles

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter run -d chrome
```

---

## Personas

- **Líder**: estudiante de ingeniería de sistemas en Juliaca
- **Cliente**: Dirección del Colegio Adventista de Juliaca
- **Asistente IA**: Claude Code (tú)

## Preferencias del líder

- Explicaciones en español, claras pero no excesivas
- Soy novato técnicamente, agradezco contexto en lo complejo
- Prefiero código real funcional sobre teoría
- Cuando termines algo, dime cómo probarlo
- Si hay decisiones, dame opciones con pros/contras
- Avísame antes de tocar muchos archivos
- Sin emojis excesivos
- Si veo errores, prefiero entender el porqué

---

## Reglas finales para Claude Code

1. **Lee este archivo PRIMERO** al iniciar cualquier sesión.
2. **NO uses Firebase** todavía. Mock data por ahora.
3. **Respeta el Design System** estrictamente.
4. **No mezcles capas** de Clean Architecture.
5. **Animaciones sí, sutiles** — 200-400ms.
6. **Phosphor Icons** sobre Material cuando sea posible.
7. **Pregunta antes de asumir**.
8. **Al terminar**, ejecuta `flutter analyze` y arregla warnings.
9. **Documentos del proyecto** son la fuente de verdad del alcance.

## Inspiración visual (apps de referencia)

Para que tengamos la misma idea:

- **Notion** (mobile) — tipografía, espaciado generoso
- **Linear** — paleta sobria, micro-interacciones
- **Things 3** — claridad, jerarquía visual
- **Apple Notes** — calidez, headers grandes
- **Stripe Dashboard** — datos densos pero respirables
- **Headspace** — colores cálidos, sensación tranquila

NO inspiración de:
- Apps muy infantiles con caricaturas
- Apps con emojis decorativos en todas partes
- Apps con sombras 3D pesadas
- Apps con gradientes saturados
