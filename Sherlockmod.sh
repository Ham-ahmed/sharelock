#!/bin/bash
#
# Command: wget -q "--no-check-certificate" https://raw.githubusercontent.com/Ham-ahmed/sharelock/refs/heads/main/Sherlockmod.sh -O - | /bin/sh
#
# Define colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "------------------------------------------------------------------------"
echo "                     Installing Sherlockmod plugin                      "
echo "------------------------------------------------------------------------"

# Function to check package manager
check_package_manager() {
    if command -v opkg >/dev/null 2>&1; then
        echo "opkg"
    elif command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dpkg >/dev/null 2>&1; then
        echo "dpkg"
    else
        echo "unknown"
    fi
}

echo "Checking Python version..."
PY_VER=$(python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))' 2>/dev/null)
if [ -z "$PY_VER" ]; then
    PY_VER=$(python3 -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))' 2>/dev/null)
fi

if [ -z "$PY_VER" ]; then
    echo -e "${RED}Error: Python is not installed or detected on this device!${NC}"
    exit 1
fi

echo -e "${GREEN}Detected Python Version: $PY_VER${NC}"

# Check Python version compatibility
case $PY_VER in
    3.9|3.10|3.11|3.12|3.13|3.14|3.8)
        echo -e "${GREEN}Python $PY_VER is supported. Proceeding...${NC}"
        ;;
    *)
        echo -e "${RED}Error: Python $PY_VER is not supported by this plugin version.${NC}"
        exit 1
        ;;
esac
echo ""

echo "Removing old versions of Sherlockmod completely... "
sleep 1

# Detect package manager
PKG_MANAGER=$(check_package_manager)
echo "Detected package manager: $PKG_MANAGER"

# Remove old package based on package manager
case $PKG_MANAGER in
    opkg)
        opkg remove enigma2-plugin-extensions-Sherlockmod > /dev/null 2>&1
        opkg remove enigma2-plugin-extensions-sherlockmod > /dev/null 2>&1
        ;;
    apt|dpkg)
        dpkg -r enigma2-plugin-extensions-sherlockmod > /dev/null 2>&1
        apt-get remove -y enigma2-plugin-extensions-sherlockmod > /dev/null 2>&1
        ;;
esac

# Force remove folder with all contents
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod ] ; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod
    echo -e "${GREEN}Old folder /Sherlockmod deleted permanently.${NC}"
else
    echo "No old folder found. System is clean."
fi

# Remove any other possible locations
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/sherlockmod ] ; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/sherlockmod
    echo "Old lowercase folder removed."
fi
echo ""

# Check and install curl if needed
echo "Checking if curl is installed... "
if ! command -v curl >/dev/null 2>&1; then
    echo "Installing curl..."
    case $PKG_MANAGER in
        opkg)
            opkg install curl
            ;;
        apt)
            apt-get update && apt-get install -y curl
            ;;
        *)
            echo -e "${RED}Warning: Cannot install curl automatically${NC}"
            ;;
    esac
fi
sleep 1

cd /tmp

# Try different Python version patterns
FILE_NAME="Sherlockmod_${PY_VER}.ipk"
DOWNLOAD_URL="https://raw.githubusercontent.com/Ham-ahmed/sharelock/refs/heads/main/Sherlockmod/${FILE_NAME}"

echo "Downloading Sherlockmod package for Python ${PY_VER}..."
curl -s -k -L "${DOWNLOAD_URL}" -o /tmp/${FILE_NAME}

# If download fails, try alternative naming
if [ $? -ne 0 ] || [ ! -f /tmp/${FILE_NAME} ]; then
    echo "Trying alternative package name..."
    # Try without minor version
    PY_VER_MAJOR=$(echo $PY_VER | cut -d. -f1)
    FILE_NAME_ALT="Sherlockmod_${PY_VER_MAJOR}.ipk"
    curl -s -k -L "https://raw.githubusercontent.com/Ham-ahmed/sharelock/refs/heads/main/Sherlockmod/${FILE_NAME_ALT}" -o /tmp/${FILE_NAME_ALT}
    
    if [ -f /tmp/${FILE_NAME_ALT} ]; then
        FILE_NAME=$FILE_NAME_ALT
    else
        echo -e "${RED}Error: Failed to download package. Please check if the file exists on GitHub.${NC}"
        exit 1
    fi
fi

if [ ! -f /tmp/${FILE_NAME} ]; then
    echo -e "${RED}Error: Failed to download ${FILE_NAME}${NC}"
    exit 1
fi

echo -e "${GREEN}Download completed successfully!${NC}"
sleep 1

echo "Installing new version...."
INSTALL_SUCCESS=0

case $PKG_MANAGER in
    opkg)
        opkg install --force-overwrite /tmp/${FILE_NAME}
        if [ $? -eq 0 ]; then
            INSTALL_SUCCESS=1
        fi
        ;;
    apt|dpkg)
        dpkg -i /tmp/${FILE_NAME}
        if [ $? -eq 0 ]; then
            INSTALL_SUCCESS=1
        else
            apt-get install -f -y
            if [ $? -eq 0 ]; then
                INSTALL_SUCCESS=1
            fi
        fi
        ;;
    *)
        echo -e "${RED}Error: Unsupported package manager${NC}"
        exit 1
        ;;
esac

if [ $INSTALL_SUCCESS -eq 0 ]; then
    echo -e "${RED}Error installing Sherlockmod${NC}"
    exit 1
fi

echo ""
sleep 1

echo "Cleaning up temporary files..."
rm -f /tmp/${FILE_NAME}
rm -f /tmp/Sherlockmod_*.ipk 2>/dev/null

# Verify installation
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod ]; then
    echo -e "${GREEN}Plugin installed successfully in: /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod${NC}"
else
    echo -e "${YELLOW}Warning: Plugin directory not found, but installation may still be complete${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN} ✅ Download and installation completed successfully!  ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     ▶ Package: Sherlockmod${NC}"
echo -e "${BLUE}     ▶ Version: v9.0${NC}"
echo -e "${YELLOW}   ▶ Note: Device will restart automatically${NC}"
echo -e "${CYAN}     ▶ Uploaded by: HAMDY_AHMED${NC}"
echo -e "${WHITE}    ▶ Group link: https://www.facebook.com/share/g/18qCRuHz26/${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo "   "

# Optional: Restart enigma2
if command -v killall >/dev/null 2>&1; then
    echo "Restarting enigma2 GUI..."
    sleep 2
    killall -9 enigma2 2>/dev/null
fi

exit 0
