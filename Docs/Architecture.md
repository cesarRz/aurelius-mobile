# Arquitectura de Aurelius

SwiftUI con organización por funcionalidad y un store observable compartido.
Las vistas describen la interfaz, las entidades representan los datos y el store
coordina el estado del workspace. Un ViewModel por pantalla se añade cuando exista
lógica de presentación que necesite vida propia; no es obligatorio para cada View.

## Estructura

- `Aurelius/App`: entrada de la app, creación de dependencias y tipos de navegación.
- `Aurelius/Domain/Entities`: entidades Swift independientes de SwiftUI.
- `Aurelius/Data/Workspace`: WorkspaceStore y extensiones de acciones, consultas y edición.
- `Aurelius/Data/Preview`: construcción explícita de los datos de ejemplo.
- `Aurelius/Features`: pantallas, filas y formularios agrupados por funcionalidad.
- `Aurelius/Shared/Components`: tarjetas y badges reutilizables entre funcionalidades.
- `Aurelius/Shared/Editor`: editor de bloques y adaptación de PencilKit a SwiftUI.
- `AureliusTests`: pruebas de comportamiento del store.

## Flujo de datos

AureliusApp conserva el WorkspaceStore con `@State` y lo inyecta con
`.environment(store)`. Las pantallas lo leen con `@Environment(WorkspaceStore.self)`.
Observation actualiza las vistas que leen propiedades modificadas. Las operaciones
compartidas viven en el store; selección, foco y borradores de formularios son estado
local. Los bindings permiten editar un valor cuya fuente de verdad está en otro lugar.

Las extensiones del store separan responsabilidades en archivos, pero siguen siendo
el mismo tipo y la misma instancia. No son servicios independientes. Algunas vistas
existentes aún editan colecciones mediante bindings; cuando agreguemos persistencia,
esas escrituras también tendrán que participar en el mecanismo de guardado.

## Equivalencias con React

| React | SwiftUI / Swift |
| --- | --- |
| Componente | `struct TaskRow: View` con `var body: some View` |
| Props | Propiedades e inicializador de la vista |
| `useState` | `@State` para estado propiedad de la vista |
| Valor + callback de edición | `@Binding` para lectura y escritura compartidas |
| Context / `useContext` | `.environment(...)` / `@Environment` |
| Store reactivo | Clase `@Observable` |
| Bindings a propiedades del store | `@Bindable` cuando se necesitan valores `$...` |
| `.map()` para renderizar filas | `ForEach(tasks) { task in ... }` |
| `.map()`, `.filter()` sobre datos | Swift también tiene `map`, `filter` y `reduce` |
| `useEffect` | Según intención: `.task`, `.task(id:)`, `.onChange`, `.onAppear` |

No existe una traducción uno a uno de hooks. `.task` es adecuada para trabajo
asíncrono ligado a la vida de una vista; `.onChange` responde a cambios concretos.
`ForEach` necesita identidad estable: nuestras entidades tienen `id: UUID` y son
`Identifiable`, equivalente al propósito de `key` en una lista de React.

## Cómo crecer

1. Colocar una pantalla y sus componentes exclusivos en `Features/<Funcionalidad>`.
2. Mover componentes a `Shared` cuando los compartan funcionalidades distintas.
3. Mantener reglas compartidas y consultas fuera del `body` de las vistas.
4. Añadir un modelo observable de presentación si una pantalla incorpora flujos
   complejos, carga asíncrona, errores o coordinación que lo justifique.
5. Incorporar persistencia real detrás de operaciones explícitas del store cuando
   se defina el almacenamiento. Crear repositorios al existir una fuente de datos
   concreta (SwiftData, API, etc.) y probar guardado, carga y errores.

## Estado actual y límites

El workspace sigue en memoria y usa `WorkspaceStore.sample()` al iniciar la app.
`WorkspaceStore()` crea uno vacío para pruebas y futura carga real. No se ha agregado
persistencia: reiniciar la app restaura los ejemplos. Inbox también conserva su estado
local en memoria. Se retiró el modelo `Item` y el contenedor SwiftData de la plantilla,
que no almacenaban las entidades del workspace.

La adaptación actual de PencilKit utiliza UIKit. La ejecución verificada es iOS;
los destinos macOS anunciados en el proyecto requieren trabajo adicional de plataforma.

Referencia: https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app
