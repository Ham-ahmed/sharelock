#!/bin/sh

# ===========================================
# SCRIPT : DOWNLOAD AND INSTALL Sherlockmod #
# ===========================================
# Command: wget -q "--no-check-certificate" https://raw.githubusercontent.com/Ham-ahmed/sharelock/refs/heads/main/Sherlockmod.sh -O - | /bin/sh
# ===========================================

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
PLUGIN_NAME="Sherlockmod"
VERSION="9.0"
GITHUB_USER="Ham-ahmed"
GITHUB_REPO="sharelock"
GITHUB_BRANCH="refs/heads/main"
PACKAGE_NAME="Sherlockmod.tar.gz"
URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/${PLUGIN_NAME}/${PACKAGE_NAME}"
PACKAGE_PATH="/tmp/${PLUGIN_NAME}_${VERSION}.tar.gz"
INSTALL_DIR="/usr/lib/enigma2/python/Plugins/Extensions/${PLUGIN_NAME}"

# Restart method (يمكن تغييره حسب النظام)
RESTART_METHOD="auto"  # auto, init, systemctl, killall, enigma2.sh

# Cleanup function
cleanup() {
    rm -f "$PACKAGE_PATH" 2>/dev/null
    rm -rf /tmp/${PLUGIN_NAME}_extract 2>/dev/null
    rm -rf /tmp/Sherlockmod* 2>/dev/null
    rm -rf /tmp/*.ipk /tmp/*.tar.gz 2>/dev/null
}

# Function to restart Enigma2 safely
restart_enigma2() {
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}           🔄 Restarting Enigma2 GUI...                 ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    
    # Countdown timer
    echo -e "${CYAN}   Please wait...${NC}"
    for i in 5 4 3 2 1; do
        echo -ne "${YELLOW}   Restarting in $i seconds...\r${NC}"
        sleep 1
    done
    echo ""
    
    # Try different restart methods
    if [ "$RESTART_METHOD" = "auto" ]; then
        # Method 1: Using init system (most common for Enigma2)
        if command -v init >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Restarting via init 4 -> init 3${NC}"
            init 4
            sleep 2
            init 3 &
            exit 0
            
        # Method 2: Using systemctl
        elif command -v systemctl >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Restarting via systemctl${NC}"
            systemctl restart enigma2 &
            exit 0
            
        # Method 3: Using enigma2 init script
        elif [ -f /etc/init.d/enigma2 ]; then
            echo -e "${GREEN}✓ Restarting via /etc/init.d/enigma2${NC}"
            /etc/init.d/enigma2 restart &
            exit 0
            
        # Method 4: Using killall (last resort)
        elif command -v killall >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Restarting via killall enigma2${NC}"
            killall -9 enigma2 2>/dev/null &
            exit 0
            
        else
            echo -e "${RED}✗ Could not restart Enigma2 automatically${NC}"
            echo -e "${YELLOW}  Please restart your device manually${NC}"
            exit 0
        fi
    else
        # Manual method selection
        case "$RESTART_METHOD" in
            "init")
                init 4 && sleep 2 && init 3 &
                ;;
            "systemctl")
                systemctl restart enigma2 &
                ;;
            "killall")
                killall -9 enigma2 &
                ;;
            *)
                echo -e "${RED}Unknown restart method${NC}"
                exit 1
                ;;
        esac
    fi
}

# Check root permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "${RED}═══════════════════════════════════════════════${NC}"
    echo "${RED}✗ Script must be run with root privileges${NC}"
    echo "${RED}═══════════════════════════════════════════════${NC}"
    exit 1
fi

# Set trap for cleanup on exit
trap cleanup EXIT

# Initial cleanup
cleanup

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}     Installing ${PLUGIN_NAME} Plugin v${VERSION}    ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""

# ===================================================================
# SECTION 1: System Update
# ===================================================================
echo -e "${CYAN}> Checking system packages...${NC}"

if command -v opkg >/dev/null 2>&1; then
    echo -e "${YELLOW}  Updating package lists...${NC}"
    opkg update > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  ✓ Package lists updated${NC}"
    else
        echo -e "${YELLOW}  ⚠ Warning: opkg update had issues, continuing...${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠ opkg not found, skipping system update${NC}"
fi

# ===================================================================
# SECTION 2: Install Required Dependencies
# ===================================================================
echo ""
echo -e "${CYAN}> Checking required dependencies...${NC}"

# Check and install python3-beautifulsoup4 if needed
if command -v opkg >/dev/null 2>&1; then
    if ! python3 -c "import bs4" 2>/dev/null; then
        echo -e "${YELLOW}  Installing python3-beautifulsoup4...${NC}"
        opkg install python3-beautifulsoup4 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}  ✓ python3-beautifulsoup4 installed${NC}"
        else
            echo -e "${YELLOW}  ⚠ Could not install python3-beautifulsoup4${NC}"
        fi
    else
        echo -e "${GREEN}  ✓ python3-beautifulsoup4 already installed${NC}"
    fi
fi

# Check for wget or curl
if ! command -v wget >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
    echo -e "${YELLOW}  Installing wget...${NC}"
    opkg install wget > /dev/null 2>&1
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN} Dependencies Check Complete${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
sleep 1

# ===================================================================
# SECTION 3: Remove Old Version
# ===================================================================
echo ""
echo -e "${CYAN}> Removing old version of ${PLUGIN_NAME}...${NC}"

# Remove via package manager if exists
if command -v opkg >/dev/null 2>&1; then
    opkg remove enigma2-plugin-extensions-${PLUGIN_NAME} 2>/dev/null
    opkg remove enigma2-plugin-extensions-$(echo ${PLUGIN_NAME} | tr '[:upper:]' '[:lower:]') 2>/dev/null
fi

# Force remove directory
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}  ✓ Old installation removed${NC}"
else
    echo -e "${GREEN}  ✓ No old installation found${NC}"
fi

# ===================================================================
# SECTION 4: Download Package
# ===================================================================
echo ""
echo -e "${CYAN}> Downloading ${PLUGIN_NAME} v${VERSION}...${NC}"
echo -e "${BLUE}  URL: ${URL}${NC}"
echo ""

# Create temp directory
mkdir -p "/tmp"

# Download with progress
if command -v wget >/dev/null 2>&1; then
    # Check if URL is accessible
    if ! wget --spider -q --no-check-certificate "$URL" 2>/dev/null; then
        echo -e "${RED}✗ Failed to connect to server or invalid URL${NC}"
        exit 1
    fi
    
    # Download with progress display
    echo -e "${YELLOW}  Downloading...${NC}"
    wget --no-check-certificate --timeout=15 --tries=3 -q --show-progress -O "$PACKAGE_PATH" "$URL"
    DOWNLOAD_RESULT=$?
    
elif command -v curl >/dev/null 2>&1; then
    # Check if URL is accessible
    if ! curl -s --head --insecure "$URL" 2>/dev/null | head -n 1 | grep -q "200\|302"; then
        echo -e "${RED}✗ Failed to connect to server or invalid URL${NC}"
        exit 1
    fi
    
    # Download with progress
    echo -e "${YELLOW}  Downloading...${NC}"
    curl -# -k --connect-timeout 15 --retry 3 -o "$PACKAGE_PATH" "$URL"
    DOWNLOAD_RESULT=$?
    
else
    echo -e "${RED}✗ Neither wget nor curl found. Please install wget first.${NC}"
    exit 1
fi

# Check if download was successful
if [ $DOWNLOAD_RESULT -ne 0 ] || [ ! -f "$PACKAGE_PATH" ] || [ ! -s "$PACKAGE_PATH" ]; then
    echo -e "${RED}✗ Package download failed${NC}"
    exit 1
fi

# Get file size
if command -v du >/dev/null 2>&1; then
    FILE_SIZE=$(du -h "$PACKAGE_PATH" 2>/dev/null | cut -f1)
    echo -e "${GREEN}  ✓ Downloaded: ${FILE_SIZE}${NC}"
else
    echo -e "${GREEN}  ✓ Download completed successfully${NC}"
fi

# ===================================================================
# SECTION 5: Verify Archive Integrity
# ===================================================================
echo ""
echo -e "${CYAN}> Verifying package integrity...${NC}"

# Check if it's a valid gzip archive
if ! gzip -t "$PACKAGE_PATH" 2>/dev/null; then
    echo -e "${RED}✗ Corrupted or invalid archive file${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Archive integrity verified${NC}"

# ===================================================================
# SECTION 6: Extract Package
# ===================================================================
echo ""
echo -e "${CYAN}> Extracting package...${NC}"

# Create temporary extraction directory
EXTRACT_DIR="/tmp/${PLUGIN_NAME}_extract"
mkdir -p "$EXTRACT_DIR"

# Extract to temp directory first (safer)
if tar -xzf "$PACKAGE_PATH" -C "$EXTRACT_DIR" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Package extracted successfully${NC}"
else
    echo -e "${RED}✗ Extraction failed${NC}"
    exit 1
fi

# Find the actual plugin directory
if [ -d "$EXTRACT_DIR/usr/lib/enigma2/python/Plugins/Extensions/${PLUGIN_NAME}" ]; then
    PLUGIN_SOURCE="$EXTRACT_DIR/usr/lib/enigma2/python/Plugins/Extensions/${PLUGIN_NAME}"
elif [ -d "$EXTRACT_DIR/${PLUGIN_NAME}" ]; then
    PLUGIN_SOURCE="$EXTRACT_DIR/${PLUGIN_NAME}"
elif [ -d "$EXTRACT_DIR/usr" ]; then
    PLUGIN_SOURCE=$(find "$EXTRACT_DIR" -type d -name "${PLUGIN_NAME}" 2>/dev/null | head -1)
    if [ -z "$PLUGIN_SOURCE" ]; then
        PLUGIN_SOURCE="$EXTRACT_DIR"
    fi
else
    PLUGIN_SOURCE="$EXTRACT_DIR"
fi

# Ensure target directory exists
mkdir -p "$(dirname "$INSTALL_DIR")"

# Copy plugin to destination
echo -e "${CYAN}> Installing to ${INSTALL_DIR}...${NC}"
cp -rf "$PLUGIN_SOURCE" "$INSTALL_DIR" 2>/dev/null

if [ $? -eq 0 ] && [ -d "$INSTALL_DIR" ]; then
    echo -e "${GREEN}  ✓ Files copied successfully${NC}"
    
    # Set proper permissions
    chmod -R 755 "$INSTALL_DIR" 2>/dev/null
    chmod 644 "$INSTALL_DIR"/*.py 2>/dev/null
    chmod 755 "$INSTALL_DIR"/*.sh 2>/dev/null
    
    # Count files installed
    FILE_COUNT=$(find "$INSTALL_DIR" -type f 2>/dev/null | wc -l)
    echo -e "${GREEN}  ✓ Installed ${FILE_COUNT} files${NC}"
else
    echo -e "${RED}✗ Failed to copy files to destination${NC}"
    exit 1
fi

# ===================================================================
# SECTION 7: Final Success Message
# ===================================================================
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN} ✅ Download and installation completed successfully!  ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     ▶ Package: ${PLUGIN_NAME}"
echo -e "${BLUE}     ▶ Version: v${VERSION}"
echo -e "${BLUE}     ▶ Location: ${INSTALL_DIR}"
echo -e "${CYAN}     ▶ Uploaded by: HAMDY_AHMED"
echo -e "${WHITE}    ▶ Group link: https://www.facebook.com/share/g/18qCRuHz26/"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ===================================================================
# SECTION 8: Automatic Restart
# ===================================================================
# Call restart function
restart_enigma2

# Cleanup will be called automatically via trap
exit 0