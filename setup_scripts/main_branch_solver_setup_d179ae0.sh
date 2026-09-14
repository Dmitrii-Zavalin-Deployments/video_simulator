#!/bin/bash
# ==============================================================================
# requirements.sh - Unified Environmental Provisioning & Binary Layer Setup
# ==============================================================================

# Keep 'set +e' to handle errors manually
set +e

# Utility function for formatted logging
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

log "🚀 Provisioning runtime environment for Video Processing Simulator (Cold Start)..."

# 0. Pre-installation environment check
log "📋 Initial Environment State:"
python --version
pip list | head -n 5

# 1. Conda Installation 
# Note: Ensure 'conda-solver: libmamba' is set in your Actions YAML for maximum speed
log "📦 Installing base binary layers via Conda..."
conda install -y -c conda-forge pythonocc-core gmsh numpy pip matplotlib
if [ $? -ne 0 ]; then 
    log "❌ ERROR: Conda install failed."
    exit 1
fi
log "✅ Base Conda dependencies installed."

# 2. Pip Upgrade
log "📦 Upgrading pip..."
python -m pip install --upgrade pip

# 3. Batched Dependency Installation
log "📦 Installing Python dependencies in batch (Grouped by Architectural Rules)..."

cat << 'EOF' > /tmp/video_simulator_requirements.txt
# Contract Enforcement
jsonschema>=4.23.0

# Core Dependencies
opencv-python-headless
Pillow
EOF

python -m pip install --no-cache-dir -r /tmp/video_simulator_requirements.txt
PIP_EXIT=$?

# Clean up temp file
rm -f /tmp/video_simulator_requirements.txt

if [ $PIP_EXIT -ne 0 ]; then
    log "❌ ERROR: Batch installation failed."
    log "🔍 Running 'pip check' to show dependency conflicts:"
    pip check
    exit 1
fi

log "✅ All dependencies installed successfully."
log "✅ Environment ready for video simulator execution."