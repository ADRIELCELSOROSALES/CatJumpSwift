# 🐱 CatJump iOS

![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-16%2B-blue?logo=apple)
![SpriteKit](https://img.shields.io/badge/SpriteKit-native-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Juego de plataformas vertical para iPhone, inspirado en el estilo Doodle Jump. El gato salta de plataforma en plataforma subiendo infinitamente mientras esquiva obstáculos, come pájaros y ratones para ganar vidas, y activa power-ups que desafían la física del juego. Cada sesión es distinta gracias a la generación procedural de contenido y un sistema de dificultad que escala con el score.

El proyecto nació como un porteo completo de una versión Android/Kotlin. Todo el motor de juego —física, colisiones, generación de contenido, cámara— fue reimplementado en Swift puro sin ningún game engine externo. Los gráficos del gato y los elementos del juego se dibujan en tiempo de ejecución con `SKShapeNode` y `CGPath`, sin una sola imagen de asset.

---

## Gameplay

El gato aparece en pantalla y cae libremente por gravedad hasta aterrizar en la primera plataforma, momento en que sale disparado hacia arriba automáticamente. Tocar la mitad izquierda de la pantalla mueve al gato a la izquierda; la mitad derecha lo mueve a la derecha. El gato envuelve los bordes horizontales de la pantalla de forma continua.

Las plataformas son de cuatro tipos: normales (siempre confiables), móviles (se desplazan horizontalmente), frágiles (desaparecen al primer contacto) y con resorte (lanzan al gato mucho más alto). Con el avance del nivel aparecen obstáculos: cactus estáticos, perros que patrullan, murciélagos y pájaros que vuelan, y ratones que rebotan. Los pájaros y ratones pueden comerse tocándolos, lo que engrosa al gato y otorga una vida extra cada cinco comidas. El perro emite un sonido especial al aparecer.

Los power-ups cambian la dinámica temporalmente: el jetpack impulsa al gato hacia arriba de forma sostenida durante 2,5 segundos sin depender de plataformas; las croquetas (kibble) otorgan tres super-saltos consecutivos con velocidad de lanzamiento mayor. Perder todas las vidas termina la partida y lleva a la pantalla de Game Over, donde el score se compara contra el récord guardado en el dispositivo y en Game Center.

---

## Tech Stack

| Capa | Tecnología | Rol |
|---|---|---|
| Renderizado | SpriteKit (`SKScene`, `SKShapeNode`, `SKNode`) | Árbol de nodos, animaciones, cámara virtual |
| Gráficos | `CGPath` + `CGContext` | Gato, plataformas, fondos degradados, todo procedural |
| Motor de juego | Swift puro (`struct GameState`) | Física, colisiones, generación, puntuación |
| Audio | AVFoundation (`AVAudioPlayer`) | Música de fondo en loop, efectos pre-cargados |
| Haptics | CoreHaptics / UIKit (`UIImpactFeedbackGenerator`) | Feedback táctil por evento de juego |
| Partículas | SpriteKit (`SKEmitterNode`, `.sks`) | Llamas del jetpack, efecto al comer obstáculos |
| Persistencia | `UserDefaults` | High score y skin seleccionada entre sesiones |
| Leaderboards | GameKit (`GKLeaderboard`) | Ranking global `catjump.highscore` |
| UI de menús | SpriteKit nativo (sin SwiftUI en escenas) | Todos los menús construidos con `SKLabelNode` y `SKShapeNode` |
| Entry point | SwiftUI (`@main`, `UIViewRepresentable`) | Puente entre SwiftUI lifecycle y SKView |

### Arquitectura

El patrón central es un **motor funcional puro**: `GameEngine.update(_ state: GameState) -> GameState` recibe el estado actual y devuelve el nuevo sin mutar nada ni producir side effects. Los efectos de sonido, haptics y transiciones de escena ocurren fuera del motor, en `GameScene`, que actúa como el coordinator entre el estado lógico y el árbol de nodos de SpriteKit.

Los nodos (`CatNode`, `PlatformNode`, etc.) son objetos tontos: reciben datos del estado y actualizan su representación visual. No guardan lógica de juego. El `ServiceContainer` (struct con lazy vars) distribuye las dependencias sin un contenedor de inyección externo.

---

## Arquitectura del proyecto

```
CatJump/
├── CatJumpApp.swift          # @main SwiftUI entry point, lifecycle (background/foreground)
├── ContentView.swift         # UIViewRepresentable bridge → SKView → MenuScene
│
├── Models/
│   ├── Cat.swift             # Estado del gato: posición, física, power-ups, vidas
│   ├── Platform.swift        # Plataforma con UUID estable para pool de nodos
│   ├── Obstacle.swift        # Obstáculo (5 tipos) con UUID
│   ├── PowerUp.swift         # Power-up (jetpack / kibble) con UUID
│   ├── GameState.swift       # Estado inmutable completo del juego + factory inicial
│   ├── CatSkin.swift         # 28 skins con colores, patrón y escala de cuerpo
│   └── SoundEvent.swift      # Enum de eventos de sonido/haptic emitidos por el motor
│
├── Game/
│   ├── GameConstants.swift   # Todas las constantes físicas y de gameplay
│   ├── DifficultyManager.swift  # Escala de dificultad por nivel/score
│   ├── PlatformGenerator.swift  # Generación procedural de plataformas, obstáculos, power-ups
│   ├── CollisionHandler.swift   # Detección de colisiones (plataformas, obstáculos, power-ups)
│   ├── GameEngine.swift      # Motor puro: 10 pasos, sin side effects
│   └── ServiceContainer.swift   # Contenedor de dependencias (struct + lazy vars)
│
├── Data/
│   └── ScoreStore.swift      # Persistencia UserDefaults (high score + skin seleccionada)
│
├── Audio/
│   ├── SoundManager.swift    # Singleton AVAudioPlayer, proceso de SoundEvents
│   └── HapticManager.swift   # Singleton UIImpactFeedbackGenerator / UINotificationFeedbackGenerator
│
├── GameCenter/
│   └── GameCenterManager.swift  # Autenticación, submit score, presentación de leaderboard
│
├── Nodes/
│   ├── CatNode.swift         # Gato dibujado con SKShapeNode (cuerpo, cabeza, orejas, bigotes, cola)
│   ├── PlatformNode.swift    # 4 tipos de plataforma dibujados proceduralmente
│   ├── ObstacleNode.swift    # 5 tipos de obstáculo dibujados proceduralmente
│   ├── PowerUpNode.swift     # Jetpack y kibble con animación de flotación
│   └── BackgroundNode.swift  # Degradados precacheados con CGContext, transición por score
│
└── Scenes/
    ├── MenuScene.swift       # Pantalla principal: título, gato animado, JUGAR / SKINS / RANKING
    ├── GameScene.swift       # Escena principal: game loop, HUD, pool de nodos, sync con GameState
    ├── GameOverScene.swift   # Score card, badge de récord, TRY AGAIN / MENU
    └── SkinScene.swift       # Grid scrollable de 28 skins con preview en tiempo real
```

---

## Features

- **28 skins de gato** completamente procedurales: cada skin define colores de cuerpo, vientre, ojos y patrón. Los patrones (tabby, tuxedo, calico, spotted, colorpoint, marbled, bicolor, solid) se dibujan con `SKShapeNode` y `CGPath` en tiempo de ejecución. Tres escalas de cuerpo: normal, chonky y slim.
- **4 tipos de plataformas**: normal, móvil, frágil y con resorte. Cada tipo tiene representación visual propia y comportamiento de físicas distinto.
- **5 tipos de obstáculos**: cactus, perro (con ladrido), murciélago, pájaro y ratón. Los dos últimos son comibles.
- **2 power-ups**: jetpack (vuelo sostenido 2,5s) y kibble (3 super-saltos consecutivos), ambos con aura visual en el gato y partículas de llama.
- **Sistema de gordura**: comer pájaros y ratones incrementa `cat.fatness` y otorga una vida extra cada 5 comidas.
- **Dificultad progresiva**: el `DifficultyManager` ajusta el gap entre plataformas, la velocidad de las móviles y la probabilidad de spawn de obstáculos a medida que sube el nivel (un nivel cada 1000 puntos).
- **Game Center Leaderboard**: autenticación automática al arrancar, submit del high score al terminar la partida, pantalla de ranking accesible desde el menú.
- **Haptics nativos**: impacto suave en cada salto, impacto fuerte al perder vida, notificación de éxito al activar power-up, notificación de error en game over.
- **Partículas SKEmitterNode**: llamas de jetpack bajo el gato mientras el power-up está activo, explosión dorada al comer un pájaro o ratón.
- **Fondo dinámico**: cuatro degradados que transicionan suavemente según el score —azul noche → azul cielo → morado atardecer → espacio profundo.

---

## Android → iOS: decisiones del porteo

| Aspecto | Android / Kotlin | iOS / Swift | Notas |
|---|---|---|---|
| **Renderizado** | Compose Canvas + `drawCircle` / `drawPath` | SpriteKit `SKShapeNode` + `CGPath` | Ambos son APIs de dibujo inmediato sobre un árbol de escena. La lógica de paths se tradujo casi 1:1. |
| **Game loop** | Coroutine con `delay(16)` en `LaunchedEffect` | `SKScene.update(_ currentTime:)` | SpriteKit garantiza 60 fps y pasa el timestamp; se eliminó la coroutine y el `delay` artificial. |
| **Persistencia** | Jetpack DataStore (Proto o Preferences) | `UserDefaults` | Misma semántica de clave-valor. Sin necesidad de Flow ni coroutines para lecturas síncronas en iOS. |
| **Audio** | `SoundPool` + `MediaPlayer` | `AVAudioPlayer` (x5 instancias) | `SoundPool` para efectos cortos, `MediaPlayer` para música. En iOS se unificó en `AVAudioPlayer` pre-cargado. |
| **Arquitectura de estado** | ViewModel + `StateFlow` / `MutableState` | `GameScene` + `ServiceContainer` | En Android el ViewModel sobrevive rotaciones. En iOS la escena es el coordinator y `GameState` es un struct inmutable pasado por el motor funcional. |

---

## Roadmap / Pendiente

- [ ] **Archivos de audio**: agregar al bundle los archivos `salto.mp3`, `loselife.mp3`, `musicloop.mp3`, `gameover.mp3`, `aparicionperro.mp3` y `aparicionperroperro.mp3`. Sin ellos el juego funciona pero en silencio.
- [ ] **Partículas `.sks`**: crear `JetpackFlame.sks` y `EatEffect.sks` desde **File → New → SpriteKit Particle File** en Xcode con los parámetros documentados en el código. Sin los archivos las partículas no aparecen (no hay crash; el código usa optional binding).
- [ ] **Game Center en App Store Connect**: activar la capability **Game Center** en el target de Xcode y crear el leaderboard con ID `catjump.highscore` en la consola de App Store Connect para que el submit de scores funcione en producción.
- [ ] **Sistema de compra de skins**: actualmente todas las skins son accesibles desde el inicio. Implementar el flujo de compra con el precio definido en cada `CatSkin.price` (en unidades de "fichas de pez").
- [ ] **Modo tablet / landscape**: el diseño de UI y la generación de plataformas asumen pantalla vertical de iPhone. Soporte iPad requeriría ajustar el layout del menú y los gaps de plataformas para pantallas más anchas.
- [ ] **TestFlight / distribución**: configurar el provisioning profile de distribución y el pipeline de CI para generar builds de TestFlight automáticamente desde la rama `main`.

---

Desarrollado por **Adriel Celso Rosales**
