# Visual Builder - iPad Game Implementation Plan

## Context

We're building "Visual Builder," an iPad-only building challenge game designed for visually impaired users. Players build objects (house, kitchen, town, etc.) level by level using large, high-contrast pieces with rich audio feedback. The game has two modes: Free Play (relaxed) and Challenge Mode (timed, 1-4 players). The repository is empty — this is a greenfield project.

### Challenge Mode Multiplayer (1-4 Players)
- Default: 1 player. User can select 2-4 players before starting.
- **Turn-based**: Each player takes a turn on the same level, starting from level 1.
- Each player's completion time is recorded.
- **Fastest player on each level earns points** (1st = 3pts, 2nd = 2pts, 3rd = 1pt, 4th = 0pts).
- Players progress through levels together — all players complete a level before moving to the next.
- At the end of the session (when players decide to stop), the player with the **most points wins**.
- Between turns: "Player 2, it's your turn!" screen with hand-off prompt.

### Cinematic Level Narration
- Every level opens with a **cinematic voice narration** before gameplay begins.
- Narration is themed to the level — dramatic, funny, spooky, or exciting depending on context.
- **Multiple narrations per level**: Each level has 3-5 different intro narrations randomly selected each playthrough for replayability.
- Uses `AVSpeechSynthesizer` with custom voice/rate settings per level, or pre-recorded audio files.
- Examples:
  - Level 1 (House): *"Welcome, builder! Your first challenge awaits. Can you build the perfect house?"*
  - Level 1 (House, alt): *"Ah, a new architect arrives! Show me what kind of house you can build!"*
  - Level 13 (Castle): *"You dare enter the castle? Let's see if you can piece it together... mwahahaha!"*
  - Level 18 (Spaceship): *"Houston, we have a builder. Assemble your ship before liftoff!"*
- Narration text stored in each level's JSON (`narrationScripts` array with voice style hints).
- Player can skip narration with a tap, or replay it from settings.

### Progressive In-Game Narration
- **Mid-level narration triggers** fire as the player progresses:
  - 25% complete: Encouraging comment (*"Great start! Keep going!"*)
  - 50% complete: Themed mid-point comment (*"The house is taking shape!"*)
  - 75% complete: Excitement builds (*"Almost there, builder!"*)
  - 100% complete: Celebration narration (*"Magnificent! You built it!"*)
- Each trigger has 3+ random variants so it never feels repetitive.
- In Challenge Mode, **tension narration** triggers based on remaining time:
  - 50% time remaining: *"Halfway through the clock..."*
  - 25% time remaining: *"The clock is ticking, builder!"*
  - 10% time remaining: *"Hurry! Almost out of time!"*
  - Time expired: *"Oh no! Time's up!"*

### Challenge Mode Tension System
- **Visual**: Screen edges pulse with a subtle red/orange glow that intensifies as time runs low
- **Audio**: Background music tempo increases at 50%/25%/10% time remaining. Heartbeat sound at final 10 seconds.
- **Haptic**: Gentle pulses every second in last 10s, intensifying in the final 5s
- **Color shift**: HUD elements shift from calm blue → amber → red as time depletes

### Dynamic Level Variation System
- **Each playthrough feels fresh** — even though it's the same 20 levels, elements randomize:
  - **Color palettes**: Each piece type has 3-5 color variants randomly selected per session
  - **Materials/Textures**: Pieces have variant textures (e.g., brick wall, wood wall, stone wall)
  - **Layout variations**: Each level defines 2-3 alternative slot arrangements (same pieces, different positions)
  - **Piece order**: Piece tray order is shuffled each playthrough
  - **Bonus pieces**: Extra decorative pieces randomly appear (flower pots, weather vanes, etc.)
- Variation is stored in the JSON as `variants` arrays alongside the base definitions
- A seed system ensures multiplayer fairness: all players in the same session get the same variant

### Easter Egg System
- **Every level contains 2-3 hidden Easter eggs** discovered through specific actions:
  - **Tap Easter eggs**: Tap a specific empty spot 3 times → reveals a hidden animation/sound
  - **Sequence Easter eggs**: Place pieces in a specific order → triggers a special narration
  - **Speed Easter eggs**: Complete a level under a secret time threshold → bonus celebration
  - **Exploration Easter eggs**: Drag a piece to an unusual location → discover hidden content
- Easter egg types: Visual (hidden animations, color explosions), Audio (secret sounds, funny quotes), Narrative (special voice lines)
- Easter egg discovery tracked in `ProgressManager` — "X of 60 Easter eggs found"
- **Easter egg catalog** maintained in `Resources/EasterEggs/easter_egg_catalog.json` documenting every egg
- Discovering all eggs in a level unlocks a "Master Builder" badge for that level

**Tech Stack: Swift/SwiftUI + SpriteKit** — chosen for native VoiceOver integration, low-latency audio (AVFoundation), haptic feedback, Apple Pencil support, and Metal-backed 2D rendering.

---

## Architecture: MVVM + Coordinator

```
SwiftUI (Navigation & Menus) ←→ ViewModel ←→ Game State
         ↓                                        ↓
   SpriteKitView              ←→          SpriteKit Scene (gameplay)
```

- **SwiftUI** handles all menus, settings, level select, and HUD overlays
- **SpriteKit** (embedded via `SpriteView`) handles the building gameplay canvas
- **ViewModels** bridge state between SwiftUI and SpriteKit scenes
- **JSON-driven levels** loaded at runtime for easy content addition

---

## Project Structure

```
VisualBuilder/
├── VisualBuilder.xcodeproj
├── VisualBuilder/
│   ├── App/
│   │   ├── VisualBuilderApp.swift          # @main entry point
│   │   └── AppCoordinator.swift            # Navigation coordinator
│   ├── Models/
│   │   ├── Level.swift                     # Level data model (Codable)
│   │   ├── Piece.swift                     # Building piece model
│   │   ├── LevelVariant.swift              # Dynamic variation config
│   │   ├── NarrationScript.swift           # Narration model with variants
│   │   ├── EasterEgg.swift                 # Easter egg definition model
│   │   ├── Player.swift                    # Player model (name, score, times)
│   │   ├── GameSession.swift              # Multiplayer session state
│   │   ├── GameState.swift                 # Current game session state
│   │   └── PlayerProgress.swift            # Save/load progress
│   ├── ViewModels/
│   │   ├── MainMenuViewModel.swift
│   │   ├── LevelSelectViewModel.swift
│   │   ├── GameViewModel.swift             # Core game logic bridge
│   │   └── SettingsViewModel.swift
│   ├── Views/
│   │   ├── MainMenuView.swift              # Title screen, mode select
│   │   ├── PlayerSetupView.swift           # Choose 1-4 players, enter names
│   │   ├── LevelSelectView.swift           # Grid of 20 levels
│   │   ├── GameView.swift                  # SpriteKit + piece tray + HUD
│   │   ├── NarrationView.swift             # Cinematic level intro overlay
│   │   ├── PlayerTurnView.swift            # "Player X, your turn!" hand-off
│   │   ├── SettingsView.swift              # Accessibility & sound options
│   │   ├── LevelCompleteView.swift         # Celebration overlay
│   │   ├── ScoreboardView.swift            # Multiplayer scores & winner
│   │   └── Components/
│   │       ├── PieceTrayView.swift         # Large scrollable piece menu
│   │       ├── TimerView.swift             # Challenge mode countdown
│   │       └── AccessibleButton.swift      # Reusable large button
│   ├── Game/
│   │   ├── Scenes/
│   │   │   ├── BuildScene.swift            # Main SpriteKit building scene
│   │   │   └── CelebrationScene.swift      # Particle effects on completion
│   │   ├── Nodes/
│   │   │   ├── PieceNode.swift             # Draggable building piece
│   │   │   ├── SlotNode.swift              # Target placement position
│   │   │   └── GridNode.swift              # Building grid/template overlay
│   │   └── Systems/
│   │       ├── SnapSystem.swift            # Snap-to-grid logic
│   │       └── CollisionSystem.swift       # Piece overlap detection
│   ├── Services/
│   │   ├── AudioManager.swift              # Sound effects, music, narration
│   │   ├── NarrationEngine.swift           # Cinematic narration with random selection
│   │   ├── TensionManager.swift            # Challenge mode escalation (visual/audio/haptic)
│   │   ├── HapticManager.swift             # Haptic feedback patterns
│   │   ├── AccessibilityManager.swift      # VoiceOver announcements
│   │   ├── LevelLoader.swift               # JSON level parser + variant selection
│   │   ├── VariantEngine.swift             # Random variant selection with seed support
│   │   ├── EasterEggManager.swift          # Easter egg detection and reward triggering
│   │   └── ProgressManager.swift           # UserDefaults persistence (incl. Easter eggs found)
│   ├── Resources/
│   │   ├── Levels/                         # JSON level definitions
│   │   │   ├── level_01_house.json
│   │   │   ├── level_02_kitchen.json
│   │   │   └── ... (20 levels)
│   │   ├── Sounds/
│   │   │   ├── place_correct.wav
│   │   │   ├── place_wrong.wav
│   │   │   ├── level_complete.wav
│   │   │   ├── timer_tick.wav
│   │   │   └── timer_warning.wav
│   │   ├── Narration/                      # Pre-recorded or TTS scripts
│   │   ├── EasterEggs/
│   │   │   └── easter_egg_catalog.json     # Master list of all Easter eggs
│   │   └── Assets.xcassets/                # Images, colors, app icon
│   └── Extensions/
│       ├── Color+HighContrast.swift        # High-contrast color palette
│       └── View+Accessibility.swift        # Accessibility view modifiers
├── VisualBuilderTests/
└── VisualBuilderUITests/
```

---

## Level Data Format (JSON)

```json
{
  "id": 1,
  "name": "Build a House",
  "description": "Place the walls, roof, and door to build a cozy house",
  "challengeTime": 120,
  "gridSize": { "width": 6, "height": 8 },
  "backgroundTheme": "suburban",

  "narrationScripts": {
    "intros": [
      {
        "text": "Welcome, builder! Your very first challenge awaits. Can you build the perfect house?",
        "voiceStyle": "friendly_narrator",
        "rate": 0.5,
        "pitchMultiplier": 1.0
      },
      {
        "text": "Ah, a new architect arrives! Show me what kind of house you can build!",
        "voiceStyle": "excited_mentor",
        "rate": 0.5,
        "pitchMultiplier": 1.1
      },
      {
        "text": "Every great builder starts somewhere. Today, you build your first home!",
        "voiceStyle": "wise_narrator",
        "rate": 0.45,
        "pitchMultiplier": 0.9
      }
    ],
    "progress": {
      "25": ["Great start! The foundation looks solid.", "You're on your way, builder!"],
      "50": ["The house is taking shape!", "Halfway there — looking good!"],
      "75": ["Almost done! Just a few more pieces!", "So close! You can see it now!"],
      "100": ["Magnificent! You built it!", "Welcome home! What a beautiful house!"]
    },
    "tension": {
      "50": ["Halfway through the clock...", "Half your time is gone, keep moving!"],
      "25": ["The clock is ticking, builder!", "Time is running out!"],
      "10": ["Hurry! Almost out of time!", "Quick, quick, quick!"],
      "expired": ["Oh no! Time's up!", "The clock ran out... so close!"]
    }
  },

  "slotVariants": [
    {
      "variantId": "classic",
      "slots": [
        {
          "id": "wall_left",
          "position": { "x": 1, "y": 2 },
          "size": { "width": 1, "height": 3 },
          "acceptsPieceType": "wall",
          "label": "Left wall"
        },
        {
          "id": "roof",
          "position": { "x": 1, "y": 5 },
          "size": { "width": 4, "height": 2 },
          "acceptsPieceType": "roof",
          "label": "Roof"
        }
      ]
    },
    {
      "variantId": "wide_house",
      "slots": [
        {
          "id": "wall_left",
          "position": { "x": 0, "y": 2 },
          "size": { "width": 1, "height": 3 },
          "acceptsPieceType": "wall",
          "label": "Left wall"
        },
        {
          "id": "roof",
          "position": { "x": 0, "y": 5 },
          "size": { "width": 6, "height": 2 },
          "acceptsPieceType": "roof",
          "label": "Roof"
        }
      ]
    }
  ],

  "pieces": [
    {
      "id": "wall_piece_1",
      "type": "wall",
      "label": "Wall section",
      "size": { "width": 1, "height": 3 },
      "colorVariants": ["#FF6B35", "#8B4513", "#A0522D", "#CD853F"],
      "textureVariants": ["brick", "wood", "stone"]
    },
    {
      "id": "roof_piece",
      "type": "roof",
      "label": "Roof",
      "size": { "width": 4, "height": 2 },
      "colorVariants": ["#D32F2F", "#1565C0", "#2E7D32", "#6A1B9A"],
      "textureVariants": ["shingle", "tile", "thatch"]
    }
  ],

  "bonusPieces": [
    { "id": "flower_pot", "label": "Flower pot", "probability": 0.5 },
    { "id": "weather_vane", "label": "Weather vane", "probability": 0.3 },
    { "id": "welcome_mat", "label": "Welcome mat", "probability": 0.4 }
  ],

  "easterEggs": [
    {
      "id": "ee_house_chimney_tap",
      "type": "tap",
      "trigger": { "position": { "x": 4, "y": 7 }, "tapsRequired": 3 },
      "reward": {
        "type": "audio",
        "content": "A tiny voice says: 'Is anyone home?'"
      },
      "hint": "Tap the chimney area three times"
    },
    {
      "id": "ee_house_speed_demon",
      "type": "speed",
      "trigger": { "completionTimeUnder": 30 },
      "reward": {
        "type": "visual",
        "content": "House turns into a gingerbread house animation"
      },
      "hint": "Complete the house in under 30 seconds"
    }
  ]
}
```

---

## 20 Levels

| # | Name | Pieces | Time | Narration Style |
|---|------|--------|------|----------------|
| 1 | Build a House | 5 (walls, roof, door) | 120s | Friendly welcome |
| 2 | Build a Kitchen | 7 (fridge, stove, sink, counters) | 110s | Warm chef voice |
| 3 | Build a Garden | 8 (flowers, trees, fence, path) | 105s | Peaceful nature |
| 4 | Build a Playground | 6 (slide, swings, sandbox) | 100s | Excited kid energy |
| 5 | Build a School | 8 (building, windows, flag, bus) | 95s | Wise teacher |
| 6 | Build a Fire Station | 7 (truck, ladder, pole, building) | 90s | Urgent dispatcher |
| 7 | Build a Hospital | 8 (building, ambulance, cross, beds) | 85s | Caring doctor |
| 8 | Build a Farm | 10 (barn, animals, tractor, fence) | 80s | Country drawl |
| 9 | Build a Park | 9 (lake, bench, bridge, trees, ducks) | 75s | Relaxed ranger |
| 10 | Build a Zoo | 10 (cages, animals, paths, signs) | 70s | Safari guide |
| 11 | Build a Library | 8 (shelves, books, desk, chairs) | 65s | Whispering librarian |
| 12 | Build a Beach | 9 (umbrella, waves, sandcastle, boat) | 60s | Surfer dude |
| 13 | Build a Castle | 10 (towers, walls, drawbridge, flag) | 55s | Spooky villain |
| 14 | Build a Train Station | 9 (tracks, platform, train, clock) | 55s | Train conductor |
| 15 | Build a Space Station | 10 (modules, solar panels, antenna) | 50s | Mission control |
| 16 | Build an Airport | 11 (runway, planes, tower, terminal) | 50s | Pilot captain |
| 17 | Build an Aquarium | 10 (tanks, fish, coral, tunnels) | 45s | Deep sea diver |
| 18 | Build a Spaceship | 10 (hull, wings, engines, cockpit) | 45s | NASA countdown |
| 19 | Build a Town | 12 (buildings, roads, cars, signs) | 40s | Mayor speech |
| 20 | Build a City | 14 (skyscrapers, bridges, parks, transit) | 35s | Epic movie trailer |

---

## Core Systems

### 1. Game Engine (BuildScene.swift)
- SpriteKit scene with grid overlay showing slot positions
- Pieces dragged from tray into the scene
- **Snap-to-grid**: When a piece is within 40pt of a matching slot, it snaps into place
- **Validation**: Piece type must match slot's `acceptsPieceType`
- **Completion check**: All slots filled = level complete

### 2. Audio System (AudioManager.swift)
- `AVAudioEngine` for low-latency sound effects
- Sound categories: UI sounds, placement sounds, celebration, timer
- `AVSpeechSynthesizer` for dynamic narration (level instructions, piece names)
- Pre-loaded audio buffers for instant playback
- Key sounds: correct placement (chime), wrong placement (gentle buzz), level complete (fanfare), timer tick, timer warning (last 10s)

### 3. Accessibility System (AccessibilityManager.swift)
- All pieces and slots have VoiceOver labels and hints
- Custom VoiceOver actions: "Place piece" when focused on a slot
- `UIAccessibility.post(.announcement)` for game events
- High-contrast mode: Bold outlines, simplified colors from `Color+HighContrast.swift`
- Minimum touch target: 60x60pt (Apple recommends 44pt; we go larger)
- Alternative interaction: Tap piece in tray → tap target slot (no drag required)

### 4. Timer System (TimerView.swift + GameViewModel)
- `Timer.publish` in Combine for countdown
- Visual: Large countdown number with progress ring
- Audio: Tick sound every second in last 10s, warning sound at 5s
- Haptic: Gentle pulse every second in last 5s

### 5. Progress System (ProgressManager.swift)
- UserDefaults-backed (simple key-value, no CoreData needed)
- Stores: levels completed, stars earned, best times, settings preferences
- `@AppStorage` property wrappers in SwiftUI views

### 7. Multiplayer System (GameSession.swift + PlayerTurnView)
- `GameSession` tracks: player list, current player index, scores per level, total scores
- Turn flow: Narration → Player Turn Screen → Gameplay → Time recorded → Next player or level
- Scoring: 1st place = 3pts, 2nd = 2pts, 3rd = 1pt, 4th = 0pts (ties split points)
- `ScoreboardView` shows after each level (all players' times) and at session end (final winner)
- "End Session" button available at any time → shows final scoreboard with winner
- Single player mode: Same flow but no turn handoff, no scoreboard between levels

### 8. Cinematic Narration System (NarrationView.swift + AudioManager)
- Each level has a `narrationScript` in JSON with text, voice style, rate, pitch
- `NarrationView` displays level name + atmospheric background while narration plays
- Uses `AVSpeechSynthesizer` with per-level voice configuration
- Skip button (large, accessible) to bypass narration
- Narration auto-advances to gameplay when complete
- Voice styles mapped to `AVSpeechSynthesisVoice` presets (e.g., different locales for accents)

### 6. Haptic System (HapticManager.swift)
- `UIImpactFeedbackGenerator` for piece pickup/placement
- `UINotificationFeedbackGenerator` for success/failure
- `UISelectionFeedbackGenerator` for piece selection in tray

---

## Game Flow

### Single Player (Free Play)
1. Main Menu → Level Select → **Cinematic Narration** → Build → Level Complete → Next Level

### Multiplayer Challenge Mode
1. Main Menu → Challenge Mode → **Player Setup** (1-4 players, names) → Level Select
2. **Cinematic Narration** plays once per level (all players watch together)
3. **Player Turn Screen**: "Player 1, get ready!" → Countdown 3-2-1 → Build (timed)
4. Player completes → time recorded → **Player Turn Screen** for Player 2 → repeat
5. All players done → **Level Scoreboard** (times + points awarded)
6. Next level or **End Session** → **Final Scoreboard** (total points, winner crowned)

### Building Interaction
1. **Piece Tray** (bottom of screen): Large horizontally-scrollable cards showing available pieces
2. **Select**: Tap a piece card → piece highlights, VoiceOver announces "Wall section selected"
3. **Place (Tap)**: Tap a compatible slot → piece snaps into position
4. **Place (Drag)**: Drag piece from tray onto grid → snaps when near a matching slot
5. **Feedback**: Correct = chime + haptic + VoiceOver "Wall placed correctly!" / Wrong = buzz + shake
6. **Complete**: All slots filled → celebration scene (particles + fanfare)

---

## Implementation Phases

### Phase 1: Project Scaffold & Navigation (Files: 10)
- Create Xcode project structure (iPadOS 17+ target)
- `VisualBuilderApp.swift`, `AppCoordinator.swift`
- `MainMenuView.swift` with mode selection (Free Play / Challenge)
- `PlayerSetupView.swift` — choose 1-4 players, enter names
- `LevelSelectView.swift` with placeholder grid
- `SettingsView.swift` with toggle stubs
- `AccessibleButton.swift` component
- `Player.swift`, `GameSession.swift` models
- Basic navigation flow between all screens
- **Testable**: App launches, set up players, navigate between all screens

### Phase 2: Core Game Engine (Files: 10)
- `BuildScene.swift` with grid rendering
- `PieceNode.swift` with drag gesture handling
- `SlotNode.swift` with highlight/accept states
- `GridNode.swift` for template overlay
- `SnapSystem.swift` for snap-to-grid logic
- `GameView.swift` embedding SpriteKit via `SpriteView`
- `PieceTrayView.swift` with piece selection
- `GameViewModel.swift` bridging SwiftUI ↔ SpriteKit
- `Level.swift`, `Piece.swift` models
- Both tap-to-place AND drag-and-drop with equal support
- **Testable**: Can place pieces on grid, pieces snap, completion detected

### Phase 3: Level System, Narration & Dynamic Variation (Files: 12)
- `LevelLoader.swift` JSON parser with variant support
- `VariantEngine.swift` — randomly selects color palettes, textures, slot layouts, bonus pieces
- `NarrationEngine.swift` — randomly selects from intro narration pool, manages progress/tension narration
- `NarrationView.swift` — cinematic level intro overlay with skip button
- `level_01_house.json` through `level_05_school.json` (first 5 levels with full narration pools + variants)
- `GameState.swift` tracking current level progress
- `LevelVariant.swift`, `NarrationScript.swift` models
- Level completion detection and transition
- `LevelCompleteView.swift` overlay
- **Testable**: Play through 5 levels; each replay shows different colors/layouts/narrations

### Phase 4: Multiplayer & Scoring (Files: 5)
- `PlayerTurnView.swift` — "Player X, your turn!" hand-off screen
- `ScoreboardView.swift` — per-level results and session winner
- Turn rotation logic in `GameSession`
- Scoring system (3/2/1/0 points per level placement)
- "End Session" with final scoreboard and winner announcement
- **Testable**: 2-4 players take turns, scores tracked, winner declared

### Phase 5: Audio, Haptics, Tension & Accessibility (Files: 8)
- `AudioManager.swift` with AVAudioEngine + AVSpeechSynthesizer
- `TensionManager.swift` — visual pulse, tempo increase, haptic escalation as timer depletes
- `HapticManager.swift` with feedback patterns
- `EasterEggManager.swift` — detection logic for tap/sequence/speed/exploration eggs
- `EasterEgg.swift` model + `easter_egg_catalog.json` (master list of all 40-60 eggs)
- `AccessibilityManager.swift` with VoiceOver announcements
- `Color+HighContrast.swift` high-contrast palette
- `View+Accessibility.swift` modifiers
- Integrate audio/haptics/tension into all interactions; VoiceOver on everything
- **Testable**: Full VoiceOver walkthrough, tension escalation visible, Easter eggs discoverable

### Phase 6: Remaining Levels, Timer & Polish (Files: 25+)
- `level_06` through `level_20` JSON files (each with 3-5 narration variants, layout variants, Easter eggs)
- `TimerView.swift` Challenge Mode countdown
- `CelebrationScene.swift` particle effects
- `ProgressManager.swift` save/load with UserDefaults (levels, times, Easter eggs found)
- Star rating system (time-based in Challenge Mode)
- Easter egg tracker UI ("X of 60 found" + Master Builder badges)
- Polish: animations, transitions, background themes per level
- **Testable**: All 20 levels playable, dynamic variation on each replay, multiplayer end-to-end, all Easter eggs documented

---

## Key Design Decisions

1. **Both tap-to-place AND drag-and-drop equally supported**: Both get equal UI prominence. Tap piece → tap slot for accessibility; drag for traditional game feel.
2. **JSON levels**: Easy to add/modify content without code changes. Could support level packs later.
3. **No CoreData**: UserDefaults is sufficient for progress tracking (just level completions + settings).
4. **iPadOS 17+**: Gives access to latest SwiftUI features and accessibility APIs.
5. **AVAudioEngine over AVAudioPlayer**: Lower latency, supports multiple simultaneous sounds.

---

## Verification Plan

1. **Build & Run**: Each phase should produce a runnable app on iPad Simulator
2. **VoiceOver Testing**: Enable VoiceOver in Simulator → navigate entire game flow
3. **Audio Testing**: Verify all interactions produce appropriate sounds (requires device or audio-enabled simulator)
4. **Haptic Testing**: Requires physical iPad device
5. **Challenge Mode**: Verify timer counts down, game ends when time expires
6. **Progress**: Close and reopen app → verify level completion persists
7. **All 20 Levels**: Play through each level in both modes

---

## Important Note on Build Environment

This plan generates Swift/Xcode project files. Since we're working in a Linux environment without Xcode, we will:
- Create all Swift source files with correct structure
- Generate the Xcode project configuration files (`.xcodeproj/project.pbxproj`)
- Create all JSON level data files
- Create asset catalog stubs
- The project will be ready to open in Xcode on macOS for building and running
