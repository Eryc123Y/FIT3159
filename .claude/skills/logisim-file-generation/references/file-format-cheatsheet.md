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
- `name` must match a tool/component in that library.
- `loc` should be integer coordinate in `(x,y)` format.
- Attributes are `<a name="..." val="..."/>`.

## 4) Wires

Wire format:

```xml
<wire from="(100,100)" to="(140,100)"/>
```

Notes:
- Endpoints should be grid-aligned integer points.
- Zero-length wires are ignored by Logisim parser.

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
    <comp lib="1" name="NOT Gate" loc="(170,100)"/>
    <comp lib="0" name="Pin" loc="(240,100)">
      <a name="facing" val="west"/>
      <a name="type" val="output"/>
    </comp>
    <wire from="(100,100)" to="(140,100)"/>
    <wire from="(200,100)" to="(240,100)"/>
  </circuit>
</project>
```

## 7) Validation Checklist

- Keep `project/version="1.0"`.
- Ensure every `comp@lib` references an existing library ID.
- Ensure every `comp` has `name` and `loc`.
- Ensure every `wire` has `from` and `to`.
- Keep only known top-level tags.
- Open in Logisim-evolution and save once to normalize output.
