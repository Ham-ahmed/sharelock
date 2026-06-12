#!/bin/sh

# ===========================================
# SCRIPT : DOWNLOAD AND INSTALL Sherlockmod #
# ======================================================================================================
# Command: wget https://raw.githubusercontent.com/Ham-ahmed/sharelock/refs/heads/main/Sherlockmod.sh -O - | /bin/sh #
# ======================================================================================================

# تعريف الألوان (اختياري للزينة)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################
# تصحيح الروابط والمتغيرات
GITHUB_USER="Ham-ahmed"
GITHUB_REPO="sharelock"
GITHUB_BRANCH="refs/heads/main"
PACKAGE_PATH="Sherlockmod"

# أسماء الملفات الصحيحة
MY_IPK="Sherlockmod.ipk"
MY_DEB="Sherlockmod.deb"
MY_GZ="Sherlockmod.tar.gz"

# تحديد نوع الحزمة حسب نظام الجهاز
if which dpkg > /dev/null 2>&1; then
    PKG_TYPE="deb"
    MY_FILE=$MY_DEB
    INSTALL_CMD="dpkg -i"
    FIX_CMD="apt-get install -f -y"
else
    PKG_TYPE="ipk"
    MY_FILE=$MY_IPK
    INSTALL_CMD="opkg install --force-overwrite"
fi

# بناء الرابط الصحيح
MY_MAIN_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/${PACKAGE_PATH}/"
MY_URL="${MY_MAIN_URL}${MY_FILE}"
MY_TMP_FILE="/var/volatile/tmp/${MY_FILE}"
BACKUP_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/${PACKAGE_PATH}/${MY_GZ}"

################################################################

MY_SEP='============================================================='
echo "${BLUE}${MY_SEP}${NC}"
echo "${GREEN}Downloading Sherlockmod package...${NC}"
echo "${BLUE}${MY_SEP}${NC}"
echo ""

# التحقق من وجود wget
if ! command -v wget > /dev/null 2>&1; then
    echo "${YELLOW}Installing wget...${NC}"
    if which opkg > /dev/null 2>&1; then
        opkg update && opkg install wget
    elif which apt-get > /dev/null 2>&1; then
        apt-get update && apt-get install -y wget
    fi
fi

# تنظيف الملفات القديمة
echo "${YELLOW}Removing old versions...${NC}"
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod
rm -rf /usr/lib/enigma2/python/Plugins/Extensions/sherlockmod
rm -f /var/volatile/tmp/Sherlockmod.* > /dev/null 2>&1

# محاولة التحميل
echo "${BLUE}Downloading from: ${MY_URL}${NC}"
wget --no-check-certificate -T 10 -q "${MY_URL}" -P "/var/volatile/tmp/"

# إذا فشل التحميل، حاول تحميل الملف المضغوط
if [ ! -f "$MY_TMP_FILE" ]; then
    echo "${YELLOW}IPK/DEB not found, trying tar.gz archive...${NC}"
    MY_FILE=$MY_GZ
    MY_URL="${MY_MAIN_URL}${MY_GZ}"
    MY_TMP_FILE="/var/volatile/tmp/${MY_FILE}"
    wget --no-check-certificate -T 10 -q "${MY_URL}" -P "/var/volatile/tmp/"
fi

# التحقق من وجود الملف بعد التحميل
if [ -f "$MY_TMP_FILE" ]; then
    echo "${GREEN}Download successful!${NC}"
    echo ""
    echo "${BLUE}${MY_SEP}${NC}"
    echo "${GREEN}Installation started...${NC}"
    echo "${BLUE}${MY_SEP}${NC}"
    echo ""
    
    # التثبيت حسب نوع الملف
    if echo "$MY_FILE" | grep -q "\.deb$"; then
        # تثبيت حزمة DEB
        dpkg -i "$MY_TMP_FILE" 2>/dev/null
        if [ $? -ne 0 ]; then
            apt-get install -f -y
            dpkg -i "$MY_TMP_FILE"
        fi
        MY_RESULT=$?
        
    elif echo "$MY_FILE" | grep -q "\.ipk$"; then
        # تثبيت حزمة IPK
        if which opkg > /dev/null 2>&1; then
            opkg install --force-overwrite --force-reinstall "$MY_TMP_FILE"
            MY_RESULT=$?
        else
            echo "${RED}Error: opkg not found for IPK installation${NC}"
            MY_RESULT=1
        fi
        
    elif echo "$MY_FILE" | grep -q "\.tar\.gz$"; then
        # استخراج الملف المضغوط يدوياً
        echo "${YELLOW}Extracting tar.gz archive...${NC}"
        cd /tmp
        tar -xzf "$MY_TMP_FILE"
        
        # البحث عن المجلد المستخرج
        if [ -d "/tmp/Sherlockmod" ]; then
            cp -rf /tmp/Sherlockmod /usr/lib/enigma2/python/Plugins/Extensions/
            MY_RESULT=$?
            rm -rf /tmp/Sherlockmod
        elif [ -d "/tmp/usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod" ]; then
            cp -rf /tmp/usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod /usr/lib/enigma2/python/Plugins/Extensions/
            MY_RESULT=$?
            rm -rf /tmp/usr
        else
            echo "${RED}Error: Could not find extracted plugin folder${NC}"
            MY_RESULT=1
        fi
        cd - > /dev/null
    else
        echo "${RED}Error: Unknown package format${NC}"
        MY_RESULT=1
    fi
    
    # تنظيف الملفات المؤقتة
    rm -f "$MY_TMP_FILE" > /dev/null 2>&1
    rm -f /tmp/Sherlockmod.tar.gz > /dev/null 2>&1
    
    echo ""
    
    # التحقق من نجاح التثبيت
    if [ $MY_RESULT -eq 0 ]; then
        echo "${GREEN}########################################################################${NC}"
        echo "${GREEN}#           Sherlockmod V9.0 INSTALLED SUCCESSFULLY                    #${NC}"
        echo "${GREEN}########################################################################${NC}"
        echo "${BLUE}#       Successfully Downloaded. Please check Plugin Browser            #${NC}"
        echo "${BLUE}########################################################################${NC}"
        
        # التحقق من وجود المجلد بعد التثبيت
        if [ -d "/usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod" ]; then
            echo "${GREEN}✓ Plugin installed at: /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod${NC}"
            # عرض الإصدار إذا وجد
            if [ -f "/usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod/plugin.py" ]; then
                VERSION=$(grep -m1 "VERSION\|__version__" /usr/lib/enigma2/python/Plugins/Extensions/Sherlockmod/plugin.py 2>/dev/null | cut -d'"' -f2)
                if [ -n "$VERSION" ]; then
                    echo "${GREEN}✓ Version detected: ${VERSION}${NC}"
                fi
            fi
        else
            echo "${YELLOW}⚠ Plugin installed but directory not found at expected location${NC}"
        fi
        
        echo ""
        
        # إعادة تشغيل الجهاز أو الواجهة
        echo "${YELLOW}Restarting Enigma2 GUI...${NC}"
        if which systemctl > /dev/null 2>&1; then
            sleep 2
            systemctl restart enigma2
        elif [ -f /etc/init.d/enigma2 ]; then
            /etc/init.d/enigma2 restart
        else
            init 4
            sleep 3 > /dev/null 2>&1
            init 3
        fi
        
    else
        echo "${RED}   >>>>   INSTALLATION FAILED !   <<<<${NC}"
        echo "${YELLOW}   Try installing manually or check your internet connection.${NC}"
    fi
    
    echo '**************************************************'
    echo '**                   FINISHED                   **'
    echo '**************************************************'
    echo ''
    exit 0
    
else
    echo "${RED}Download failed!${NC}"
    echo "${YELLOW}Possible reasons:${NC}"
    echo "  1. File not found on GitHub repository"
    echo "  2. Internet connection issue"
    echo "  3. GitHub API rate limit"
    echo ""
    echo "${BLUE}Try manual installation from:${NC}"
    echo "  https://github.com/${GITHUB_USER}/${GITHUB_REPO}"
    exit 1
fi

# ----------------------------------------------------------------------------------------------------------
