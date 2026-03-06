---
name: logisim-file-generation
description: Generate and repair Logisim-evolution `.circ` XML files for digital logic projects. Use when creating Logisim files from scratch, converting circuit descriptions into valid `.circ` structure, fixing malformed component/wire XML, or producing reusable starter templates for FIT3159-style logic exercises.
---

# Logisim File Generation

Use this skill to produce valid, loadable Logisim-evolution project XML with minimal trial-and-error. Prefer deterministic generation via script, then adjust manually only when needed.

## Quick Start

1. Build a starter project:
   - `python3 scripts/generate_circ.py --output ./my_circuit.circ`
2. Build from a JSON circuit specification:
   - `python3 scripts/generate_circ.py --spec ./spec.json --output ./my_circuit.circ`
3. Build from spec and auto-organize layout/routing:
   - `python3 scripts/generate_circ.py --spec ./spec.json --output ./my_circuit.circ --organize`
4. Open the result in Logisim-evolution and save once to normalize ordering/formatting.

## Workflow

1. Select generation mode:
   - Use template mode for a blank or minimal starter circuit.
   - Use spec mode when components/wires are already described in structured form.
   - Use `--organize` when you want cleaner placement and deterministic routing.
2. Load `references/file-format-cheatsheet.md` before manual XML editing.
3. Generate the `.circ` file with `scripts/generate_circ.py`.
4. Validate structure with this checklist:
   - Keep root as `<project version="1.0" source="...">`.
   - Ensure `#Base` library is present so Edit/Wiring tools are available.
   - Ensure each `<comp>` has `name` and `loc`.
   - Ensure each `<wire>` has `from` and `to`.
   - Ensure every referenced `lib` ID exists in `<lib .../>`.
   - Ensure gate sizes match your coordinates (port offsets depend on `size`):
     - `NOT Gate`: use `size=20` for worksheet-style spacing.
     - logic gates (`AND/OR/NAND/...`): use `size=30` for worksheet-style spacing.
   - Ensure Pin orientation matches the verified `1.circ` style:
     - left-side inputs: `facing=east`
     - right-side outputs: `facing=west` and `labelloc=east`
5. Open in Logisim-evolution; if it loads, save once and keep the normalized output.

## JSON Spec Rules

Use this high-level JSON schema for `--spec` input:

```json
{
  "source": "4.1.0",
  "main": "main",
  "layout": {
    "mode": "auto",
    "origin": "(100,100)",
    "column_gap": 140,
    "row_gap": 60,
    "grid": 10,
    "preserve_existing": true
  },
  "libraries": [
    { "name": "0", "desc": "#Wiring" },
    { "name": "1", "desc": "#Gates" }
  ],
  "circuits": [
    {
      "name": "main",
      "attributes": { "circuitnamedboxfixedsize": "false" },
      "components": [
        {
          "id": "A0",
          "lib": "0",
          "name": "Pin",
          "grid": { "column": 0, "row": 0 },
          "attrs": { "facing": "east", "type": "input" }
        }
      ],
      "connections": [
        {
          "from": { "id": "A0" },
          "to": { "point": "(240,100)" },
          "style": "manhattan"
        }
      ]
    }
  ]
}
```

Notes:
- `components[].id` is optional but strongly recommended for clean `connections`.
- `loc` and `grid` can be mixed; `loc` is exact, `grid` is auto-layout slot.
- `wires` supports raw points; `connections` supports point + component-id endpoints.
- endpoint objects support `anchor`, `dx`, `dy`, and `via` for controlled routing.
- `lib` supports ID (`"1"`), description (`"#Gates"`), or alias (`"gates"`, `"memory"`, etc.).
- unknown component names are allowed; generator passes `name`, `lib`, and attrs through.

## Component Coverage

The generator now supports broad Logisim-evolution component usage by design:
- accepts any component `name` (no restrictive whitelist),
- preserves arbitrary `attrs`,
- resolves libraries by ID, `#desc`, or alias,
- auto-adds missing built-in libraries when referenced by alias/desc.

For uncommon components, provide explicit `lib` + component-specific attributes from Logisim.

## Troubleshooting

- Missing library errors: add the missing `<lib name="...">` entry and keep IDs consistent.
- Invalid coordinate errors: rewrite points to `(x,y)` with integer values.
- Unknown top-level node errors: keep top-level nodes limited to known Logisim nodes.
- Pin compatibility issues in newer versions: prefer `type=input|output` and `behavior=...` style attributes.
- Pin appears mirrored/disconnected: for right-side outputs use `facing=west` plus `labelloc=east` (as in `1.circ`).
- Gate inputs disconnected: set explicit gate `size` values that match the routed coordinates (`NOT=20`, logic gates=30 for this style).
- File opens but feels uneditable: include `#Base` library (the generator now auto-adds it), plus default toolbar/mappings.
- Wrong logic from “connected-looking” wires: avoid sharing the same coordinate for independent nets; same coordinate means electrical connection.
- Layout looks messy: use `--organize` or add top-level `layout` with `grid`, `column_gap`, and `row_gap`.
