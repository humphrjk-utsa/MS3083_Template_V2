#!/bin/bash
# Git Setup and Troubleshooting Script for Students
# This script fixes common Git issues in GitHub Classroom assignments

echo "🛠️ Git Setup and Troubleshooting for GitHub Classroom"
echo "=================================================="

# Check current Git configuration
echo "📋 Current Git Configuration:"
echo "  User: $(git config --get user.name || echo 'Not set')"
echo "  Email: $(git config --get user.email || echo 'Not set')"
echo "  GPG Signing: $(git config --get commit.gpgsign || echo 'Not set')"

# Fix common issues
echo ""
echo "🔧 Fixing common Git issues..."

# Disable GPG signing (common issue in codespaces)
git config --global commit.gpgsign false
git config --global tag.gpgsign false
git config --local commit.gpgsign false 2>/dev/null || true
git config --local tag.gpgsign false 2>/dev/null || true
echo "✅ Disabled GPG signing"

# Set up basic user info if not set
if [ -z "$(git config --get user.name)" ]; then
    git config --global user.name "Data Science Student"
    echo "✅ Set default user name"
fi

if [ -z "$(git config --get user.email)" ]; then
    git config --global user.email "student@example.com"
    echo "✅ Set default user email"
fi

# Set default branch to main
git config --global init.defaultBranch main
echo "✅ Set default branch to main"

echo ""
echo "🧪 Testing Git functionality..."

# Test if we can create a commit
if git status >/dev/null 2>&1; then
    echo "✅ Git repository detected"
    
    # Check if there are any changes to commit
    if [ -n "$(git status --porcelain)" ]; then
        echo "📝 Uncommitted changes detected"
        echo "   Run: git add . && git commit -m 'Your message here'"
    else
        echo "✅ Working directory clean"
    fi
    
    # Check if we can push
    if git remote get-url origin >/dev/null 2>&1; then
        echo "✅ Remote origin configured"
        echo "   Run: git push (to submit your work)"
    else
        echo "⚠️ No remote origin found (this might be normal for local testing)"
    fi
else
    echo "⚠️ Not in a Git repository"
fi

echo ""
echo "🎯 Common Git Commands for Assignments:"
echo "   📊 Check status:        git status"
echo "   📝 Add all changes:     git add ."
echo "   💾 Commit changes:      git commit -m 'Completed assignment X'"
echo "   🚀 Push to GitHub:      git push"
echo "   📋 View history:        git log --oneline"
echo "   🔄 Pull updates:        git pull"

echo ""
echo "🆘 If you still have issues:"
echo "   1. Try restarting the terminal"
echo "   2. Run this script again: bash scripts/fix_git.sh"
echo "   3. Contact your instructor if problems persist"

echo ""
echo "✅ Git setup complete! You should now be able to commit and push your work."
