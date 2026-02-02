#!/bin/bash
# Test R Kernel Setup Script

echo "🔍 Testing R Kernel Setup..."
echo "================================"

# Test 1: Check if R is installed
echo "1. Checking R installation..."
if command -v R &> /dev/null; then
    echo "   ✅ R is installed: $(R --version | head -1)"
else
    echo "   ❌ R is not found"
    exit 1
fi

# Test 2: Check if Jupyter is working
echo "2. Checking Jupyter..."
if command -v jupyter &> /dev/null; then
    echo "   ✅ Jupyter is available"
else
    echo "   ❌ Jupyter is not found"
    exit 1
fi

# Test 3: Check available kernels
echo "3. Checking available kernels..."
echo "   Available kernels:"
jupyter kernelspec list | grep -E "(ir|R)" || echo "   ⚠️ R kernel not found"

# Test 4: Test IRkernel package
echo "4. Testing IRkernel package..."
R -e "if(require('IRkernel', quietly=TRUE)) { cat('   ✅ IRkernel is working\n') } else { cat('   ❌ IRkernel not found\n') }" 2>/dev/null

# Test 5: Test basic R functionality
echo "5. Testing basic R functionality..."
R -e "cat('   ✅ Basic R test: 2 + 2 =', 2 + 2, '\n')" 2>/dev/null

echo "================================"
echo "🎯 R Kernel test complete!"
echo ""
echo "💡 To use R in VS Code:"
echo "   1. Open the r-kernel-diagnostic.ipynb notebook"
echo "   2. Click on the kernel selector (top-right)"
echo "   3. Select 'R' from the list"
echo "   4. Run the diagnostic cells"
echo ""
echo "🔧 If R kernel is not showing in VS Code:"
echo "   - Try reloading VS Code window (Ctrl+Shift+P > 'Developer: Reload Window')"
echo "   - Check that Jupyter extension is enabled"
echo "   - Try selecting kernel manually in notebook"
