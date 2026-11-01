#!/usr/bin/env bash
#
# Essentials APK Build Script
# Builds debug/release APK using Gradle wrapper.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Auto-detect JAVA_HOME if not already configured
if [ -z "${JAVA_HOME:-}" ]; then
    POTENTIAL_JDKS=(
        "/home/hamondev/.gradle/jdks/amazon_com_inc_-21-amd64-linux.2"
        "/home/hamondev/.tlauncher/mojang_jre/java-runtime-delta/linux/java-runtime-delta"
        "/usr/lib/jvm/java-21-openjdk"
        "/usr/lib/jvm/default"
    )
    for jdk in "${POTENTIAL_JDKS[@]}"; do
        if [ -d "$jdk" ] && [ -x "$jdk/bin/java" ]; then
            export JAVA_HOME="$jdk"
            export PATH="$JAVA_HOME/bin:$PATH"
            break
        fi
    done
fi

if [ -z "${JAVA_HOME:-}" ] && ! command -v java >/dev/null 2>&1; then
    echo "ERROR: Java 21 JDK is required. Please set JAVA_HOME." >&2
    exit 1
fi

chmod +x gradlew 2>/dev/null || true

BUILD_TASK="${1:-assembleDebug}"
shift || true

echo "==> Building Essentials APK with task: $BUILD_TASK..."
./gradlew "$BUILD_TASK" "$@"

echo ""
echo "==> Build completed successfully!"
APK_DIR="$PROJECT_ROOT/app/build/outputs/apk"
if [ -d "$APK_DIR" ]; then
    echo "Generated APK(s):"
    find "$APK_DIR" -name "*.apk" -type f | while read -r apk; do
        echo "  - $apk"
    done
fi
