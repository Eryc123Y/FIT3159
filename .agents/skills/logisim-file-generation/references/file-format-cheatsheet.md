# Logisim-evolution `.circ` XML Cheatsheet

Use this reference when manually editing generated `.circ` files.

## 1) Root Structure

Required top-level shape:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="1.0" source="4.1.0">
  <lib name="0" desc="#Wiring"/>
  <lib name="1" desc="#Gates"/>
  <main name="main"/>
  <circuit name="main">...</circuit>
</project>
```

## 2) Common Top-Level Nodes

- `<lib name="..." desc="..."/>`: define libraries and IDs.
- Include `#Base` library for edit tools (`Poke/Edit/Wiring/Text`).
- `<main name="..."/>`: choose default circuit opened first.
- `<circuit name="...">...</circuit>`: contain components and wires.
- Optional in richer files: `<options>`, `<mappings>`, `<toolbar>`, `<vhdl>`.

## 3) Components

Component format:

```xml
<comp lib="0" name="Pin" loc="(100,100)">
  <a name="facing" val="east"/>
  <a name="type" val="input"/>
</comp>
```

Notes:
- `lib` must match one `<lib name="...">`.
- `lib` in JSON spec can be provided as:
  - ID (`"1"`)
  - description (`"#Gates"`)
  - alias (`"gates"`, `"memory"`, `"io"`, etc.)
- `name` must match a tool/component in that library.
- `loc` should be integer coordinate in `(x,y)` format.
- Attributes are `<a name="..." val="..."/>`.
- Gate ports move with gate `size`; always set `size` explicitly when wires are hand-routed.
  - `NOT Gate`: `size="20"` for worksheet-style spacing.
  - `AND/OR/NAND/NOR/XOR/XNOR Gate`: `size="30"` for worksheet-style spacing.
- For worksheet-style decoder layouts matching `1.circ`:
  - left input pins: `facing="east"`
  - right output pins: `facing="west"` with `labelloc="east"`

### Auto-Organized Placement (JSON Spec)

Use top-level layout settings for cleaner generation:

```json
"layout": {
  "mode": "auto",
  "origin": "(100,100)",
  "column_gap": 140,
  "row_gap": 60,
  "grid": 10,
  "preserve_existing": true
}
```

Per-component placement hints:
- `id`: stable component identifier for connection routing.
- `grid.column` / `grid.row`: place by slot.
- `column` / `row` (or `stage` / `lane`): shorthand slot hints.
- `loc`: exact coordinate override.

## 4) Wires

Wire format:

```xml
<wire from="(100,100)" to="(140,100)"/>
```

Notes:
- Endpoints should be grid-aligned integer points.
- Zero-length wires are ignored by Logisim parser.
- If two independent nets share any coordinate, they become connected (junction).
- To cross without connecting, route one net around with a small offset.

### Endpoint Routing via `connections`

`connections` supports component-based endpoints:

```json
{
  "from": { "id": "A0", "anchor": "output" },
  "to": { "id": "G1", "anchor": "input1" },
  "style": "manhattan",
  "elbow": "horizontal-first",
  "via": [{ "point": "(200,120)" }]
}
```

Endpoint object fields:
- `id` / `component`: component id
- `anchor`: `loc`, `input`, `input2`, `output`, `left`, `right`, `up`, `down`
- `dx`, `dy`: integer offsets from anchor
- `point`: explicit `(x,y)` endpoint

## 5) Coordinates

Accepted by parser:
- `(100,100)`
- `100,100`
- `100 100`

Recommended canonical style:
- `(100,100)` only

## 6) Minimal Working Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="1.0" source="4.1.0">
  <lib name="0" desc="#Wiring"/>
  <lib name="1" desc="#Gates"/>
  <main name="main"/>
  <circuit name="main">
    <comp lib="0" name="Pin" loc="(100,100)">
      <a name="facing" val="east"/>
      <a name="type" val="input"/>
    </comp>
    <comp lib="1" name="NOT Gate" loc="(170,100)">
      <a name="size" val="20"/>
    </comp>
    <comp lib="0" name="Pin" loc="(240,100)">
      <a name="facing" val="west"/>
      <a name="labelloc" val="east"/>
      <a name="type" val="output"/>
    </comp>
    <wire from="(100,100)" to="(150,100)"/>
    <wire from="(170,100)" to="(240,100)"/>
  </circuit>
</project>
```

## 7) Validation Checklist

- Keep `project/version="1.0"`.
- Ensure every `comp@lib` references an existing library ID.
- Ensure every `comp` has `name` and `loc`.
- Ensure every `wire` has `from` and `to`.
- Keep only known top-level tags.
- Use `--organize` for cleaner sorting/routing when generation is messy.
- Open in Logisim-evolution and save once to normalize output.
