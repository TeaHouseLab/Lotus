#!/bin/bash

#enable static links
#I don't know what i'm doing since i only want fish to be built
curl -sL "https://github.com/TeaHouseLab/Lotus/blob/main/static.patch?raw=true" >static.patch
patch -p1 -i static.patch

set -e

ROOT_DIR="$(git rev-parse --show-toplevel)"
APP_BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$APP_BUILD_DIR/package"
# FISH_NCURSES_ROOT must be provided externally.

env \
  CXXFLAGS='-static-libgcc -static-libstdc++ -DTPUTS_USES_INT_ARG' \
  LDFLAGS='-static-libgcc -static-libstdc++' \
  cmake -S "$ROOT_DIR" -B "$APP_BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DBUILD_DOCS=ON \
  -DWITH_GETTEXT=OFF \
  -DFISH_USE_SYSTEM_PCRE2=OFF \
  -DFISH_ALLOW_UNSUPPORTED_STATIC_LINKING=ON \
  -DCurses_ROOT="$FISH_NCURSES_ROOT" \
  -DCURSES_NEED_NCURSES=ON

make -C "$APP_BUILD_DIR" -j$(nproc)
make -C "$APP_BUILD_DIR" install DESTDIR="$APP_DIR"

rm -f "$APP_DIR/usr/bin/fish_indent"
rm -f "$APP_DIR/usr/bin/fish_key_reader"
rm -rf "$APP_DIR/usr/share/doc/fish"

cp -r "$FISH_NCURSES_ROOT/share/terminfo" "$APP_DIR/usr/share/"

cat << 'EOF' > "$APP_DIR/lotus"
#!/bin/bash
unset ARGV0
export TERMINFO_DIRS="$package/usr/share/terminfo:$TERMINFO_DIRS"
exec "$(dirname "$(readlink  -f "${0}")")/usr/bin/fish" ${@+"$@"}
EOF
chmod 755 "$APP_DIR/lotus"
tar zcvf package.tar.gz "$APP_DIR"