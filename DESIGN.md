# Design System Document: Industrial Precision (Night Operations Edition)

## 1. Overview & Creative North Star: "The Tactical Vanguard"
This design system is engineered for the high-stakes, low-light, and physically demanding environments of nocturnal field operations. Our Creative North Star is **Tactical Vanguard**—a philosophy that rejects decorative "fluff" in favor of utilitarian luxury. 

We move beyond the "standard app" look by embracing **Industrial Brutalism** through an editorial lens. By utilizing intentional asymmetry, clear interactive zones, and a strict tonal layering system, we create a UI that feels less like software and more like a high-performance instrument. This is about clarity under moonlit conditions, reduction of eye strain, and authority in every pixel.

---

## 2. Colors: High-Contrast Authority (Dark Mode)
Our palette is rooted in deep, matte foundations with "Action" accents designed to remain legible and minimize glare in dark environments.

*   **Primary (Tactical Navy):** Use `primary` (#1A237E) for high-level branding and core structural identity. This is the "Safety" color.
*   **Secondary (Action Orange):** Use `secondary` (#FF6D00) for critical interaction points. This is the "Warning/Action" color.
*   **The "No-Line" Rule:** Boundaries are rarely defined by 1px solid lines. Use subtle background shifts to define territory. This creates a more rugged, integrated feel within the dark-mode environment.
*   **Surface Hierarchy & Nesting:** Use the `surface` tiers to create "Environmental Depth" for clear scanning.
    *   **Base:** `surface_container_lowest` (Deepest neutral/True black-adjacent)
    *   **Main Content Area:** `surface` (Industrial dark grey)
    *   **Interactive Cards:** `surface_container` (Slightly elevated grey-wash)
*   **The "Glass & Gradient" Rule:** For floating status bars, use medium-opacity surfaces with a backdrop blur. Apply a subtle linear gradient using `primary_color_hex` for hero backgrounds to provide "visual soul" without sacrificing low-light legibility.

---

## 3. Typography: The Command Scale
We utilize **Inter** for its mathematical precision and superior legibility. The hierarchy is designed to be "glanceable" and dense for professional efficiency.

*   **Display (The Indicator):** `display-lg` is reserved for critical telemetry data—numbers that must be read instantly (e.g., PSI, Voltage, Temperature).
*   **Headline (The Directive):** `headline-md` serves as the primary task header. It uses tight tracking (-0.02em) to feel authoritative and dense.
*   **Body (The Intelligence):** `body-lg` is the workhorse. We never go below `body-sm` to ensure readability for workers in the field using low-brightness displays.
*   **Label (The Meta):** `label-md` is always uppercase with +0.05em letter spacing to differentiate technical metadata from actionable text.

---

## 4. Elevation & Depth: Tonal Layering
In our dark-mode system, hierarchy is achieved through distinct value stepping rather than heavy drop shadows.

*   **The Layering Principle:** To lift a card, move from a darker surface to a slightly lighter or more saturated neutral. This mimics the look of machined parts being overlaid in a workshop.
*   **Shadows:** Shadows are largely avoided as they disappear in dark mode. Instead, use thin `outline` strokes or surface stepping to denote elevation.
*   **Density & Spacing:** With a spacing scale of **2 (Normal)**, the layout remains organized and efficient, balancing information density with touch-target safety.

---

## 5. Components: Machined Interaction

### Buttons (The Primary Tools)
*   **Primary:** Solid `primary` (#1A237E) with high-contrast text. Roundedness: `2` (Moderate radii). Height: Min 48px for professional accessibility.
*   **Secondary:** Ghost style or solid `secondary` (#FF6D00) for high-alert actions.
*   **Tactile State:** On press, the button should lighten or shift to a more saturated variant to provide immediate physical feedback against the dark background.

### Cards & Lists (Data Blocks)
*   **Forbid Dividers:** Minimize the use of lines. Use the Normal spacing (scale 2) or slight background shifts between `surface` tiers to separate content.
*   **Status Indicators:** Use `tertiary` (#FFD600) for warnings and `primary` (#1A237E) for confirmations. Icons must be 24px minimum.

### Input Fields (The Data Entry)
*   **Design:** Block-style inputs using `surface_container`. 
*   **Active State:** Use a 2px bottom-bar of `secondary` (#FF6D00) rather than a full-box highlight to maintain the "no-line" aesthetic.

---

## 6. Do's and Don'ts

### Do:
*   **Do** maintain high contrast between text and dark surfaces to ensure readability on dimmed screens.
*   **Do** lean into asymmetry. Left-align all typography but right-align critical status icons to create a clear "Scan Path."
*   **Do** use `on_surface_variant` for non-essential labels to keep the focus on `primary` data.

### Don't:
*   **Don't** use 1px borders as your primary means of containment. They look "cheap" and fragile in a rugged system.
*   **Don't** use pure black (#000000) for body text; use the high-density neutral (#1B1B1F) as a foundation to maintain professional tonality.
*   **Don't** center-align long blocks of text. In a field environment, left-justified text is the only way to ensure rapid reading.
*   **Don't** use overly aggressive corner radii. Stick to the `2` (Moderate) scale to maintain a balanced, engineered feel.

---
**Director's Note:** In this dark-mode environment, every pixel should feel forged, not grown. Keep the contrast high, the edges intentional, and the interaction fast to support operations in the shadows.