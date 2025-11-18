#!/usr/bin/env bash
# qalarc_OS Comprehensive Testing Suite
# Tests all Phase 8 components

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# ============================================================================
# Test Framework
# ============================================================================

test_start() {
    echo -e "${BLUE}[TEST]${NC} $1"
    ((TESTS_TOTAL++))
}

test_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

test_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# ============================================================================
# Component Tests
# ============================================================================

test_installer_files() {
    echo ""
    echo "=== Testing Installer Files ==="

    test_start "installer.sh exists and is executable"
    if [ -x "./installer.sh" ]; then
        test_pass "installer.sh found and executable"
    else
        test_fail "installer.sh missing or not executable"
    fi

    test_start "detect-hardware.sh exists and is executable"
    if [ -x "./detect-hardware.sh" ]; then
        test_pass "detect-hardware.sh found and executable"
    else
        test_fail "detect-hardware.sh missing or not executable"
    fi

    test_start "build-iso.sh exists and is executable"
    if [ -x "./build-iso.sh" ]; then
        test_pass "build-iso.sh found and executable"
    else
        test_fail "build-iso.sh missing or not executable"
    fi
}

test_profiles() {
    echo ""
    echo "=== Testing NixOS Profiles ==="

    for profile in ai-workstation gaming-ai base; do
        test_start "Profile $profile.nix exists"
        if [ -f "./profiles/$profile.nix" ]; then
            test_pass "Profile $profile.nix found"

            # Check for required placeholders
            test_start "Profile $profile.nix has placeholders"
            if grep -q "{{HOSTNAME}}" "./profiles/$profile.nix" && \
               grep -q "{{USERNAME}}" "./profiles/$profile.nix"; then
                test_pass "Placeholders found in $profile.nix"
            else
                test_fail "Missing placeholders in $profile.nix"
            fi
        else
            test_fail "Profile $profile.nix not found"
        fi
    done
}

test_hardware_detection() {
    echo ""
    echo "=== Testing Hardware Detection ==="

    test_start "Hardware detection script syntax"
    if bash -n ./detect-hardware.sh; then
        test_pass "detect-hardware.sh syntax valid"
    else
        test_fail "detect-hardware.sh syntax errors"
    fi

    test_start "Hardware detection --human output"
    if ./detect-hardware.sh --human > /tmp/hw-test-human.txt 2>&1; then
        if grep -q "CPU:" /tmp/hw-test-human.txt; then
            test_pass "Human output format working"
        else
            test_fail "Human output incomplete"
        fi
    else
        test_fail "Hardware detection failed"
    fi

    test_start "Hardware detection --json output"
    if ./detect-hardware.sh --json > /tmp/hw-test-json.txt 2>&1; then
        if grep -q "cpu_model" /tmp/hw-test-json.txt; then
            test_pass "JSON output format working"
        else
            test_fail "JSON output incomplete"
        fi
    else
        test_fail "Hardware detection JSON failed"
    fi

    test_start "Removable drive detection"
    if grep -q "removable_drives" /tmp/hw-test-json.txt; then
        test_pass "Removable drive detection present"
    else
        test_warn "Removable drive detection not in output"
    fi
}

test_welcome_window() {
    echo ""
    echo "=== Testing Welcome Window ==="

    cd ../qalarc-welcome || exit 1

    test_start "Welcome window main.py exists"
    if [ -f "./main.py" ] && [ -x "./main.py" ]; then
        test_pass "main.py found and executable"
    else
        test_fail "main.py missing or not executable"
    fi

    test_start "Welcome window backend.py exists"
    if [ -f "./backend.py" ]; then
        test_pass "backend.py found"

        # Check for required classes
        test_start "Backend classes defined"
        if grep -q "class HardwareBackend" backend.py && \
           grep -q "class ModelBackend" backend.py && \
           grep -q "class SystemBackend" backend.py; then
            test_pass "All backend classes found"
        else
            test_fail "Missing backend classes"
        fi
    else
        test_fail "backend.py not found"
    fi

    test_start "Main QML file exists"
    if [ -f "./main.qml" ]; then
        test_pass "main.qml found"
    else
        test_fail "main.qml not found"
    fi

    for page in Hardware Models Tour Status; do
        test_start "Page ${page}Page.qml exists"
        if [ -f "./pages/${page}Page.qml" ]; then
            test_pass "${page}Page.qml found"
        else
            test_fail "${page}Page.qml not found"
        fi
    done

    cd ../usb-installer || exit 1
}

test_model_database() {
    echo ""
    echo "=== Testing Model Database ==="

    cd ../model-manager || exit 1

    test_start "model-database.json exists"
    if [ -f "./model-database.json" ]; then
        test_pass "model-database.json found"

        # Validate JSON
        test_start "JSON syntax valid"
        if jq empty model-database.json 2>/dev/null; then
            test_pass "JSON syntax valid"

            # Check structure
            test_start "Database structure"
            MODEL_COUNT=$(jq '.models | length' model-database.json)
            if [ "$MODEL_COUNT" -gt 0 ]; then
                test_pass "Found $MODEL_COUNT models in database"
            else
                test_fail "No models in database"
            fi

            # Check required fields
            test_start "Model metadata completeness"
            if jq '.models[0] | has("name") and has("vram_required") and has("size_gb")' model-database.json | grep -q "true"; then
                test_pass "Model metadata complete"
            else
                test_fail "Model metadata incomplete"
            fi
        else
            test_fail "Invalid JSON syntax"
        fi
    else
        test_fail "model-database.json not found"
    fi

    cd ../usb-installer || exit 1
}

test_system_integration() {
    echo ""
    echo "=== Testing System Integration ==="

    test_start "Ollama service status"
    if systemctl is-active --quiet ollama; then
        test_pass "Ollama service running"

        test_start "Ollama API accessible"
        if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
            test_pass "Ollama API responding"
        else
            test_fail "Ollama API not accessible"
        fi

        test_start "Models available"
        MODEL_COUNT=$(ollama list 2>/dev/null | tail -n +2 | wc -l)
        if [ "$MODEL_COUNT" -gt 0 ]; then
            test_pass "Found $MODEL_COUNT installed model(s)"
        else
            test_warn "No models installed (expected llama3.2:1b)"
        fi
    else
        test_fail "Ollama service not running"
    fi

    test_start "Ghostty terminal installed"
    if command -v ghostty > /dev/null 2>&1; then
        test_pass "Ghostty available"
    else
        test_fail "Ghostty not found"
    fi

    test_start "oterm installed"
    if command -v oterm > /dev/null 2>&1; then
        test_pass "oterm available"
    else
        test_warn "oterm not found (optional)"
    fi

    test_start "ROCm tools installed"
    if command -v rocm-smi > /dev/null 2>&1; then
        test_pass "rocm-smi available"
    else
        test_warn "rocm-smi not found"
    fi
}

test_documentation() {
    echo ""
    echo "=== Testing Documentation ==="

    for doc in README.md DRIVE-SIZE-GUIDE.md; do
        test_start "Documentation $doc exists"
        if [ -f "./$doc" ]; then
            test_pass "$doc found"

            # Check for key sections
            if [ "$doc" = "README.md" ]; then
                test_start "README has portable installation section"
                if grep -q "Portable Installation" README.md; then
                    test_pass "Portable installation docs present"
                else
                    test_fail "Portable installation docs missing"
                fi
            fi
        else
            test_fail "$doc not found"
        fi
    done

    cd ../qalarc-welcome || exit 1

    test_start "Welcome window README exists"
    if [ -f "./README.md" ]; then
        test_pass "Welcome README found"
    else
        test_fail "Welcome README not found"
    fi

    cd ../usb-installer || exit 1
}

test_portable_installation() {
    echo ""
    echo "=== Testing Portable Installation Features ==="

    test_start "Portable installation variables in installer"
    if grep -q "IS_PORTABLE" installer.sh; then
        test_pass "Portable installation variables found"
    else
        test_fail "Portable installation variables missing"
    fi

    test_start "check_portable_installation function exists"
    if grep -q "check_portable_installation()" installer.sh; then
        test_pass "Portable installation function found"
    else
        test_fail "Portable installation function missing"
    fi

    test_start "check_if_portable function in hardware detection"
    if grep -q "check_if_portable()" detect-hardware.sh; then
        test_pass "Portable check function found"
    else
        test_fail "Portable check function missing"
    fi
}

test_git_repository() {
    echo ""
    echo "=== Testing Git Repository ==="

    cd .. || exit 1

    test_start "Git repository initialized"
    if [ -d ".git" ]; then
        test_pass "Git repository found"

        test_start "Branch is phase8-installer-welcome"
        CURRENT_BRANCH=$(git branch --show-current)
        if [ "$CURRENT_BRANCH" = "phase8-installer-welcome" ]; then
            test_pass "On correct branch"
        else
            test_warn "On branch: $CURRENT_BRANCH (expected: phase8-installer-welcome)"
        fi

        test_start "Remote configured"
        if git remote get-url origin > /dev/null 2>&1; then
            REMOTE_URL=$(git remote get-url origin | sed 's/ghp_[^@]*@/TOKEN@/')
            test_pass "Remote configured: $REMOTE_URL"
        else
            test_fail "No remote configured"
        fi

        test_start "Working directory status"
        if [ -z "$(git status --porcelain)" ]; then
            test_pass "Working directory clean"
        else
            test_warn "Uncommitted changes present"
        fi
    else
        test_fail "Not a git repository"
    fi

    cd usb-installer || exit 1
}

# ============================================================================
# Main Test Runner
# ============================================================================

main() {
    echo "=========================================="
    echo "qalarc_OS Phase 8 - Comprehensive Testing"
    echo "=========================================="
    echo ""

    # Change to script directory
    cd "$(dirname "${BASH_SOURCE[0]}")"

    # Run all tests
    test_installer_files
    test_profiles
    test_hardware_detection
    test_welcome_window
    test_model_database
    test_system_integration
    test_documentation
    test_portable_installation
    test_git_repository

    # Summary
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo -e "Total Tests:  $TESTS_TOTAL"
    echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
    echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        exit 1
    fi
}

main "$@"
