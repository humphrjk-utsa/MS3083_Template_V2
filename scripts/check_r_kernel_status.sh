#!/bin/bash
# Comprehensive R Kernel Status Check
# This script verifies that R kernel is properly set up and working

echo "🔍 R Kernel Status Check"
echo "========================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success_count=0
total_checks=6

# Check 1: R Installation
echo "1️⃣ Checking R installation..."
if command -v R &> /dev/null; then
    R_VERSION=$(R --version | head -1)
    echo -e "   ${GREEN}✅ R is installed: $R_VERSION${NC}"
    ((success_count++))
else
    echo -e "   ${RED}❌ R is not installed${NC}"
fi

# Check 2: Jupyter Installation
echo "2️⃣ Checking Jupyter installation..."
if command -v jupyter &> /dev/null; then
    JUPYTER_VERSION=$(jupyter --version | head -1)
    echo -e "   ${GREEN}✅ Jupyter is available: $JUPYTER_VERSION${NC}"
    ((success_count++))
else
    echo -e "   ${RED}❌ Jupyter is not installed${NC}"
fi

# Check 3: IRkernel Package
echo "3️⃣ Checking IRkernel package..."
R_CHECK=$(R -e "if(require('IRkernel', quietly=TRUE)) cat('INSTALLED') else cat('MISSING')" 2>/dev/null | tail -1)
if [[ "$R_CHECK" == *"INSTALLED"* ]]; then
    echo -e "   ${GREEN}✅ IRkernel package is available${NC}"
    ((success_count++))
else
    echo -e "   ${RED}❌ IRkernel package is missing${NC}"
fi

# Check 4: Kernel Registration
echo "4️⃣ Checking R kernel registration..."
if jupyter kernelspec list 2>/dev/null | grep -q "ir"; then
    KERNEL_PATH=$(jupyter kernelspec list | grep "ir" | awk '{print $2}')
    echo -e "   ${GREEN}✅ R kernel is registered at: $KERNEL_PATH${NC}"
    ((success_count++))
else
    echo -e "   ${RED}❌ R kernel is not registered with Jupyter${NC}"
fi

# Check 5: Kernel Configuration
echo "5️⃣ Checking kernel configuration..."
if [ -f "$HOME/.local/share/jupyter/kernels/ir/kernel.json" ]; then
    echo -e "   ${GREEN}✅ R kernel configuration exists${NC}"
    echo "   📋 Configuration preview:"
    head -5 "$HOME/.local/share/jupyter/kernels/ir/kernel.json" | sed 's/^/      /'
    ((success_count++))
else
    echo -e "   ${RED}❌ R kernel configuration file not found${NC}"
fi

# Check 6: R Profile
echo "6️⃣ Checking R profile..."
if [ -f "$HOME/.Rprofile" ]; then
    echo -e "   ${GREEN}✅ R profile exists${NC}"
    ((success_count++))
else
    echo -e "   ${YELLOW}⚠️ R profile not found (optional)${NC}"
    ((success_count++))  # Don't fail for missing .Rprofile
fi

# Summary
echo ""
echo "📊 Status Summary"
echo "=================="
if [ $success_count -eq $total_checks ]; then
    echo -e "${GREEN}🎉 All checks passed! ($success_count/$total_checks)${NC}"
    echo ""
    echo "✅ Your R kernel is fully configured and ready to use!"
    echo ""
    echo "🎯 To use R in VS Code:"
    echo "   1. Open any .ipynb notebook"
    echo "   2. Click the kernel selector (top-right corner)"
    echo "   3. Select 'R' from the dropdown"
    echo "   4. Start coding!"
    echo ""
    echo "💡 If the R kernel doesn't appear in VS Code:"
    echo "   - Try refreshing VS Code (Ctrl+Shift+P > 'Developer: Reload Window')"
    echo "   - Wait a moment for kernels to be detected"
    echo ""
else
    echo -e "${YELLOW}⚠️ Some issues detected ($success_count/$total_checks checks passed)${NC}"
    echo ""
    echo "🔧 To fix issues, run:"
    echo "   bash scripts/setup_r_kernel.sh"
    echo ""
    echo "📞 For help, check the troubleshooting section in:"
    echo "   notebooks/r-kernel-diagnostic.ipynb"
fi

# Additional diagnostic info
echo ""
echo "🔍 Additional Information"
echo "========================="
echo "Current user: $(whoami)"
echo "Working directory: $(pwd)"
echo "R library paths:"
R -e ".libPaths()" 2>/dev/null | grep -v ">" | sed 's/^/   /'
echo ""
echo "Available Jupyter kernels:"
jupyter kernelspec list 2>/dev/null | sed 's/^/   /'
