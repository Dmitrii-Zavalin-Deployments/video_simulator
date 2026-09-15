#!/bin/bash
# ==============================================================================
# requirements.sh - Unified Environmental Provisioning & Path Resolution
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

# 1. Pip Upgrade
log "📦 Upgrading pip..."
python -m pip install --upgrade pip

# 2. Batched Dependency Installation
log "📦 Installing Python dependencies in batch..."

cat << 'EOF' > /tmp/video_simulator_requirements.txt
# Contract Enforcement
jsonschema>=4.23.0

# Scientific & Image Processing Pipeline
opencv-python-headless>=4.9.0
scikit-image>=0.22.0
scikit-learn>=1.3.0
numpy>=1.26.0
Pillow>=10.0.0
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

log "✅ All base dependencies installed successfully."

# 3. Sub-Repository Path Discovery & PYTHONPATH Injection
log "🔌 Configuring PYTHONPATH for sub-repositories (e.g., video_frame_extractor)..."
export PYTHONPATH="\(PYTHONPATH:\)(pwd)"

# Automatically find and export 'src' directories of any cloned sub-repositories
for subrepo_src in $(find . -type d -name "src"); do
    if [[ "\(subrepo_src" == *"repositories"* ]] || [[ "\)subrepo_src" == *"input-output"* ]]; then
        export PYTHONPATH="\(PYTHONPATH:\)(realpath "$subrepo_src")"
        log "📂 Registered sub-repo path: \((realpath "\)subrepo_src")"
    fi
done

log "✅ Environment and sub-repo paths ready for video simulator execution."