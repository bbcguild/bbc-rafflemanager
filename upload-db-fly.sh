#!/bin/bash

# Upload database to Fly.io app
# Usage: ./upload-db-fly.sh <environment> [database-file]

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📤 Database Upload to Fly.io${NC}"
echo "================================"

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}❌ Error: Environment must be specified${NC}"
    echo "Usage: $0 <environment> [database-file]"
    echo "Environments: dev, test, staging, prod"
    exit 1
fi

ENVIRONMENT=$1
DB_FILE=${2:-"raffle.db"}

# Set app name based on environment
case $ENVIRONMENT in
    "dev")
        APP_NAME="bbcguild-raffle-dev"
        ;;
    "test")
        APP_NAME="bbcguild-raffle-test"
        ;;
    "staging")
        APP_NAME="bbcguild-raffle-staging"
        ;;
    "prod")
        APP_NAME="bbcguild-raffle"
        ;;
    *)
        echo -e "${RED}❌ Error: Invalid environment '$ENVIRONMENT'${NC}"
        exit 1
        ;;
esac

# Check if database file exists
if [ ! -f "$DB_FILE" ]; then
    echo -e "${RED}❌ Error: Database file '$DB_FILE' not found${NC}"
    exit 1
fi

echo -e "${BLUE}Environment:${NC} $ENVIRONMENT"
echo -e "${BLUE}App Name:${NC} $APP_NAME"
echo -e "${BLUE}Database File:${NC} $DB_FILE"
echo -e "${BLUE}File Size:${NC} $(du -h "$DB_FILE" | cut -f1)"

# Safety confirmation for production
if [ "$ENVIRONMENT" = "prod" ]; then
    echo -e "${RED}🚨 WARNING: You are about to overwrite the PRODUCTION database!${NC}"
    echo -e "${RED}   This will replace all data in the production environment.${NC}"
    echo ""
    read -p "Are you absolutely sure you want to continue? (type 'YES' to confirm): " confirmation
    if [ "$confirmation" != "YES" ]; then
        echo -e "${YELLOW}❌ Upload cancelled${NC}"
        exit 1
    fi
else
    echo ""
    read -p "Continue with database upload to $ENVIRONMENT? (y/N): " confirmation
    if [ "$confirmation" != "y" ] && [ "$confirmation" != "Y" ]; then
        echo -e "${YELLOW}❌ Upload cancelled${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}🔄 Creating backup of existing database...${NC}"
flyctl ssh console --app "$APP_NAME" -C "cp /data/raffle.db /data/raffle.db.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo 'No existing database to backup'"

echo -e "${BLUE}📤 Uploading database...${NC}"
flyctl ssh sftp shell --app "$APP_NAME" --command "put $DB_FILE /data/raffle.db"

echo -e "${BLUE}🔧 Setting permissions...${NC}"
flyctl ssh console --app "$APP_NAME" -C "chown app:app /data/raffle.db && chmod 644 /data/raffle.db"

echo -e "${BLUE}🔄 Restarting application...${NC}"
flyctl apps restart "$APP_NAME"

echo ""
echo -e "${GREEN}✅ Database upload complete!${NC}"
echo -e "${BLUE}🌐 Check your app:${NC} https://$APP_NAME.fly.dev"
echo ""
echo -e "${BLUE}🔍 Verify upload:${NC}"
echo "   flyctl ssh console --app $APP_NAME -C 'ls -la /data/raffle.db'"
echo "   flyctl ssh console --app $APP_NAME -C 'sqlite3 /data/raffle.db \".tables\"'"
