# Color Counter Changelog

This document tracks all notables changes to the Aseprite Color Counter plugin.

---

## 1.1.1

### Added

- If the active sprite has pixels selected, then only the colors in that zone are counted

---

## 1.1.0

### Added

- Stop the script if the number of colors detected is over 1000
  - Since the script tends to crash or freeze Aseprite if too many colors are inserted into the table
- Display the color counts in a dialog with the actual colors displayed
  - Colors are sorted by count in descending order

### Changed

- Hide console output when outside of debug mode
- Change error messages to be displayed as alerts

---

## 1.0.1

### Added

- Add warning message when the active sprite is very large and get confirmation from the user before continuing
  - Sprite is "very large" when it is made of 1.5 million pixels or more
- Stop script automatically if it runs for too long (2 min or more)

### Changed

- Improve plugin performance

### Fixed

- Show error message when active sprite is not in RGB mode

---

## 1.0.0

### Added

- Add plugin adds a command to Aseprite that counts and reports how much of each RGB color is used in the active sprite
  - Can set a shortcut to trigger the command quickly
  - Sprite must be in RGB mode otherwise RGB values are not reported to the script
  - Anything outside of pixel art or that is large with many colors will severely impact performance

---
