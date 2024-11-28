#!/bin/bash

# Directory structure
REPO_DIR="$(pwd)"
BUILD_DIR="$REPO_DIR/build"
REPO_DB_DIR="$REPO_DIR/repo"

# Create necessary directories
mkdir -p "$BUILD_DIR"
mkdir -p "$REPO_DB_DIR"

# Function to build a package
build_package() {
    local pkg_dir="$1"
    echo "Building package in $pkg_dir..."
    
    # Copy source files from onigirilinux repository
    if [ -d "../onigirilinux/apps/${pkg_dir#onigiri-}" ]; then
        mkdir -p "$BUILD_DIR/$pkg_dir/src"
        cp -r "../onigirilinux/apps/${pkg_dir#onigiri-}"/* "$BUILD_DIR/$pkg_dir/src/"
    elif [ -d "../onigirilinux/plugins/${pkg_dir#onigiri-}" ]; then
        mkdir -p "$BUILD_DIR/$pkg_dir/src"
        cp -r "../onigirilinux/plugins/${pkg_dir#onigiri-}"/* "$BUILD_DIR/$pkg_dir/src/"
    fi
    
    # Build package
    cd "$BUILD_DIR/$pkg_dir"
    makepkg -f
    
    # Move package to repo directory
    mv *.pkg.tar.zst "$REPO_DB_DIR/"
}

# Clean previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build each package
for pkg_dir in packages/*/; do
    pkg_name=$(basename "$pkg_dir")
    # Create build directory for package
    mkdir -p "$BUILD_DIR/$pkg_name"
    cp "$pkg_dir/PKGBUILD" "$BUILD_DIR/$pkg_name/"
    
    # Build package
    build_package "$pkg_name"
done

# Create/update repository database
cd "$REPO_DB_DIR"
repo-add onigirilinux.db.tar.gz *.pkg.tar.zst

echo "Repository built successfully!"
