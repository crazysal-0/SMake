#!/bin/sh

set -e

VERSION="0.1.0"
INSTALL_DIR="$HOME/.local/bin"
BINARY_NAME="smake"

mkdir -p "$INSTALL_DIR"

echo "Installing SMake $VERSION..."

curl -fL \
    "https://github.com/crazysal-0/SMake/releases/download/v${VERSION}/smake-linux-x86_64" \
    -o "$INSTALL_DIR/$BINARY_NAME"

chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "SMake installed to $INSTALL_DIR/$BINARY_NAME"
echo

case ":$PATH:" in
    *":$INSTALL_DIR:"*)
        ;;
    *)
        echo "$INSTALL_DIR is not in your PATH."
        echo "Add this to your shell configuration:"
        echo
        echo 'export PATH="$HOME/.local/bin:$PATH"'
        ;;
esac