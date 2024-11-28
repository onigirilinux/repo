#!/bin/bash

# Configuration
REPO_NAME="onigirilinux"
ARCH="x86_64"
DB_NAME="onigirilinux.db.tar.gz"
GITHUB_USERNAME="onigirilinux"
GITHUB_REPO="repo"
RELEASE_TAG="repo-$(date +%Y.%m.%d)"

# Directory setup
WORK_DIR="$(pwd)"
BUILD_DIR="$WORK_DIR/build"
REPO_DIR="$WORK_DIR/repo"
DB_DIR="$WORK_DIR/docs"

# Create necessary directories
mkdir -p "$BUILD_DIR"
mkdir -p "$REPO_DIR"
mkdir -p "$DB_DIR"

# Build packages
echo "Building packages..."
./build_repo.sh

# Move packages to repo directory
mv "$REPO_DIR"/*.pkg.tar.zst "$DB_DIR/"

# Create/update repository database in docs directory
cd "$DB_DIR"
repo-add "$DB_NAME" *.pkg.tar.zst

# Create symbolic links for database files
ln -sf "$DB_NAME" onigirilinux.db
ln -sf "$DB_NAME.sig" onigirilinux.db.sig
ln -sf "$DB_NAME" onigirilinux.files
ln -sf "$DB_NAME.sig" onigirilinux.files.sig

# Create release notes
echo "Creating release notes..."
{
    echo "# OnigiriLinux Repository Update"
    echo "Date: $(date +%Y-%m-%d)"
    echo ""
    echo "## Packages:"
    for pkg in *.pkg.tar.zst; do
        echo "- $pkg"
    done
} > release_notes.md

# Optional: If using GitHub CLI (gh)
if command -v gh &> /dev/null; then
    echo "Creating GitHub release..."
    gh release create "$RELEASE_TAG" \
        --title "Repository Update $(date +%Y-%m-%d)" \
        --notes-file release_notes.md \
        *.pkg.tar.zst
fi

echo "Repository update complete!"
echo ""
echo "Manual steps:"
echo "1. Push the 'docs' directory to GitHub"
echo "2. Ensure GitHub Pages is enabled and set to the 'docs' folder"
echo "3. Update pacman.conf to use: Server = https://$GITHUB_USERNAME.github.io/$GITHUB_REPO/\$arch"
