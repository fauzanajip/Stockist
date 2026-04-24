# Design System Document: Industrial Precision (Command Center Edition)

## 1. Overview & Creative North Star: "The Tactical Vanguard"
This design system is engineered for high-stakes, professional field operations where clarity, authority, and precision are paramount. Our Creative North Star is **Tactical Vanguard**—a philosophy that rejects decorative "fluff" in favor of utilitarian luxury. 

We embrace **Industrial Brutalism** through an editorial lens. By utilizing sharp geometry, all-caps typography, and clear interactive zones, we create a UI that feels less like software and more like a high-performance instrument. Everything is designed for the "Command Center" aesthetic—built for speed and absolute accuracy.

---

## 2. Colors: High-Contrast Authority (Dark Mode)
Our palette is rooted in deep, matte foundations with "Action" accents designed for maximum legibility.

*   **Primary (Tactical Navy):** Use `primary` (#287BE7) for high-level branding and core structural identity. This is the "Safety" color.
*   **Secondary (Action Orange):** Use `secondary` (#FF6D00) for critical interaction points. This is the "Warning/Action" color.
*   **Tertiary (Warning Yellow):** Use `tertiary` (#FFD600) for alerts and high-visibility status markers.
*   **Surface Hierarchy:**
    *   **Base:** `surface_container_lowest` (#0A0A0F) - Deepest neutral/True black-adjacent.
    *   **Main Content Area:** `surface` (#1B1B1F) - Industrial dark grey.
    *   **Interactive Cards:** `surface_container` (#25252A) - Slightly elevated grey-wash.

---

## 3. Typography: Tactical Manifest
We utilize **Inter** with a strict rule of **All-Caps** and **Weight w900** for all operational labels and headers to ensure authority and quick recognition.

*   **Headers & Labels:** Always all-caps, fontWeight: w900.
*   **Status Indicators:** Uppercase with +1.5px letter spacing to differentiate technical metadata from actionable text.
*   **Body Content:** High-density neutrals to ensure the focus remains on the data-filled tactical labels.

---

## 4. Geometry: Zero Radius Architecture
The core of "Industrial Precision" is the total rejection of rounded corners.

*   **The Zero Rule:** All containers, buttons, cards, and input fields MUST use `BorderRadius.zero`. Sharp edges convey the feeling of machined parts and professional tools.
*   **Borders:** Use thin `outline` strokes from `surface_container_high` (#2F2F35) to define territory instead of shadows.

---

## 5. Interaction Patterns: Tactical Flow

### Buttons (Tactical Switches)
*   **Shape:** Strictly rectangular (`borderRadius: 0`).
*   **Transitions:** Fast, subtle micro-animations that provide immediate physical feedback.
*   **Placement:** Fixed-bottom actions for critical operations.

### Data Entry (Telemetry Input)
*   **Input Fields:** Block-style inputs with high-contrast active borders (Action Orange).
*   **Separators:** Minimalist dots or faint lines to guide the eye without adding visual noise.

### Dialogues (Operational Overlays)
*   **Edit Records:** All master data and history edits must be performed using **ModalBottomSheets**. This maintains the "Environmental Layering" and keeps the user grounded in the current mission context.

---

## 6. Do's and Don'ts

### Do:
*   **Do** keep all edges sharp (BorderRadius: 0).
*   **Do** use All-Caps w900 for every tactical label.
*   **Do** use high-contrast status chips (READY, REVIEW, SYNCING).
*   **Do** prioritize information density.

### Don't:
*   **Don't** use `BorderRadius.circular`. Rounded corners are prohibited in the Command Center.
*   **Don't** use soft shadows. Rely on tonal shifts and sharp outlines.
*   **Don't** use title-case for headers. Force all-caps for maximum authority.
*   **Don't** add decorative white-space; every pixel must serve a tactical purpose.

---
**Director's Note:** Every pixel should feel forged, not grown. Keep the edges intentional, the hierarchy flat, and the interaction fast to support mission-critical operations.