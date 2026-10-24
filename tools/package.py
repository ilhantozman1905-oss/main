#!/usr/bin/env python3
"""Verify the built place and create complete installation archives without deleting old builds."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import argparse
import hashlib
import json
import shutil
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

def digest(data):
    return hashlib.sha256(data).hexdigest()

def preserve(path):
    if path.exists():
        archive = ROOT / 'build' / 'archive' / (path.stem + '-' + digest(path.read_bytes())[:12] + path.suffix)
        archive.parent.mkdir(parents=True, exist_ok=True)
        if archive.exists():
            assert archive.read_bytes() == path.read_bytes(), f'Archive collision: {archive}'
        else:
            shutil.copy2(path, archive)

def verify_place(place):
    actual = {}
    def walk(item, parents):
        props = item.find('Properties')
        name = props.find("*[@name='Name']") if props is not None else None
        current = parents + [(name.text or '') if name is not None else item.attrib.get('class', '')]
        if props is not None:
            source = props.find("*[@name='Source']")
            if source is not None:
                actual['/'.join(current)] = source.text or ''
        for child in item.findall('Item'):
            walk(child, current)
    for item in ET.parse(place).getroot().findall('Item'):
        walk(item, [])
    prefixes = {
        'shared': ['ReplicatedStorage', 'MoonScrubbers', 'Shared'],
        'server': ['ServerScriptService', 'MoonScrubbers'],
        'client': ['StarterPlayer', 'StarterPlayerScripts', 'MoonScrubbers'],
    }
    files = sorted((ROOT / 'src').rglob('*.lua'))
    for file in files:
        parts = list(file.relative_to(ROOT / 'src').parts)
        name = parts[-1].removesuffix('.lua').removesuffix('.server').removesuffix('.client')
        target = '/'.join(prefixes[parts[0]] + parts[1:-1] + [name])
        matches = [value for key, value in actual.items() if key == target or key.endswith('/' + target)]
        assert len(matches) == 1, f'Missing/duplicate script: {target}'
        assert matches[0].replace('\r\n', '\n') == file.read_text().replace('\r\n', '\n'), f'Stale script: {file}'
    assert len(actual) == len(files), 'Unexpected embedded scripts'
    print(f'PASS: place matches all {len(files)} current source scripts')

def package(place):
    verify_place(place)
    build = ROOT / 'build'
    build.mkdir(exist_ok=True)
    target = build / 'MoonScrubbers.rbxlx'
    if place.resolve() != target.resolve():
        if target.exists() and target.read_bytes() != place.read_bytes():
            preserve(target)
        shutil.copy2(place, target)
    entries = {'MoonScrubbers.rbxlx': target}
    for name in ('README.md', 'default.project.json', '.gitignore'):
        entries[name] = ROOT / name
    for folder in ('src', 'docs', 'tests', 'tools'):
        for file in sorted((ROOT / folder).rglob('*')):
            if file.is_file() and '__pycache__' not in file.parts:
                entries[file.relative_to(ROOT).as_posix()] = file
    manifest = {name: digest(file.read_bytes()) for name, file in entries.items()}
    install = build / 'MoonScrubbers-installatie.zip'
    preserve(install)
    with ZipFile(install, 'w', ZIP_DEFLATED) as zip_file:
        for name, file in entries.items():
            zip_file.write(file, name)
        zip_file.writestr('BESTANDEN-SHA256.json', json.dumps(manifest, indent=2) + '\n')
    with ZipFile(install) as zip_file:
        assert zip_file.testzip() is None
        assert set(zip_file.namelist()) == set(entries) | {'BESTANDEN-SHA256.json'}
        for name, file in entries.items():
            assert zip_file.read(name) == file.read_bytes(), name
    download = build / 'MoonScrubbers-download.zip'
    preserve(download)
    with ZipFile(download, 'w', ZIP_DEFLATED) as zip_file:
        zip_file.write(target, target.name)
    with ZipFile(download) as zip_file:
        assert zip_file.testzip() is None
        assert zip_file.read(target.name) == target.read_bytes()
    print(f'PASS: {len(entries) + 1} files in full installation ZIP verified byte-for-byte')
    print(install)
    print('SHA256:', digest(install.read_bytes()))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--place', required=True, type=Path)
    args = parser.parse_args()
    package(args.place)
