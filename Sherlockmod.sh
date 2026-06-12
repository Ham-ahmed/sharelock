#!/bin/bash
#
# Command: wget -q "--no-check-certificate" https://raw.githubusercontent.com/Ham-ahmed/sharelock/refs/heads/main/Sherlockmod.sh -O - | /bin/sh
#
echo "------------------------------------------------------------------------"
echo "                     Installing Sherlockmod plugin                      "
echo "------------------------------------------------------------------------"

echo "Checking Python version..."
PY_VER=$(python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))' 2>/dev/null)
if [ -z "$PY_VER" ]; then
    PY_VER=$(python3 -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))' 2>/dev/null)
fi

if [ -z "$PY_VER" ]; then
    echo "Error: Python is not installed or detected on this device!"
    exit 1
fi

echo "Detected Python Version: $PY_VER"

case $PY_VER in
    3.9|3.10|3.11|3.12|3.13|3.14)
        echo "Python $PY_VER is supported. Proceeding..."
        ;;
    *)
        echo "Error: Python $PY_VER is not supported by this plugin version."
        exit 1
        ;;
esac
echo ""

echo "Removing old versions of Sherlockmod completely... "
sleep 1

opkg remove enigma2-plugin-extensions-Sherlockmod > /dev/null 2>&1
opkg remove enigma2-plugin-extensions-Sherlockmod > /dev/null 2>&1

# الحذف الإجباري للفولدر بكل محتوياته (عشان نضمن نضافة الرسيفر تماماً)
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod ] ; then
    rm -rf /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod
    echo "Old folder /Sherlockmod deleted permanently."
else
    echo "No old folder found. System is clean."
fi
echo ""

# 3. التأكد من وجود curl
echo "Checking if curl is installed... "
if ! command -v curl >/dev/null 2>&1; then
    opkg install curl
fi
sleep 1

cd /tmp

FILE_NAME="Sherlockmod_${PY_VER}.ipk"
DOWNLOAD_URL="https://raw.githubusercontent.com/Ham-ahmed/sharelock/refs/heads/main/Sherlockmod/${FILE_NAME}"

echo "Downloading Sherlockmod package for Python ${PY_VER}..."
curl -s -k -L "${DOWNLOAD_URL}" -o /tmp/${FILE_NAME}

if [ $? -ne 0 ] || [ ! -f /tmp/${FILE_NAME} ]; then
    echo "Error: Failed to download ${FILE_NAME}. Please check if the file exists on GitHub."
    exit 1
fi
sleep 1

echo "Installing new version...."
opkg install --force-overwrite /tmp/${FILE_NAME}
if [ $? -ne 0 ]; then
    echo "Error installing Sherlockmod"
    exit 1
fi

echo ""
sleep 1

echo "Cleaning up temporary files..."
rm -f /tmp/${FILE_NAME}

echo "Done"
#
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN} ✅ Download and installation completed successfully!  ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}     ▶ Package: $plugin"
    echo -e "${BLUE}     ▶ Version: v9.0"
    echo -e "${YELLOW}   ▶ Note: Device will restart automatically"
    echo -e "${CYAN}     ▶ Uploaded by: HAMDY_AHMED"
    echo -e "${WHITE}    ▶ Group link: https://www.facebook.com/share/g/18qCRuHz26/"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo "   "
exit 0
