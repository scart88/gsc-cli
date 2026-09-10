#!/usr/bin/env bash
set -e

# ==============================================================================
# GSC CLI Installer (Google Search Console & Indexing API)
# ==============================================================================

BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║     🚀 INSTALLING GOOGLE SEARCH CONSOLE & INDEXING CLI       ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# 1. Target directory
TARGET_DIR="${HOME}/.local/bin"
TARGET_BIN="${TARGET_DIR}/gsc"
mkdir -p "${TARGET_DIR}"

# 2. Source resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/dist/gsc" ]; then
  echo -e "📦 Installing standalone binary from local repository..."
  cp "${SCRIPT_DIR}/dist/gsc" "${TARGET_BIN}"
elif [ -d "${SCRIPT_DIR}/lib/gsc" ]; then
  echo -e "📦 Building and installing standalone binary from local repository..."
  (cd "${SCRIPT_DIR}" && rake build:standalone >/dev/null 2>&1 || ruby -e 'system("rake", "build:standalone")')
  cp "${SCRIPT_DIR}/dist/gsc" "${TARGET_BIN}"
else
  REPO_RAW_URL="${GSC_SOURCE_URL:-https://raw.githubusercontent.com/ApollosWave/gsc-cli/main/dist/gsc}"
  echo -e "🌐 Downloading latest release from ${CYAN}${REPO_RAW_URL}${RESET}..."
  curl -fsSL "${REPO_RAW_URL}" -o "${TARGET_BIN}"
fi

chmod +x "${TARGET_BIN}"

# 3. PATH check
if [[ ":$PATH:" != *":${TARGET_DIR}:"* ]]; then
  echo -e "${YELLOW}⚠️  Note: ${TARGET_DIR} is not in your current PATH.${RESET}"
  echo -e "   Add this line to your ~/.zshrc or ~/.bashrc:"
  echo -e "   ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
  echo ""
fi

# 4. Auto-install AI Agent Skills
echo -e "🤖 Installing AI Agent Skills..."
"${TARGET_BIN}" skills install 2>/dev/null || true

if [ -d "${SCRIPT_DIR}/skills" ]; then
  if [ -d "${HOME}/.gemini/config/skills" ]; then
    cp -r "${SCRIPT_DIR}/skills/"* "${HOME}/.gemini/config/skills/" 2>/dev/null || true
  fi
  if [ -d "${HOME}/.claude/skills" ]; then
    cp -r "${SCRIPT_DIR}/skills/"* "${HOME}/.claude/skills/" 2>/dev/null || true
  fi
fi

echo ""
echo -e "${GREEN}${BOLD}🎉 Installation Complete!${RESET}"
echo -e "   Executable: ${CYAN}${TARGET_BIN}${RESET}"
echo ""
echo -e "${BOLD}Next Steps:${RESET}"
echo -e "   1. Run ${CYAN}gsc connect${RESET} to configure your Google Service Account key."
echo -e "   2. Run ${CYAN}gsc use yourdomain.com${RESET} to set your default property."
echo -e "   3. Run ${CYAN}gsc top-queries${RESET} or ${CYAN}gsc audit${RESET} to verify."
echo ""
