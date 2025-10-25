#!/usr/bin/env bash
set -e

# ---------------- How to Use ----------------
# 1. Make it executable:
#       chmod +x deploy_nus.sh
# 2. Run it from terminal:
#       ./deploy_nus.sh

# ===== Configuration =====
LOCAL_DIR="/Users/yaotong/Documents/personal_page/yao-site"
REMOTE_USER="yaotong"
REMOTE_HOST="stu.comp.nus.edu.sg"
REMOTE_DIR="~/public_html"

echo "Deploying: $LOCAL_DIR → $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

# ===== Step 1. Clean old files =====
echo "Removing old files from server..."
ssh ${REMOTE_USER}@${REMOTE_HOST} 'rm -rf ~/public_html/{*,.[!.]*,..?*} || true'

# ===== Step 2. Upload new files =====
echo "Uploading new files..."
rsync -avz --delete "${LOCAL_DIR}/" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/

# ===== Step 3. Fix permissions =====
echo "Setting permissions..."
ssh ${REMOTE_USER}@${REMOTE_HOST} '
  find ~/public_html -type d -exec chmod 755 {} \; &&
  find ~/public_html -type f -exec chmod 644 {} \;
'

# ===== Step 4. Ensure UTF-8 encoding =====
echo "Writing .htaccess for UTF-8..."
ssh ${REMOTE_USER}@${REMOTE_HOST} 'cat > ~/public_html/.htaccess << "EOF"
AddDefaultCharset UTF-8
AddType "text/html; charset=UTF-8" .html .htm
AddType "text/css; charset=UTF-8"  .css
AddType "application/javascript; charset=UTF-8" .js
AddCharset UTF-8 .html .htm .css .js .json .txt .xml .svg
EOF'

echo "Deployment complete!"
echo "Visit your site at: https://www.comp.nus.edu.sg/~yaotong/"
