#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2026 Stephane Galland <galland@arakhne.org>
#
# This program is free library; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or any later version.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; see the file COPYING.  If not,
# write to the Free Software Foundation, Inc., 59 Temple Place - Suite
# 330, Boston, MA 02111-1307, USA.

"""
setup.py - A minimal packaging script for TeX-UPmethodology project.

Usage:
    python3 setup.py build          # Extract version from src/UPMVERSION.def to VERSION
    python3 setup.py sdist          # Create a source distribution archive
"""

import os
import sys
import re
import tarfile
import shutil
import subprocess
import argparse

# ------------------------------------------------------------
# Configuration for sdist
# ------------------------------------------------------------
SOURCE_DIRS = ["src", "bst", "doc"]
INFO_FILES = ['AUTHORS', 'Changelog', 'COPYING', 'README', 'VERSION']
DIST_DIR = "dist"

# File patterns that are results of LaTeX compilation (excluded from docs/)
EXCLUDED_PATTERNS = {
    ".aux", ".log", ".out", ".toc", ".lof", ".lot",
    ".bbl", ".blg", ".synctex.gz", ".fls", ".fdb_latexmk",
    ".dvi", ".ps", ".nav", ".snm", ".vrb",
    ".idx", ".ilg", ".ind", ".glg", ".glo", ".gls", ".ist",
    ".acn", ".acr", ".alg", ".glsdefs", ".xdv", ".run.xml",
    ".bcf", ".blg", "~", ".bak"
}

def should_exclude(file_path: str) -> bool:
    """
    Return True if the file should be excluded from the docs/ archive.
    """
    if os.path.islink(file_path):
        return True
    for pattern in EXCLUDED_PATTERNS:
        if file_path.endswith(pattern):
            return True
    return False


def add_directory_to_tar(tar: tarfile.TarFile, root_dir: str, archive_parent: str):
    """
    Recursively add files from root_dir into tar under archive_parent/.
    """
    if not os.path.isdir(root_dir):
        print(f"Error: Directory '{root_dir}' not found.")
        sys.exit(255)

    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            full_path = os.path.join(dirpath, filename)
            rel_path = os.path.relpath(full_path, start=root_dir)
            arcname = os.path.join(archive_parent, rel_path)
            tar.add(full_path, arcname=arcname, recursive=False)

def get_archive_basename(root_dir : str, basename : str) -> str:
    """
    Compute the basename of the archive file.
    """
    version_file = os.path.join(root_dir, 'VERSION')
    with open(version_file, 'r') as version_f:
        version_number = str(version_f.read()).strip()
    return f"{basename}-{version_number}"

def get_archive_name(root_dir : str, basename : str) -> str:
    """
    Compute the name of the archive file.
    """
    return get_archive_basename(root_dir, basename) + ".tar.gz"

def compute_sdist_archive_name(root_dir : str, archive_name : str) -> str:
    dist_dir = os.path.join(root_dir, DIST_DIR)
    os.makedirs(dist_dir, exist_ok=True)
    archive_name = get_archive_name(root_dir, archive_name)
    archive_path = os.path.join(dist_dir, archive_name)
    return archive_path

def cmd_sdist(root_dir : str, archive_name : str, folder_name : str):
    """
    Create a source distribution tar.gz archive.
    """
    archive_path = compute_sdist_archive_name(root_dir, archive_name)

    if os.path.isfile(archive_path):
        os.unlink(archive_path)

    print(f"Creating source distribution: {archive_path}")
    with tarfile.open(archive_path, "w:gz") as tar:
        for src_dir in SOURCE_DIRS:
            add_directory_to_tar(tar, src_dir, os.path.join(folder_name, src_dir))
        for info_file in INFO_FILES:
            full_info_file = os.path.join(root_dir, info_file)
            arcname = os.path.join(folder_name, info_file)
            tar.add(full_info_file, arcname=arcname, recursive=False)
    print("Done.")

def cmd_build_version(root_dir : str):
    """
    Extract version from src/UPMVERSION.def and write it to VERSION.
    The .def file contains a line like: \\def\\UPMVERSION{20260406}
    """
    def_file = os.path.join(root_dir, "src", "UPMVERSION.def")
    if not os.path.isfile(def_file):
        print(f"Error: '{def_file}' not found.")
        sys.exit(255)

    with open(def_file, 'r') as def_f:
        content = str(def_f.read())

    # Regex to match \def\UPMVERSION{...}
    # Allows spaces: \def\UPMVERSION{20260406} or \def\UPMVERSION {20260406}
    match = re.search(r"\\def\\UPMVERSION\s*\{([^}]+)\}", content, re.S)
    if not match:
        print("Error: Could not find \\def\\UPMVERSION{...} in the file.")
        sys.exit(255)

    version = match.group(1).strip()
    version_file = os.path.join(root_dir, 'VERSION')
    with open(version_file, 'w') as version_f:
        version_f.write(f"{version}\n")
    print(f"Version '{version}' written to {version_file}")

def cmd_build_readme(root_dir : str):
    """
    Build the README file.
    """
    readme_input = os.path.join(root_dir, "README.textile")
    readme_output = os.path.join(root_dir, "README")

    if not os.path.isfile(readme_input):
        print(f"Error: '{readme_input}' not found, skipping README conversion.")
        sys.exit(255)

    cmd = ["pandoc", "-f", "textile", "-t", "plain", str(readme_input), "-o", str(readme_output)]
    try:
        subprocess.run(cmd, check=True)
        print(f"Converted '{readme_input}' -> '{readme_output}'")
    except subprocess.CalledProcessError as e:
        print(f"Error running pandoc: {e}")
        sys.exit(255)

def cmd_build_doc(root_dir : str):
    """
    Generate the official documentation:
    1. Create symbolic links of all files in ./src into ./doc/ (preserving directory structure).
    2. Run pdflatex on doc/upmethodology-doc.tex.
    3. Ensure compilation succeeds.
    """
    src_dir = os.path.join(root_dir, "src")
    doc_dir = os.path.join(root_dir, "doc")
    tex_file = os.path.join(doc_dir, "upmethodology-doc.tex")

    # Check prerequisites
    if not os.path.isdir(src_dir):
        print(f"Error: '{src_dir}' directory not found.")
        sys.exit(255)
    if not os.path.isdir(doc_dir):
        print(f"Error: '{doc_dir}' directory not found.")
        sys.exit(255)
    if not os.path.isfile(tex_file):
        print(f"Error: '{tex_file}' not found.")
        sys.exit(255)

    # Step 1: Create symbolic links from src/ into doc/
    print("Creating symbolic links from src/ into doc/...")
    # Walk through src directory
    for root, dirs, files in os.walk(src_dir):
        # Compute relative path from src_dir
        rel_path = os.path.relpath(root, src_dir)
        # Target directory in doc
        target_dir = os.path.join(doc_dir, rel_path)
        # Create target directory if it doesn't exist
        os.makedirs(target_dir, exist_ok=True)
        for file in files:
            src_file = os.path.join(root, file)
            link_path = os.path.join(target_dir, file)
            # If the link already exists and is a symlink, remove it first (to avoid errors)
            if os.path.islink(link_path):
                os.unlink(link_path)
            # Create the symlink (relative or absolute? Use absolute to be safe)
            try:
                # Use absolute path for source to make symlink robust
                os.symlink(src_file, link_path)
                print(f"  {link_path} -> {src_file}")
            except Exception as e:
                print(f"  Warning: Could not create symlink {link_path}: {e}")

    # Step 2: Run pdflatex on upmethodology-doc.tex
    print(f"Compiling {tex_file} with pdflatex...")
    # Save current working directory
    original_cwd = os.getcwd()
    try:
        os.chdir(doc_dir)
        # Run pdflatex with nonstop mode to avoid hanging on errors
        cmd = ["pdflatex", "-interaction=nonstopmode", "upmethodology-doc.tex"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print("LaTeX compilation failed. Here is the log:")
            # Print last 50 lines of stdout/stderr for debugging
            print(result.stdout[-2000:] if result.stdout else "")
            print(result.stderr[-2000:] if result.stderr else "")
            sys.exit(255)
        else:
            print("LaTeX compilation succeeded.")
            # Run a second time to resolve cross-references (not required but common)
            print("Running pdflatex again to resolve references...")
            result2 = subprocess.run(cmd, capture_output=True, text=True)
            if result2.returncode != 0:
                print("Warning: Second compilation had issues, but PDF may still be usable.")
            else:
                print("Documentation generated successfully.")
    finally:
        os.chdir(original_cwd)

def cmd_build(root_dir : str):
    """
    Build the source code.
    """
    cmd_build_version(root_dir)
    cmd_build_readme(root_dir)
    cmd_build_doc(root_dir)

def cmd_clean(root_dir : str):
    """
    Clean temporary files, generated files, and symbolic links from docs/.
    """
    docs_dir = os.path.join(root_dir, "doc")
    if not os.path.isdir(docs_dir):
        print(f"Directory '{docs_dir}' not found, nothing to clean.")
        return

    removed_count = 0
    for root, dirs, files in os.walk(docs_dir):
        for name in files:
            file_path = os.path.join(root, name)
            # Check if it's a symlink or matches an excluded pattern
            if os.path.islink(file_path) or should_exclude(file_path):
                try:
                    os.unlink(file_path)
                    print(f"Removed: {file_path}")
                    removed_count += 1
                except Exception as e:
                    print(f"Error removing {file_path}: {e}")

    for cleanable in ['dist', 'build']:
        dist_dir = os.path.join(root_dir, cleanable)
        if os.path.isdir(dist_dir):
            shutil.rmtree(dist_dir)
            print(f"Removed: {dist_dir}")
            removed_count += 1
    print(f"Cleaning complete. Removed {removed_count} item(s).")

def cmd_build_deb(root_dir : str, archive_name : str):
    """
    Build the Debian packages using the scripts from Stephane Galland
    """
    basename = get_archive_basename(root_dir, archive_name)
    build_dir = os.path.join(root_dir, 'build')
    shutil.rmtree(build_dir, ignore_errors=True)
    source_folder = os.path.join(root_dir, 'packaging', 'debian')
    target_root_folder = os.path.join(build_dir, basename)
    target_folder = os.path.join(target_root_folder, 'debian')
    shutil.copytree(source_folder, target_folder, dirs_exist_ok=True)
    source_archive_path = compute_sdist_archive_name(root_dir, archive_name)
    target_source_archive_path = os.path.join(target_root_folder, 'upstream')
    os.makedirs(target_source_archive_path, exist_ok=True)
    shutil.copy(source_archive_path, target_source_archive_path)
    old_dir = os.getcwd()
    try:
        os.chdir(target_root_folder)
        cmd = ["dpkg-buildpackages_i386_ia64_amd64", "any"]
        try:
            subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running deb packaging command: {e}")
            sys.exit(255)
    finally:
        os.chdir(old_dir)

def main():
    current_root_dir = os.path.normpath(os.path.dirname(str(__file__)))
    parser = argparse.ArgumentParser(description="Configure TeX-UPmethodology project.")
    parser.add_argument("command", choices=["sdist", "build", "clean", "deb"],
                        help="Command to run: 'build' (preparing source code), 'sdist' (create archive), 'clean' (remove files) or 'deb' (building Debian packages).")
    args = parser.parse_args()

    if args.command == "build":
        cmd_build(current_root_dir)
    elif args.command == "sdist":
        cmd_clean(current_root_dir)
        cmd_sdist(current_root_dir, 'tex-upmethodology', 'upmethodology')
    elif args.command == "clean":
        cmd_clean(current_root_dir)
    elif args.command == "deb":
        cmd_clean(current_root_dir)
        cmd_sdist(current_root_dir, 'tex-upmethodology', 'upmethodology')
        cmd_build_deb(current_root_dir, 'tex-upmethodology')
    else:
        print(f"Error: Unsupported command. Use 'build' or 'sdist'.")
        sys.exit(255)


if __name__ == "__main__":
    main()
