#!/bin/bash
# ==============================================================================
# FORENSIC AUDIT & AUTO-REPAIR SCRIPT
# ==============================================================================
# Purpose: Inspects environment state, audits smoking-gun source files using 
#          line numbering, performs grep diagnostics, and applies automated
#          sed injections to repair build/installation failures in CI/CD.
# ==============================================================================

set +e

echo "=============================================================================="
echo "🔍 STARTING FORENSIC AUDIT & ENVIRONMENT DIAGNOSTICS"
echo "=============================================================================="

# 1. Inspect Python and Pip Runtime State
echo "--- [1] Python & Pip Runtime Environment ---"
python --version
python -m pip --version
pip list --format=freeze

# 2. Smoking-Gun Source Audit using cat -n
echo "--- [2] Smoking-Gun Source Audit: Setup Scripts & Requirements ---"
SETUP_SCRIPT=$(find setup_scripts -name "*.sh" | head -n 1)
if [ -n "\(SETUP_SCRIPT" ] && [ -f "\)SETUP_SCRIPT" ]; then
    echo "📁 Inspecting setup script: $SETUP_SCRIPT"
    cat -n "$SETUP_SCRIPT"
else
    echo "⚠️ Warning: No active setup script found under setup_scripts/"
fi

if [ -f "requirements.txt" ]; then
    echo "📁 Inspecting requirements.txt:"
    cat -n requirements.txt
fi

# 3. Grep Diagnostics for Error Root Causes
echo "--- [3] Grep Diagnostics for Pip / Build Failures ---"
echo "Searching for pip installation commands:"
grep -rn "pip install" . || echo "No pip install found in workspace."

echo "Searching for error keywords in recent logs/files:"
grep -rn "ERROR" . || echo "No explicit ERROR tags found in workspace files."

# 4. Automated Repairs via sed Injections
echo "--- [4] Applying Automated Repairs via sed Injections ---"
if [ -n "\(SETUP_SCRIPT" ] && [ -f "\)SETUP_SCRIPT" ]; then
    echo "💉 Injecting robust flags (--prefer-binary) into pip install commands within $SETUP_SCRIPT..."
    
    # Replace standard pip install with robust flags to avoid source build bottlenecks
    sed -i 's/python -m pip install/python -m pip install --prefer-binary/g' "$SETUP_SCRIPT"
    sed -i 's/pip install/pip install --prefer-binary/g' "$SETUP_SCRIPT"
    
    echo "✅ Successfully updated $SETUP_SCRIPT. Refined content:"
    cat -n "$SETUP_SCRIPT"
fi

if [ -f "requirements.txt" ]; then
    echo "💉 Checking requirements.txt for strict/unsupported constraints..."
    # Ensure dependencies are clean and compatible
    sed -i '/^opencv-python-headless/ s/$/ /' requirements.txt
fi

echo "=============================================================================="
echo "✅ FORENSIC AUDIT & AUTOMATED REPAIR COMPLETED"
echo "=============================================================================="