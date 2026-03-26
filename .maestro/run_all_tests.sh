#!/bin/bash

# Maestro Test Runner for MomRise Bug Fixes
# Run all automated tests

export PATH="$PATH":"$HOME/.maestro/bin"

echo "========================================"
echo "MomRise Automated Testing with Maestro"
echo "========================================"
echo ""

# Test #9: Navbar Navigation
echo "Running Test #9: Navbar Navigation..."
maestro test .maestro/test_navbar_navigation.yaml
echo ""

# Test #10: Keyboard Overlap
echo "Running Test #10: Keyboard Overlap Fix..."
maestro test .maestro/test_learning_path_keyboard.yaml
echo ""

echo "========================================"
echo "Manual Tests Required:"
echo "========================================"
echo ""
echo "Test #4, #5, #6, #7: Pinterest Import"
echo "  1. Share a recipe from Pinterest to MomRise"
echo "  2. Run: maestro test .maestro/test_pinterest_import.yaml"
echo ""
echo "Test #1: Meal Template Auto-Creation"
echo "  - Manual verification needed (check Firebase)"
echo ""
echo "Test #2: iOS Sharing"
echo "  - iOS device required"
echo ""
echo "Test #3: Templates→Saved Days Rename"
echo "  - Visual inspection of UI text"
echo ""
echo "Test #8: Backend Tag Verification"
echo "  - Check Firebase Cloud Function logs"
echo ""
