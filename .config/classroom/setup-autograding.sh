#!/bin/bash

# GitHub Classroom Setup Script
# Run this script when setting up the repository as a GitHub Classroom template
# This restores the autograding configuration from the hidden location

echo "Setting up GitHub Classroom autograding..."

# Create the required GitHub directories
mkdir -p .github/classroom
mkdir -p .github/workflows

# Copy autograding configuration back to where GitHub Classroom expects it
cp .config/classroom/tests.json .github/classroom/autograding.json
cp .config/classroom/workflow.yml .github/workflows/classroom.yml

echo "✅ GitHub Classroom autograding configured!"
echo "Files created:"
echo "  - .github/classroom/autograding.json"
echo "  - .github/workflows/classroom.yml"
echo ""
echo "You can now:"
echo "1. Import this repository into GitHub Classroom"
echo "2. Enable autograding in your assignment settings"
echo "3. Students will not see the autograding configuration in their repositories"
