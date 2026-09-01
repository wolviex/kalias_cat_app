---
slug: flow
title: Key flows
role: key flows
updated: "2026-09-01T02:22:22"
---

# Key flows

## Typical play flow

```mermaid
sequenceDiagram
  participant P as Player
  participant R as Room
  participant C as Cat state
  participant G as Minigame / Calm activity
  participant S as Profile + Hive
  P->>R: Enter room and tap a cat or activity
  R->>C: Read hunger, energy, derived mood
  alt Care action
    P->>R: Feed or play
    R->>C: Update cat wellbeing and reaction
    R->>S: Award Heart Sparks and persist
  else Triggered learning activity
    R->>G: Route to matching minigame
    G->>S: Award Star Sparks and persist progress
    G->>C: Restore the triggering stat where applicable
  else Calm activity
    R->>G: Open Calm Corner or Mood Mirror
  end
  S-->>R: Queue trunk after each 100-XP cycle
```

## Important flows

- Onboarding creates the local player profile and selects a difficulty tier.
- The room computes cat moods from hunger and energy; those moods surface prompts and gate relevant minigames.
- Completing care or learning awards XP into a single Purr-gress cycle. Each completed cycle makes a trunk available; opening it adds an inventory reward that may be equipped.
- Calm Corner remains available independently of cat state and provides lower-stimulation breathing, sensory play, and mood check-in experiences.
