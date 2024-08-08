# Color Counter Changelog

This document tracks all notables changes to the Aseprite Color Counter plugin.

---

## 1.0.1

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
