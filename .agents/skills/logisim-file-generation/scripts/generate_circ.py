#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Literal


DEFAULT_MINIMAL_LIBRARIES = [
    {"name": "0", "desc": "#Wiring"},
    {"name": "1", "desc": "#Gates"},
]

DEFAULT_FULL_LIBRARIES = [
    {"name": "0", "desc": "#Wiring"},
    {"name": "1", "desc": "#Gates"},
    {"name": "2", "desc": "#Plexers"},
    {"name": "3", "desc": "#Arithmetic"},
    {"name": "D", "desc": "#FPArithmetic"},
    {"name": "4", "desc": "#Memory"},
    {"name": "5", "desc": "#I/O"},
    {"name": "A", "desc": "#TTL"},
    {"name": "7", "desc": "#TCL"},
    {"name": "8", "desc": "#Base"},
    {"name": "9", "desc": "#BFH-Praktika"},
    {"name": "B", "desc": "#Input/Output-Extra"},
    {"name": "C", "desc": "#Soc"},
]

CANONICAL_LIBRARY_ID_BY_DESC = {library["desc"]: library["name"] for library in DEFAULT_FULL_LIBRARIES}
LIBRARY_ALIAS_TO_DESC = {
    "wiring": "#Wiring",
    "gates": "#Gates",
    "plexers": "#Plexers",
    "arithmetic": "#Arithmetic",
    "fparithmetic": "#FPArithmetic",
    "memory": "#Memory",
    "io": "#I/O",
    "i/o": "#I/O",
    "ttl": "#TTL",
    "tcl": "#TCL",
    "base": "#Base",
    "bfh-praktika": "#BFH-Praktika",
    "input/output-extra": "#Input/Output-Extra",
    "soc": "#Soc",
}

POINT_PATTERN = re.compile(r"^\s*\(?\s*(-?\d+)\s*[,\s]\s*(-?\d+)\s*\)?\s*$")
INPUT_ANCHOR_PATTERN = re.compile(r"^input(?P<index>\d+)?$")


@dataclass(frozen=True, order=True)
class Point:
    x: int
    y: int

    def as_text(self) -> str:
        return f"({self.x},{self.y})"

    def snapped(self, grid: int) -> "Point":
        if grid <= 1:
            return self
        return Point(x=int(round(self.x / grid) * grid), y=int(round(self.y / grid) * grid))


@dataclass
class ComponentRecord:
    component_id: str
    name: str
    lib: str | None
    attrs: dict[str, Any]
    loc: Point | None
    column_hint: int | None
    row_hint: int | None


@dataclass(frozen=True)
class LayoutConfig:
    mode: Literal["manual", "auto"]
    origin: Point
    column_gap: int
    row_gap: int
    grid: int
    preserve_existing: bool
    sort_elements: bool
    snap_existing_points: bool


@dataclass
class CircuitRecord:
    name: str
    attributes: dict[str, Any]
    components: list[ComponentRecord]
    wires: list[tuple[Point, Point]]


class LibraryRegistry:
    def __init__(self, libraries: list[dict[str, str]]):
        self._libraries: list[dict[str, str]] = []
        self._by_name: dict[str, str] = {}
        self._by_desc_lower: dict[str, str] = {}
        for library in libraries:
            self._register(library["name"], library["desc"])

    def _register(self, name: str, desc: str) -> None:
        self._libraries.append({"name": name, "desc": desc})
        self._by_name[name] = desc
        self._by_desc_lower[desc.lower()] = name

    def all(self) -> list[dict[str, str]]:
        return list(self._libraries)

    def find_name_by_desc(self, desc: str) -> str | None:
        return self._by_desc_lower.get(desc.lower())

    def find_desc_by_name(self, name: str | None) -> str | None:
        if name is None:
            return None
        return self._by_name.get(name)

    def ensure_desc(self, desc: str) -> str:
        normalized_desc = desc.strip()
        if not normalized_desc.startswith("#"):
            normalized_desc = f"#{normalized_desc}"

        existing_name = self.find_name_by_desc(normalized_desc)
        if existing_name is not None:
            return existing_name

        canonical_name = CANONICAL_LIBRARY_ID_BY_DESC.get(normalized_desc)
        if canonical_name is not None and canonical_name not in self._by_name:
            self._register(canonical_name, normalized_desc)
            return canonical_name

        new_name = choose_available_library_name(self._libraries)
        self._register(new_name, normalized_desc)
        return new_name

    def resolve(self, raw_library: Any, field_name: str) -> str:
        if not isinstance(raw_library, str) or not raw_library.strip():
            raise ValueError(f"{field_name} must be a non-empty string")

        library_ref = raw_library.strip()
        if library_ref in self._by_name:
            return library_ref

        desc_name = self.find_name_by_desc(library_ref)
        if desc_name is not None:
            return desc_name

        alias = library_ref.lower()
        if alias.startswith("#"):
            alias = alias[1:]

        desc_from_alias = LIBRARY_ALIAS_TO_DESC.get(alias)
        if desc_from_alias is not None:
            return self.ensure_desc(desc_from_alias)

        if library_ref.startswith("#"):
            return self.ensure_desc(library_ref)

        raise ValueError(
            f"{field_name}='{raw_library}' is unknown. Use a known lib ID, '#Library', or alias."
        )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate a Logisim-evolution .circ XML file from template or JSON spec."
    )
    parser.add_argument(
        "--output",
        "-o",
        required=True,
        help="Output .circ path",
    )
    parser.add_argument(
        "--spec",
        "-s",
        help="Optional JSON spec path. If omitted, generate a minimal starter circuit.",
    )
    parser.add_argument(
        "--main-circuit",
        default="main",
        help="Main circuit name when --spec is omitted (default: main)",
    )
    parser.add_argument(
        "--source",
        default="4.1.0",
        help="Source version attribute for <project> (default: 4.1.0)",
    )
    parser.add_argument(
        "--library-set",
        choices=["minimal", "full"],
        default="minimal",
        help="Library set used when --spec is omitted (default: minimal)",
    )
    parser.add_argument(
        "--organize",
        action="store_true",
        help=(
            "Enable auto-organization: auto-place components lacking loc, "
            "snap to grid, manhattan-route connection segments, and sort XML elements."
        ),
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite output file if it already exists",
    )
    return parser.parse_args()


def parse_int(value: Any, field_name: str, *, minimum: int | None = None) -> int:
    if isinstance(value, bool) or not isinstance(value, int):
        raise ValueError(f"{field_name} must be an integer")
    if minimum is not None and value < minimum:
        raise ValueError(f"{field_name} must be >= {minimum}")
    return value


def parse_bool(value: Any, field_name: str) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value != 0
    if isinstance(value, str):
        lowered = value.strip().lower()
        if lowered in {"true", "1", "yes", "y", "on"}:
            return True
        if lowered in {"false", "0", "no", "n", "off"}:
            return False
    raise ValueError(f"{field_name} must be a boolean")


def parse_point(raw: Any, field_name: str) -> Point:
    if isinstance(raw, Point):
        return raw

    if isinstance(raw, str):
        match = POINT_PATTERN.match(raw)
        if match:
            return Point(x=int(match.group(1)), y=int(match.group(2)))
        raise ValueError(
            f"{field_name}='{raw}' is invalid; expected integer point like '(x,y)'"
        )

    if isinstance(raw, (list, tuple)) and len(raw) == 2:
        x_raw, y_raw = raw
        if isinstance(x_raw, bool) or isinstance(y_raw, bool):
            raise ValueError(f"{field_name} list point values must be integers")
        if isinstance(x_raw, int) and isinstance(y_raw, int):
            return Point(x=x_raw, y=y_raw)
        raise ValueError(f"{field_name} list point values must be integers")

    if isinstance(raw, dict):
        if "point" in raw:
            return parse_point(raw["point"], f"{field_name}.point")
        if "x" in raw and "y" in raw:
            x_raw = raw["x"]
            y_raw = raw["y"]
            if isinstance(x_raw, bool) or isinstance(y_raw, bool):
                raise ValueError(f"{field_name} point x/y must be integers")
            if isinstance(x_raw, int) and isinstance(y_raw, int):
                return Point(x=x_raw, y=y_raw)
            raise ValueError(f"{field_name} point x/y must be integers")

    raise ValueError(
        f"{field_name} must be a point string '(x,y)', [x,y], or object with x/y"
    )


def add_attr(parent: ET.Element, name: str, value: Any) -> None:
    attr = ET.SubElement(parent, "a")
    attr.set("name", str(name))
    attr.set("val", str(value))


def normalize_component_attrs(component_name: str, attrs: dict[str, Any]) -> dict[str, Any]:
    normalized = dict(attrs)

    if component_name == "NOT Gate" and "size" not in normalized:
        normalized["size"] = "20"

    narrow_multi_input_gates = {
        "AND Gate",
        "NAND Gate",
        "OR Gate",
        "NOR Gate",
        "XOR Gate",
        "XNOR Gate",
    }
    if component_name in narrow_multi_input_gates and "size" not in normalized:
        normalized["size"] = "30"

    if component_name != "Pin":
        return normalized

    legacy_output = normalized.get("output")
    if "type" not in normalized and legacy_output is not None:
        legacy_value = str(legacy_output).strip().lower()
        normalized["type"] = "output" if legacy_value == "true" else "input"
        normalized.pop("output", None)

    pin_type = str(normalized.get("type", "")).strip().lower()
    if "facing" not in normalized:
        normalized["facing"] = "west" if pin_type == "output" else "east"

    if pin_type == "output" and "labelloc" not in normalized:
        normalized["labelloc"] = "east"

    if pin_type == "input" and "behavior" not in normalized:
        normalized["behavior"] = "simple"

    return normalized


def normalize_libraries(raw_libraries: Any) -> list[dict[str, str]]:
    if raw_libraries is None:
        return list(DEFAULT_MINIMAL_LIBRARIES)
    if not isinstance(raw_libraries, list):
        raise ValueError("libraries must be a list")

    libraries: list[dict[str, str]] = []
    seen_names: set[str] = set()
    for idx, entry in enumerate(raw_libraries):
        if not isinstance(entry, dict):
            raise ValueError(f"libraries[{idx}] must be an object")
        name = entry.get("name")
        desc = entry.get("desc")
        if not isinstance(name, str) or not name:
            raise ValueError(f"libraries[{idx}].name must be a non-empty string")
        if not isinstance(desc, str) or not desc:
            raise ValueError(f"libraries[{idx}].desc must be a non-empty string")
        if name in seen_names:
            raise ValueError(f"Duplicate library name '{name}'")
        seen_names.add(name)
        libraries.append({"name": name, "desc": desc})
    return libraries


def choose_available_library_name(libraries: list[dict[str, str]]) -> str:
    used = {library["name"] for library in libraries}
    for candidate in ("9", "8", "A", "B", "C"):
        if candidate not in used:
            return candidate
    number = 0
    while str(number) in used:
        number += 1
    return str(number)


def ensure_base_library(registry: LibraryRegistry) -> None:
    registry.ensure_desc("#Base")


def infer_library_desc_from_component(component_name: str, attrs: dict[str, Any]) -> str | None:
    lower_name = component_name.lower()

    if lower_name == "pin":
        return "#Wiring"
    if lower_name in {"clock", "constant", "probe", "tunnel", "bit extender", "splitter"}:
        return "#Wiring"
    if lower_name.endswith(" gate"):
        return "#Gates"
    if any(keyword in lower_name for keyword in ("mux", "demux", "decoder", "encoder")):
        return "#Plexers"
    if any(
        keyword in lower_name
        for keyword in ("adder", "subtractor", "multiplier", "divider", "comparator", "shifter")
    ):
        return "#Arithmetic"
    if any(
        keyword in lower_name
        for keyword in ("ram", "rom", "register", "counter", "flip-flop", "latch")
    ):
        return "#Memory"
    if any(
        keyword in lower_name
        for keyword in ("led", "button", "keyboard", "tty", "hex digit", "seven-segment")
    ):
        return "#I/O"
    if lower_name.startswith("74") or "ttl" in lower_name:
        return "#TTL"

    explicit_type = attrs.get("type")
    if isinstance(explicit_type, str) and explicit_type.lower() in {"input", "output"}:
        return "#Wiring"
    return None


def parse_layout_config(raw_layout: Any, organize_flag: bool) -> LayoutConfig:
    if raw_layout is None:
        return LayoutConfig(
            mode="auto" if organize_flag else "manual",
            origin=Point(100, 100),
            column_gap=140,
            row_gap=60,
            grid=10,
            preserve_existing=True,
            sort_elements=organize_flag,
            snap_existing_points=organize_flag,
        )

    if not isinstance(raw_layout, dict):
        raise ValueError("layout must be an object if provided")

    mode_raw = raw_layout.get("mode", "auto" if organize_flag else "manual")
    if not isinstance(mode_raw, str):
        raise ValueError("layout.mode must be 'manual' or 'auto'")
    mode = mode_raw.strip().lower()
    if mode not in {"manual", "auto"}:
        raise ValueError("layout.mode must be 'manual' or 'auto'")

    origin = parse_point(raw_layout.get("origin", "(100,100)"), "layout.origin")
    column_gap = parse_int(raw_layout.get("column_gap", 140), "layout.column_gap", minimum=10)
    row_gap = parse_int(raw_layout.get("row_gap", 60), "layout.row_gap", minimum=10)
    grid = parse_int(raw_layout.get("grid", 10), "layout.grid", minimum=1)
    preserve_existing = parse_bool(raw_layout.get("preserve_existing", True), "layout.preserve_existing")
    sort_elements = parse_bool(raw_layout.get("sort_elements", organize_flag), "layout.sort_elements")
    snap_existing_points = parse_bool(
        raw_layout.get("snap_existing_points", organize_flag), "layout.snap_existing_points"
    )

    return LayoutConfig(
        mode=mode,
        origin=origin,
        column_gap=column_gap,
        row_gap=row_gap,
        grid=grid,
        preserve_existing=preserve_existing,
        sort_elements=sort_elements,
        snap_existing_points=snap_existing_points,
    )


def parse_component_hints(component_data: dict[str, Any], idx: int) -> tuple[int | None, int | None]:
    column_hint: int | None = None
    row_hint: int | None = None

    grid_data = component_data.get("grid")
    if grid_data is not None:
        if not isinstance(grid_data, dict):
            raise ValueError(f"components[{idx}].grid must be an object")
        if "column" in grid_data:
            column_hint = parse_int(grid_data["column"], f"components[{idx}].grid.column")
        if "row" in grid_data:
            row_hint = parse_int(grid_data["row"], f"components[{idx}].grid.row")

    if "column" in component_data:
        column_hint = parse_int(component_data["column"], f"components[{idx}].column")
    if "stage" in component_data:
        column_hint = parse_int(component_data["stage"], f"components[{idx}].stage")
    if "row" in component_data:
        row_hint = parse_int(component_data["row"], f"components[{idx}].row")
    if "lane" in component_data:
        row_hint = parse_int(component_data["lane"], f"components[{idx}].lane")
    return column_hint, row_hint


def parse_components(
    raw_components: Any,
    circuit_name: str,
    registry: LibraryRegistry,
    layout: LayoutConfig,
) -> list[ComponentRecord]:
    if raw_components is None:
        return []
    if not isinstance(raw_components, list):
        raise ValueError(f"circuit '{circuit_name}' components must be a list")

    records: list[ComponentRecord] = []
    seen_ids: set[str] = set()

    for idx, component_data in enumerate(raw_components):
        if not isinstance(component_data, dict):
            raise ValueError(f"circuit '{circuit_name}' components[{idx}] must be an object")

        component_name = component_data.get("name")
        if not isinstance(component_name, str) or not component_name:
            raise ValueError(
                f"circuit '{circuit_name}' components[{idx}].name must be a non-empty string"
            )

        attrs = component_data.get("attrs", {})
        if attrs is None:
            attrs = {}
        if not isinstance(attrs, dict):
            raise ValueError(f"circuit '{circuit_name}' components[{idx}].attrs must be an object")
        normalized_attrs = normalize_component_attrs(component_name, attrs)

        raw_library = component_data.get("lib")
        resolved_library: str | None = None
        if raw_library is not None:
            resolved_library = registry.resolve(raw_library, f"components[{idx}].lib")
        else:
            inferred_desc = infer_library_desc_from_component(component_name, normalized_attrs)
            if inferred_desc is not None:
                resolved_library = registry.ensure_desc(inferred_desc)

        loc: Point | None = None
        if component_data.get("loc") is not None:
            loc = parse_point(component_data["loc"], f"components[{idx}].loc")
            if layout.snap_existing_points:
                loc = loc.snapped(layout.grid)

        component_id_raw = component_data.get("id", f"c{idx}")
        if not isinstance(component_id_raw, str) or not component_id_raw:
            raise ValueError(f"circuit '{circuit_name}' components[{idx}].id must be a non-empty string")
        if component_id_raw in seen_ids:
            raise ValueError(f"circuit '{circuit_name}' contains duplicate component id '{component_id_raw}'")
        seen_ids.add(component_id_raw)

        column_hint, row_hint = parse_component_hints(component_data, idx)
        records.append(
            ComponentRecord(
                component_id=component_id_raw,
                name=component_name,
                lib=resolved_library,
                attrs=normalized_attrs,
                loc=loc,
                column_hint=column_hint,
                row_hint=row_hint,
            )
        )

    return records


def classify_component_column(component: ComponentRecord, registry: LibraryRegistry) -> int:
    name_lower = component.name.lower()

    if name_lower == "pin":
        pin_type = str(component.attrs.get("type", "input")).strip().lower()
        return 4 if pin_type == "output" else 0

    if name_lower in {"clock", "constant"}:
        return 0
    if name_lower == "not gate":
        return 1

    desc = registry.find_desc_by_name(component.lib)
    if desc == "#Wiring":
        return 0
    if desc in {"#Gates", "#Plexers", "#Arithmetic", "#FPArithmetic", "#Memory", "#TTL"}:
        return 2
    if desc in {"#I/O", "#Input/Output-Extra"}:
        return 3

    if name_lower.endswith(" gate"):
        return 2
    return 2


def apply_component_layout(
    components: list[ComponentRecord], registry: LibraryRegistry, layout: LayoutConfig
) -> None:
    used_rows_by_column: dict[int, set[int]] = {}

    for component in components:
        if component.loc is None:
            continue
        if component.column_hint is not None:
            column = component.column_hint
        else:
            column = int(round((component.loc.x - layout.origin.x) / layout.column_gap))
        if component.row_hint is not None:
            row = component.row_hint
        else:
            row = int(round((component.loc.y - layout.origin.y) / layout.row_gap))
        used_rows_by_column.setdefault(column, set()).add(row)

    next_row_by_column: dict[int, int] = {
        column: (max(rows) + 1 if rows else 0)
        for column, rows in used_rows_by_column.items()
    }

    for component in components:
        if (
            component.loc is not None
            and layout.preserve_existing
            and (layout.mode == "manual" or layout.mode == "auto")
        ):
            continue

        column = (
            component.column_hint
            if component.column_hint is not None
            else classify_component_column(component, registry)
        )
        if component.row_hint is not None:
            row = component.row_hint
        else:
            row = next_row_by_column.get(column, 0)
            next_row_by_column[column] = row + 1

        raw_point = Point(
            x=layout.origin.x + column * layout.column_gap,
            y=layout.origin.y + row * layout.row_gap,
        )
        component.loc = raw_point.snapped(layout.grid)
        used_rows_by_column.setdefault(column, set()).add(row)

    missing_locations = [component.component_id for component in components if component.loc is None]
    if missing_locations:
        raise ValueError(f"Components missing location after layout: {', '.join(missing_locations)}")


def parse_positive_size(value: Any, fallback: int) -> int:
    if isinstance(value, bool):
        return fallback
    if isinstance(value, int) and value > 0:
        return value
    if isinstance(value, str):
        cleaned = value.strip()
        if cleaned.isdigit():
            number = int(cleaned)
            if number > 0:
                return number
    return fallback


def get_component_anchor(component: ComponentRecord, anchor_name: str) -> Point:
    if component.loc is None:
        raise ValueError(f"Component '{component.component_id}' has no location")

    anchor = anchor_name.strip().lower()
    if anchor in {"", "loc", "center", "port", "default"}:
        return component.loc

    size = parse_positive_size(component.attrs.get("size"), 30)
    name_lower = component.name.lower()

    if name_lower == "not gate":
        if anchor in {"input", "in", "left", "west"}:
            return Point(component.loc.x - size, component.loc.y)
        if anchor in {"output", "out", "right", "east"}:
            return component.loc

    if name_lower.endswith(" gate"):
        if anchor in {"output", "out", "right", "east"}:
            return component.loc

        input_match = INPUT_ANCHOR_PATTERN.match(anchor)
        if anchor in {"input", "in", "left", "west"} or input_match:
            input_count = parse_positive_size(component.attrs.get("inputs"), 2)
            if input_match and input_match.group("index") is not None:
                index = max(int(input_match.group("index")) - 1, 0)
            else:
                index = 0
            if input_count <= 1:
                offset_y = 0
            elif input_count == 2:
                offset_y = -10 if index <= 0 else 10
            else:
                spacing = max(size // max(input_count - 1, 1), 6)
                start = -spacing * (input_count - 1) // 2
                offset_y = start + spacing * min(index, input_count - 1)
            return Point(component.loc.x - size, component.loc.y + offset_y)

    if anchor in {"left", "west"}:
        return Point(component.loc.x - size, component.loc.y)
    if anchor in {"right", "east"}:
        return Point(component.loc.x + size, component.loc.y)
    if anchor in {"up", "north", "top"}:
        return Point(component.loc.x, component.loc.y - size)
    if anchor in {"down", "south", "bottom"}:
        return Point(component.loc.x, component.loc.y + size)

    raise ValueError(
        f"Unknown anchor '{anchor_name}' for component '{component.component_id}'."
    )


def resolve_endpoint(
    raw_endpoint: Any,
    field_name: str,
    components_by_id: dict[str, ComponentRecord],
    layout: LayoutConfig,
) -> Point:
    if isinstance(raw_endpoint, str):
        if POINT_PATTERN.match(raw_endpoint):
            point = parse_point(raw_endpoint, field_name)
            return point.snapped(layout.grid) if layout.snap_existing_points else point
        component = components_by_id.get(raw_endpoint)
        if component is None:
            raise ValueError(
                f"{field_name}='{raw_endpoint}' is neither a point nor a known component id"
            )
        if component.loc is None:
            raise ValueError(f"{field_name} references component '{raw_endpoint}' without a location")
        return component.loc

    if isinstance(raw_endpoint, dict):
        if "id" in raw_endpoint or "component" in raw_endpoint:
            component_id = raw_endpoint.get("id", raw_endpoint.get("component"))
            if not isinstance(component_id, str) or not component_id:
                raise ValueError(f"{field_name}.id must be a non-empty string")
            component = components_by_id.get(component_id)
            if component is None:
                raise ValueError(f"{field_name} references unknown component id '{component_id}'")
            anchor = raw_endpoint.get("anchor", "loc")
            if not isinstance(anchor, str):
                raise ValueError(f"{field_name}.anchor must be a string")
            base = get_component_anchor(component, anchor)
            dx = parse_int(raw_endpoint.get("dx", 0), f"{field_name}.dx")
            dy = parse_int(raw_endpoint.get("dy", 0), f"{field_name}.dy")
            return Point(base.x + dx, base.y + dy).snapped(layout.grid)

        point = parse_point(raw_endpoint, field_name)
        return point.snapped(layout.grid) if layout.snap_existing_points else point

    point = parse_point(raw_endpoint, field_name)
    return point.snapped(layout.grid) if layout.snap_existing_points else point


def build_segments_between_points(
    points: list[Point], *, style: str, elbow: str
) -> list[tuple[Point, Point]]:
    if len(points) < 2:
        return []

    segments: list[tuple[Point, Point]] = []
    for start, end in zip(points, points[1:]):
        if style in {"manhattan", "orthogonal"} and start.x != end.x and start.y != end.y:
            if elbow == "vertical-first":
                mid = Point(start.x, end.y)
            else:
                mid = Point(end.x, start.y)
            segments.append((start, mid))
            segments.append((mid, end))
        else:
            segments.append((start, end))
    return segments


def normalize_wire_segments(segments: list[tuple[Point, Point]]) -> list[tuple[Point, Point]]:
    deduplicated: dict[tuple[Point, Point], tuple[Point, Point]] = {}
    for start, end in segments:
        if start == end:
            continue
        key = (start, end) if start <= end else (end, start)
        deduplicated[key] = (start, end)

    normalized = list(deduplicated.values())
    normalized.sort(
        key=lambda segment: (
            min(segment[0].y, segment[1].y),
            min(segment[0].x, segment[1].x),
            max(segment[0].y, segment[1].y),
            max(segment[0].x, segment[1].x),
        )
    )
    return normalized


def parse_wires(
    raw_items: Any,
    circuit_name: str,
    field_name: str,
    components_by_id: dict[str, ComponentRecord],
    layout: LayoutConfig,
    *,
    default_style: str,
) -> list[tuple[Point, Point]]:
    if raw_items is None:
        return []
    if not isinstance(raw_items, list):
        raise ValueError(f"circuit '{circuit_name}' {field_name} must be a list")

    segments: list[tuple[Point, Point]] = []
    for idx, item in enumerate(raw_items):
        if not isinstance(item, dict):
            raise ValueError(f"circuit '{circuit_name}' {field_name}[{idx}] must be an object")

        from_value = item.get("from")
        to_value = item.get("to")
        if from_value is None or to_value is None:
            raise ValueError(f"{field_name}[{idx}] requires both 'from' and 'to'")

        start = resolve_endpoint(from_value, f"{field_name}[{idx}].from", components_by_id, layout)
        end = resolve_endpoint(to_value, f"{field_name}[{idx}].to", components_by_id, layout)

        style_raw = item.get("style", default_style)
        if not isinstance(style_raw, str):
            raise ValueError(f"{field_name}[{idx}].style must be a string")
        style = style_raw.strip().lower()
        if style not in {"straight", "manhattan", "orthogonal"}:
            raise ValueError(
                f"{field_name}[{idx}].style must be one of: straight, manhattan, orthogonal"
            )

        elbow_raw = item.get("elbow", "horizontal-first")
        if not isinstance(elbow_raw, str):
            raise ValueError(f"{field_name}[{idx}].elbow must be a string")
        elbow = elbow_raw.strip().lower()
        if elbow not in {"horizontal-first", "vertical-first"}:
            raise ValueError(
                f"{field_name}[{idx}].elbow must be 'horizontal-first' or 'vertical-first'"
            )

        via_raw = item.get("via", [])
        if via_raw is None:
            via_raw = []
        if not isinstance(via_raw, list):
            raise ValueError(f"{field_name}[{idx}].via must be a list")

        via_points = [
            resolve_endpoint(via_item, f"{field_name}[{idx}].via[{via_idx}]", components_by_id, layout)
            for via_idx, via_item in enumerate(via_raw)
        ]

        points = [start, *via_points, end]
        segments.extend(build_segments_between_points(points, style=style, elbow=elbow))

    return segments


def build_circuit_record(
    circuit_data: dict[str, Any],
    registry: LibraryRegistry,
    layout: LayoutConfig,
) -> CircuitRecord:
    name = circuit_data.get("name")
    if not isinstance(name, str) or not name:
        raise ValueError("Each circuit requires a non-empty string 'name'")

    attributes = circuit_data.get("attributes", {})
    if attributes is None:
        attributes = {}
    if not isinstance(attributes, dict):
        raise ValueError(f"circuit '{name}' attributes must be an object")

    components = parse_components(circuit_data.get("components", []), name, registry, layout)
    apply_component_layout(components, registry, layout)
    components_by_id = {component.component_id: component for component in components}

    wire_segments = parse_wires(
        circuit_data.get("wires", []),
        name,
        "wires",
        components_by_id,
        layout,
        default_style="straight",
    )
    connection_segments = parse_wires(
        circuit_data.get("connections", []),
        name,
        "connections",
        components_by_id,
        layout,
        default_style="manhattan",
    )
    wires = normalize_wire_segments([*wire_segments, *connection_segments])

    if layout.sort_elements:
        components.sort(
            key=lambda component: (
                component.loc.x if component.loc is not None else 0,
                component.loc.y if component.loc is not None else 0,
                component.name,
                component.component_id,
            )
        )

    return CircuitRecord(name=name, attributes=attributes, components=components, wires=wires)


def build_circuit_element(circuit_record: CircuitRecord) -> ET.Element:
    circuit = ET.Element("circuit")
    circuit.set("name", circuit_record.name)

    for attr_name, attr_value in circuit_record.attributes.items():
        add_attr(circuit, attr_name, attr_value)

    for component_record in circuit_record.components:
        if component_record.loc is None:
            raise ValueError(
                f"Circuit '{circuit_record.name}' component '{component_record.component_id}' missing location"
            )
        component = ET.SubElement(circuit, "comp")
        component.set("name", component_record.name)
        component.set("loc", component_record.loc.as_text())
        if component_record.lib is not None:
            component.set("lib", component_record.lib)
        for attr_name, attr_value in component_record.attrs.items():
            add_attr(component, attr_name, attr_value)

    for start, end in circuit_record.wires:
        wire = ET.SubElement(circuit, "wire")
        wire.set("from", start.as_text())
        wire.set("to", end.as_text())

    return circuit


def append_editor_defaults(project: ET.Element, registry: LibraryRegistry) -> None:
    base_lib = registry.find_name_by_desc("#Base")
    wiring_lib = registry.find_name_by_desc("#Wiring")
    gates_lib = registry.find_name_by_desc("#Gates")

    if base_lib is None:
        return

    options = ET.SubElement(project, "options")
    add_attr(options, "gateUndefined", "ignore")
    add_attr(options, "simlimit", "1000")
    add_attr(options, "simrand", "0")

    mappings = ET.SubElement(project, "mappings")
    ET.SubElement(mappings, "tool", {"lib": base_lib, "name": "Poke Tool", "map": "Button2"})
    ET.SubElement(mappings, "tool", {"lib": base_lib, "name": "Menu Tool", "map": "Button3"})
    ET.SubElement(
        mappings, "tool", {"lib": base_lib, "name": "Menu Tool", "map": "Ctrl Button1"}
    )

    toolbar = ET.SubElement(project, "toolbar")
    ET.SubElement(toolbar, "tool", {"lib": base_lib, "name": "Poke Tool"})
    ET.SubElement(toolbar, "tool", {"lib": base_lib, "name": "Edit Tool"})
    ET.SubElement(toolbar, "tool", {"lib": base_lib, "name": "Wiring Tool"})
    ET.SubElement(toolbar, "tool", {"lib": base_lib, "name": "Text Tool"})
    ET.SubElement(toolbar, "sep")

    if wiring_lib is not None:
        ET.SubElement(toolbar, "tool", {"lib": wiring_lib, "name": "Pin"})
        output_pin_tool = ET.SubElement(toolbar, "tool", {"lib": wiring_lib, "name": "Pin"})
        add_attr(output_pin_tool, "facing", "west")
        add_attr(output_pin_tool, "type", "output")
        ET.SubElement(toolbar, "sep")

    if gates_lib is not None:
        for gate_name in (
            "NOT Gate",
            "AND Gate",
            "OR Gate",
            "XOR Gate",
            "NAND Gate",
            "NOR Gate",
        ):
            ET.SubElement(toolbar, "tool", {"lib": gates_lib, "name": gate_name})


def build_from_spec(spec: dict[str, Any], *, organize_flag: bool = False) -> ET.ElementTree:
    source = spec.get("source", "4.1.0")
    main_circuit_name = spec.get("main", "main")
    if not isinstance(source, str) or not source:
        raise ValueError("'source' must be a non-empty string")
    if not isinstance(main_circuit_name, str) or not main_circuit_name:
        raise ValueError("'main' must be a non-empty string")

    layout = parse_layout_config(spec.get("layout"), organize_flag)
    registry = LibraryRegistry(normalize_libraries(spec.get("libraries")))
    ensure_base_library(registry)

    circuits_data = spec.get("circuits")
    if not isinstance(circuits_data, list) or not circuits_data:
        raise ValueError("'circuits' must be a non-empty list")

    circuit_records = [
        build_circuit_record(circuit_data, registry, layout) for circuit_data in circuits_data
    ]

    circuit_names = {circuit.name for circuit in circuit_records}
    if main_circuit_name not in circuit_names:
        raise ValueError(
            f"'main' circuit '{main_circuit_name}' not found in circuits: {sorted(circuit_names)}"
        )

    project = ET.Element("project")
    project.set("version", "1.0")
    project.set("source", source)

    comment = (
        "This file is intended to be loaded by Logisim-evolution "
        "(https://github.com/logisim-evolution/)."
    )
    project.append(ET.Comment(comment))

    for library in registry.all():
        lib_element = ET.SubElement(project, "lib")
        lib_element.set("name", library["name"])
        lib_element.set("desc", library["desc"])

    main = ET.SubElement(project, "main")
    main.set("name", main_circuit_name)

    append_editor_defaults(project, registry)

    for circuit_record in circuit_records:
        project.append(build_circuit_element(circuit_record))

    return ET.ElementTree(project)


def build_default(
    source: str, main_circuit_name: str, library_set: str, *, organize_flag: bool
) -> ET.ElementTree:
    libraries = (
        DEFAULT_FULL_LIBRARIES if library_set == "full" else DEFAULT_MINIMAL_LIBRARIES
    )
    spec = {
        "source": source,
        "main": main_circuit_name,
        "libraries": libraries,
        "circuits": [{"name": main_circuit_name, "components": [], "wires": []}],
    }
    return build_from_spec(spec, organize_flag=organize_flag)


def indent_tree(root: ET.Element) -> None:
    if hasattr(ET, "indent"):
        ET.indent(root)  # type: ignore[attr-defined]
        return

    def _indent(elem: ET.Element, level: int = 0) -> None:
        indentation = "\n" + level * "  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = indentation + "  "
            for child in elem:
                _indent(child, level + 1)
            if not elem[-1].tail or not elem[-1].tail.strip():
                elem[-1].tail = indentation
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = indentation

    _indent(root)


def main() -> None:
    args = parse_args()
    output_path = Path(args.output)

    try:
        if output_path.exists() and not args.overwrite:
            raise ValueError(
                f"Output file '{output_path}' already exists. Use --overwrite to replace it."
            )
        if output_path.suffix != ".circ":
            raise ValueError("Output path must end with .circ")

        if args.spec:
            with Path(args.spec).open("r", encoding="utf-8") as input_file:
                spec_data = json.load(input_file)
            if not isinstance(spec_data, dict):
                raise ValueError("Spec file must contain a JSON object at top level")
            tree = build_from_spec(spec_data, organize_flag=args.organize)
        else:
            tree = build_default(
                args.source,
                args.main_circuit,
                args.library_set,
                organize_flag=args.organize,
            )

        root = tree.getroot()
        indent_tree(root)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        tree.write(output_path, encoding="UTF-8", xml_declaration=True)
        print(f"[OK] Wrote Logisim file: {output_path}")
    except (ValueError, KeyError, TypeError, json.JSONDecodeError, OSError) as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        raise SystemExit(1) from None


if __name__ == "__main__":
    main()
