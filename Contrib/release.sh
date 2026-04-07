#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-packages}"
ROOT_DIR="$(pwd)"
BUILD_DIR="$ROOT_DIR/build"
PACKAGES_DIR="$ROOT_DIR/packages"
PROJECT_DIR="$ROOT_DIR/WalletWasabi.Daemon"
PROJECT_FILE="$PROJECT_DIR/WalletWasabi.Daemon.csproj"
PROJECT_NAME="WalletWasabi.Daemon"
EXECUTABLE_NAME="abw-daemon"
PACKAGE_NAME="abw-daemon"
PLATFORMS=("win-x64" "linux-x64" "linux-arm64" "osx-x64" "osx-arm64")
LINUX_PLATFORMS=("linux-x64" "linux-arm64")

LATEST_TAG="$(git describe --tags --abbrev=0)"
VERSION="${LATEST_TAG#v}"
PACKAGE_PREFIX="${PACKAGE_NAME}-${VERSION}"

usage() {
  cat <<'EOF'
Usage:
  ./Contrib/release.sh [packages|debian|releasenote|gpgsign]

Modes:
  packages    Build daemon packages for all supported runtimes.
  debian      Build daemon packages and Debian archives for Linux runtimes.
  releasenote Render the release template with the current tag version.
  gpgsign     Sign every file already present in ./packages.
EOF
}

render_release_note() {
  sed -e "s/{version}/$VERSION/g" \
      -e "/{highlights}/r ./WalletWasabi/Announcements/ReleaseHighlights.md" \
      -e "/{highlights}/d" \
      ./Contrib/ReleaseTemplate.md
}

normalize_platform_name() {
  local platform="$1"
  if [[ "$platform" == osx-* ]]; then
    echo "macOS-${platform#osx-}"
  else
    echo "$platform"
  fi
}

rename_published_binary() {
  local output_dir="$1"
  local platform="$2"
  local extension=""
  if [[ "$platform" == win-* ]]; then
    extension=".exe"
  fi

  if [[ -f "$output_dir/${PROJECT_NAME}${extension}" ]]; then
    mv "$output_dir/${PROJECT_NAME}${extension}" "$output_dir/${EXECUTABLE_NAME}${extension}"
  fi
}

build_runtime() {
  local platform="$1"
  local output_dir="$BUILD_DIR/$platform"

  rm -rf "$output_dir"
  mkdir -p "$output_dir"

  dotnet restore "$PROJECT_FILE" --locked-mode
  dotnet publish "$PROJECT_FILE" \
    --configuration Release \
    --runtime "$platform" \
    --output "$output_dir" \
    --self-contained true \
    --disable-parallel \
    --no-restore \
    --property:VersionPrefix="$VERSION" \
    --property:DebugType=none \
    --property:DebugSymbols=false \
    --property:DocumentationFile='' \
    /clp:ErrorsOnly

  rename_published_binary "$output_dir" "$platform"
}

package_runtime() {
  local platform="$1"
  local output_dir="$BUILD_DIR/$platform"
  local package_platform
  package_platform="$(normalize_platform_name "$platform")"
  local package_base="$PACKAGE_PREFIX-$package_platform"

  pushd "$output_dir" >/dev/null
  zip -rq "$PACKAGES_DIR/$package_base.zip" .
  popd >/dev/null

  if [[ "$platform" == linux-* ]]; then
    local source_date_epoch="${SOURCE_DATE_EPOCH:-$(git log -1 --pretty=%ct)}"
    tar --sort=name \
        --mtime="@${source_date_epoch}" \
        --owner=0 \
        --group=0 \
        --numeric-owner \
        --transform="s|^$(basename "$output_dir")|$EXECUTABLE_NAME|" \
        --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
        -pczf "$PACKAGES_DIR/$package_base.tar.gz" \
        -C "$BUILD_DIR" \
        "$(basename "$output_dir")"
  fi
}

package_debian() {
  local platform="$1"
  local arch_suffix=""
  local arch_name="amd64"
  local source_dir="$BUILD_DIR/$platform"

  if [[ "$platform" == "linux-arm64" ]]; then
    arch_suffix="-arm64"
    arch_name="arm64"
  fi

  local package_dir="$BUILD_DIR/deb-$platform"
  local package_root="$package_dir/usr/local/lib/$EXECUTABLE_NAME"
  local bin_dir="$package_dir/usr/local/bin"
  local debian_dir="$package_dir/DEBIAN"

  rm -rf "$package_dir"
  mkdir -p "$package_root" "$bin_dir" "$debian_dir"

  cp -a "$source_dir/." "$package_root/"

  cat > "$bin_dir/$EXECUTABLE_NAME" <<EOF
#!/usr/bin/env sh
exec /usr/local/lib/$EXECUTABLE_NAME/$EXECUTABLE_NAME "\$@"
EOF
  chmod 0755 "$bin_dir/$EXECUTABLE_NAME"

  local installed_size
  installed_size="$(du -s "$package_dir" | cut -f1)"
  cat > "$debian_dir/control" <<EOF
Package: $PACKAGE_NAME
Priority: optional
Section: utils
Maintainer: abw contributors
Version: $VERSION
Homepage: https://github.com/nopara73/abw
Vcs-Git: https://github.com/nopara73/abw.git
Vcs-Browser: https://github.com/nopara73/abw
Architecture: $arch_name
License: MIT
Installed-Size: $installed_size
Description: bitcoin wallet for agents
 open-source. non-custodial. privacy-focused.
EOF

  dpkg-deb -Zxz --build "$package_dir" "$PACKAGES_DIR/${PACKAGE_PREFIX}${arch_suffix}.deb"
}

sign_packages() {
  pushd "$PACKAGES_DIR" >/dev/null
  rm -f SHA256SUMS SHA256SUMS.asc
  for file in ./*; do
    [[ -f "$file" ]] || continue
    sha256sum "$file" >> SHA256SUMS
    gpg --armor --detach-sign --output "$file.asc" "$file"
  done
  gpg --sign --digest-algo sha256 -a --clearsign --armor --output SHA256SUMS.asc SHA256SUMS
  popd >/dev/null
}

build_packages() {
  mkdir -p "$BUILD_DIR" "$PACKAGES_DIR"
  for platform in "${PLATFORMS[@]}"; do
    build_runtime "$platform"
    package_runtime "$platform"
  done
}

case "$MODE" in
  packages)
    build_packages
    ;;
  debian)
    build_packages
    for platform in "${LINUX_PLATFORMS[@]}"; do
      package_debian "$platform"
    done
    ;;
  releasenote)
    render_release_note
    ;;
  gpgsign)
    sign_packages
    ;;
  *)
    usage
    exit 1
    ;;
esac
