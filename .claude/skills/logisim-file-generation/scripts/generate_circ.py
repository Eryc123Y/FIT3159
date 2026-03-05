#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any


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

POINT_PATTERN = re.compile(r"^\s*\(?\s*(-?\d+)\s*[,\s]\s*(-?\d+)\s*\)?\s*$")


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
        "--overwrite",
        action="store_true",
        help="Overwrite output file if it already exists",
    )
    return parser.parse_args()


def normalize_point(raw: Any, field_name: str) -> str:
    if not isinstance(raw, str):
        raise ValueError(f"{field_name} must be a string point like '(x,y)'")

    match = POINT_PATTERN.match(raw)
    if not match:
        raise ValueError(
            f"{field_name}='{raw}' is invalid; expected integer point '(x,y)'"
        )

    x, y = int(match.group(1)), int(match.group(2))
    return f"({x},{y})"


def add_attr(parent: ET.Element, name: str, value: Any) -> None:
    attr = ET.SubElement(parent, "a")
    attr.set("name", str(name))
    attr.set("val", str(value))


def normalize_libraries(raw_libraries: Any) -> list[dict[str, str]]:
    if raw_libraries is None:
        return DEFAULT_MINIMAL_LIBRARIES
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


def build_circuit_element(circuit_data: dict[str, Any]) -> ET.Element:
    name = circuit_data.get("name")
    if not isinstance(name, str) or not name:
        raise ValueError("Each circuit requires a non-empty string 'name'")

    circuit = ET.Element("circuit")
    circuit.set("name", name)

    attributes = circuit_data.get("attributes", {})
    if attributes is None:
        attributes = {}
    if not isinstance(attributes, dict):
        raise ValueError(f"circuit '{name}' attributes must be an object")
    for attr_name, attr_value in attributes.items():
        add_attr(circuit, attr_name, attr_value)

    components = circuit_data.get("components", [])
    if components is None:
        components = []
    if not isinstance(components, list):
        raise ValueError(f"circuit '{name}' components must be a list")

    for idx, component_data in enumerate(components):
        if not isinstance(component_data, dict):
            raise ValueError(f"circuit '{name}' components[{idx}] must be an object")
        component_name = component_data.get("name")
        loc = component_data.get("loc")
        if not isinstance(component_name, str) or not component_name:
            raise ValueError(
                f"circuit '{name}' components[{idx}].name must be a non-empty string"
            )
        component = ET.SubElement(circuit, "comp")
        component.set("name", component_name)
        component.set("loc", normalize_point(loc, f"components[{idx}].loc"))
        lib = component_data.get("lib")
        if lib is not None:
            if not isinstance(lib, str) or not lib:
                raise ValueError(
                    f"circuit '{name}' components[{idx}].lib must be a non-empty string"
                )
            component.set("lib", lib)

        attrs = component_data.get("attrs", {})
        if attrs is None:
            attrs = {}
        if not isinstance(attrs, dict):
            raise ValueError(f"circuit '{name}' components[{idx}].attrs must be an object")
        for attr_name, attr_value in attrs.items():
            add_attr(component, attr_name, attr_value)

    wires = circuit_data.get("wires", [])
    if wires is None:
        wires = []
    if not isinstance(wires, list):
        raise ValueError(f"circuit '{name}' wires must be a list")
    for idx, wire_data in enumerate(wires):
        if not isinstance(wire_data, dict):
            raise ValueError(f"circuit '{name}' wires[{idx}] must be an object")
        from_point = normalize_point(wire_data.get("from"), f"wires[{idx}].from")
        to_point = normalize_point(wire_data.get("to"), f"wires[{idx}].to")
        wire = ET.SubElement(circuit, "wire")
        wire.set("from", from_point)
        wire.set("to", to_point)

    return circuit


def build_from_spec(spec: dict[str, Any]) -> ET.ElementTree:
    source = spec.get("source", "4.1.0")
    main_circuit_name = spec.get("main", "main")
    if not isinstance(source, str) or not source:
        raise ValueError("'source' must be a non-empty string")
    if not isinstance(main_circuit_name, str) or not main_circuit_name:
        raise ValueError("'main' must be a non-empty string")

    libraries = normalize_libraries(spec.get("libraries"))
    circuits = spec.get("circuits")
    if not isinstance(circuits, list) or not circuits:
        raise ValueError("'circuits' must be a non-empty list")

    project = ET.Element("project")
    project.set("version", "1.0")
    project.set("source", source)

    comment = (
        "This file is intended to be loaded by Logisim-evolution "
        "(https://github.com/logisim-evolution/)."
    )
    project.append(ET.Comment(comment))

    for library in libraries:
        lib_element = ET.SubElement(project, "lib")
        lib_element.set("name", library["name"])
        lib_element.set("desc", library["desc"])

    main = ET.SubElement(project, "main")
    main.set("name", main_circuit_name)

    for circuit_data in circuits:
        project.append(build_circuit_element(circuit_data))

    return ET.ElementTree(project)


def build_default(source: str, main_circuit_name: str, library_set: str) -> ET.ElementTree:
    libraries = (
        DEFAULT_FULL_LIBRARIES if library_set == "full" else DEFAULT_MINIMAL_LIBRARIES
    )
    spec = {
        "source": source,
        "main": main_circuit_name,
        "libraries": libraries,
        "circuits": [{"name": main_circuit_name, "components": [], "wires": []}],
    }
    return build_from_spec(spec)


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

    if output_path.exists() and not args.overwrite:
        raise SystemExit(
            f"Output file '{output_path}' already exists. Use --overwrite to replace it."
        )
    if output_path.suffix != ".circ":
        raise SystemExit("Output path must end with .circ")

    if args.spec:
        with Path(args.spec).open("r", encoding="utf-8") as input_file:
            spec_data = json.load(input_file)
        if not isinstance(spec_data, dict):
            raise SystemExit("Spec file must contain a JSON object at top level")
        tree = build_from_spec(spec_data)
    else:
        tree = build_default(args.source, args.main_circuit, args.library_set)

    root = tree.getroot()
    indent_tree(root)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    tree.write(output_path, encoding="UTF-8", xml_declaration=True)
    print(f"[OK] Wrote Logisim file: {output_path}")


if __name__ == "__main__":
    main()
