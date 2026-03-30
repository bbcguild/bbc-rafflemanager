#!/bin/bash

# Fly.io Deployment Script for BBC Guild Raffle Manager
# This script safely deploys to multiple environments with explicit confirmation
#
# Usage:
#   ./deploy.sh <environment> [--force]
#
# Environments:
#   dev      - Development environment (bbcguild-raffle-dev)
#   test     - Test environment (bbcguild-raffle-test)  
#   staging  - Staging environment (bbcguild-raffle-staging)
#   prod     - Production environment (bbcguild-raffle)
#
# Examples:
#   ./deploy.sh dev
#   ./deploy.sh test --force
#   ./deploy.sh prod

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 BBC Guild Raffle Manager - Safe Multi-Environment Deployment${NC}"
echo "=================================================================="

# Function to display usage
show_usage() {
    echo "Usage: $0 <environment> [--force]"
    echo ""
    echo "Environments:"
    echo "  dev      - Development environment (bbcguild-raffle-dev)"
    echo "  test     - Test environment (bbcguild-raffle-test)"
    echo "  staging  - Staging environment (bbcguild-raffle-staging)"
    echo "  prod     - Production environment (bbcguild-raffle)"
    echo ""
    echo "Options:"
    echo "  --force  - Skip confirmation prompts (use with caution!)"
    echo ""
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 test --force"
    echo "  $0 prod"
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}❌ Error: Environment must be specified${NC}"
    echo ""
    show_usage
fi

ENVIRONMENT=$1
FORCE_MODE=false

if [ "$2" = "--force" ]; then
    FORCE_MODE=true
fi

# Validate environment and set configuration
case $ENVIRONMENT in
    "dev")
        APP_NAME="bbcguild-raffle-dev"
        VOLUME_NAME="raffle_data_dev"
        PYRAMID_DEBUG="1"
        LOG_LEVEL="DEBUG"
        MEMORY_SIZE="512mb"
        VOLUME_SIZE="1"
        MIN_MACHINES="0"
        CONFIG_FILE="fly.toml"
        ;;
    "test")
        APP_NAME="bbcguild-raffle-test"
        VOLUME_NAME="raffle_data_test"
        PYRAMID_DEBUG="1"
        LOG_LEVEL="DEBUG"
        MEMORY_SIZE="512mb"
        VOLUME_SIZE="1"
        MIN_MACHINES="0"
        CONFIG_FILE="fly.toml"
        ;;
    "staging")
        APP_NAME="bbcguild-raffle-staging"
        VOLUME_NAME="raffle_data_staging"
        PYRAMID_DEBUG="0"
        LOG_LEVEL="INFO"
        MEMORY_SIZE="1gb"
        VOLUME_SIZE="2"
        MIN_MACHINES="0"
        CONFIG_FILE="fly.toml"
        ;;
    "prod")
        APP_NAME="bbcguild-raffle"
        VOLUME_NAME="raffle_data"
        PYRAMID_DEBUG="0"
        LOG_LEVEL="INFO"
        MEMORY_SIZE="1gb"
        VOLUME_SIZE="2"
        MIN_MACHINES="1"
        CONFIG_FILE="fly.toml"
        ;;
    *)
        echo -e "${RED}❌ Error: Invalid environment '$ENVIRONMENT'${NC}"
        echo ""
        show_usage
        ;;
esac

echo -e "${BLUE}Environment:${NC} $ENVIRONMENT"
echo -e "${BLUE}App Name:${NC} $APP_NAME"
echo -e "${BLUE}Volume:${NC} $VOLUME_NAME (${VOLUME_SIZE}GB)"
echo -e "${BLUE}Memory:${NC} $MEMORY_SIZE"

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo -e "${RED}❌ flyctl is not installed. Please install it first:${NC}"
    echo "   curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if user is logged in
if ! flyctl auth whoami &> /dev/null; then
    echo -e "${RED}❌ You're not logged into fly.io. Please run:${NC}"
    echo "   flyctl auth login"
    exit 1
fi

echo -e "${GREEN}✅ flyctl is installed and you're logged in${NC}"

# Check if app already exists
APP_EXISTS=false
if flyctl apps list | grep -q "^$APP_NAME"; then
    APP_EXISTS=true
    echo -e "${YELLOW}⚠️  App '$APP_NAME' already exists${NC}"
    
    # Show current app status
    echo ""
    echo -e "${BLUE}Current app status:${NC}"
    flyctl status --app "$APP_NAME" 2>/dev/null || echo "  (Unable to get status)"
    echo ""
fi

# Safety confirmation for production
if [ "$ENVIRONMENT" = "prod" ] && [ "$FORCE_MODE" = false ]; then
    echo -e "${RED}🚨 WARNING: You are about to deploy to PRODUCTION!${NC}"
    echo -e "${RED}   App: $APP_NAME${NC}"
    echo -e "${RED}   This will affect the live production environment.${NC}"
    echo ""
    read -p "Are you absolutely sure you want to continue? (type 'YES' to confirm): " confirmation
    if [ "$confirmation" != "YES" ]; then
        echo -e "${YELLOW}❌ Deployment cancelled${NC}"
        exit 1
    fi
elif [ "$APP_EXISTS" = true ] && [ "$FORCE_MODE" = false ]; then
    echo -e "${YELLOW}⚠️  You are about to deploy to an existing app: $APP_NAME${NC}"
    echo ""
    read -p "Continue with deployment? (y/N): " confirmation
    if [ "$confirmation" != "y" ] && [ "$confirmation" != "Y" ]; then
        echo -e "${YELLOW}❌ Deployment cancelled${NC}"
        exit 1
    fi
fi
# Create app if it doesn't exist
if [ "$APP_EXISTS" = false ]; then
    echo -e "${BLUE}📦 Creating new fly.io app: $APP_NAME${NC}"
    flyctl apps create "$APP_NAME" --generate-name=false
else
    echo -e "${BLUE}📦 Using existing fly.io app: $APP_NAME${NC}"
fi

# Create volume for persistent storage if it doesn't exist
echo -e "${BLUE}💾 Setting up persistent volume: $VOLUME_NAME${NC}"

if ! flyctl volumes list --app "$APP_NAME" 2>/dev/null | grep -q "$VOLUME_NAME"; then
    echo -e "${BLUE}Creating volume: $VOLUME_NAME (${VOLUME_SIZE}GB)${NC}"
    flyctl volumes create "$VOLUME_NAME" --size "$VOLUME_SIZE" --app "$APP_NAME"
else
    echo -e "${GREEN}Volume $VOLUME_NAME already exists${NC}"
fi

# Set secrets for the environment
echo -e "${BLUE}🔐 Setting up environment secrets${NC}"
flyctl secrets set DATABASE_PATH="/data/raffle.db" --app "$APP_NAME"
flyctl secrets set IMPORT_PATH="/data/import" --app "$APP_NAME"
flyctl secrets set PYRAMID_DEBUG="$PYRAMID_DEBUG" --app "$APP_NAME"
flyctl secrets set LOG_LEVEL="$LOG_LEVEL" --app "$APP_NAME"

# Deploy the application
echo -e "${BLUE}🚀 Deploying application to $ENVIRONMENT environment${NC}"

# Create environment-specific fly.toml if needed
TEMP_CONFIG=""
if [ "$ENVIRONMENT" != "prod" ]; then
    TEMP_CONFIG="fly.${ENVIRONMENT}.toml"
    echo -e "${BLUE}📝 Creating environment-specific config: $TEMP_CONFIG${NC}"
    
    # Generate environment-specific fly.toml
    cat > "$TEMP_CONFIG" << EOF
# fly.${ENVIRONMENT}.toml - ${ENVIRONMENT^} environment configuration
app = '$APP_NAME'
primary_region = 'iad'

[build]
  dockerfile = 'Dockerfile.production'

[deploy]
  strategy = 'immediate'

[env]
  DATABASE_PATH = '/data/raffle.db'
  IMPORT_PATH = '/data/import'
  LOG_LEVEL = '$LOG_LEVEL'
  PYRAMID_DEBUG = '$PYRAMID_DEBUG'
  PYTHONPATH = '/app'

[processes]
  app = '/app/startup.sh'

[[mounts]]
  source = '$VOLUME_NAME'
  destination = '/data'
  initial_size = '${VOLUME_SIZE}gb'

[http_service]
  internal_port = 80
  force_https = true
  auto_stop_machines = 'stop'
  auto_start_machines = true
  min_machines_running = $MIN_MACHINES
  processes = ['app']

  [[http_service.checks]]
    interval = '30s'
    timeout = '5s'
    grace_period = '10s'
    method = 'GET'
    path = '/health'

[[restart]]
  policy = 'on-failure'

[[vm]]
  memory = '$MEMORY_SIZE'
  cpus = 1
EOF

    CONFIG_FILE="$TEMP_CONFIG"
fi

# Deploy with appropriate config
if [ -n "$TEMP_CONFIG" ]; then
    flyctl deploy --app "$APP_NAME" --config "$CONFIG_FILE" --dockerfile Dockerfile.production
else
    flyctl deploy --app "$APP_NAME" --dockerfile Dockerfile.production
fi

# Clean up temporary config
if [ -n "$TEMP_CONFIG" ] && [ -f "$TEMP_CONFIG" ]; then
    rm "$TEMP_CONFIG"
    echo -e "${BLUE}🧹 Cleaned up temporary config file${NC}"
fi

echo ""
echo -e "${GREEN}✅ Deployment to $ENVIRONMENT environment complete!${NC}"

# Check if local database exists and offer to transfer it
if [ -f "raffle.db" ] && [ "$FORCE_MODE" = false ]; then
    echo ""
    echo -e "${YELLOW}📁 Local database file detected: raffle.db${NC}"
    echo -e "${YELLOW}   This database is NOT automatically transferred to Fly.io${NC}"
    echo ""
    read -p "Would you like to transfer your local database to $ENVIRONMENT? (y/N): " transfer_db
    
    if [ "$transfer_db" = "y" ] || [ "$transfer_db" = "Y" ]; then
        echo -e "${BLUE}📤 Transferring database to $APP_NAME...${NC}"
        
        # Create a backup first
        echo "Creating backup of any existing database..."
        flyctl ssh console --app "$APP_NAME" -C "cp /data/raffle.db /data/raffle.db.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo 'No existing database to backup'"
        
        # Transfer the database
        echo "Uploading local database..."
        flyctl ssh sftp shell --app "$APP_NAME" --command "put raffle.db /data/raffle.db"
        
        # Set proper permissions
        flyctl ssh console --app "$APP_NAME" -C "chown app:app /data/raffle.db && chmod 644 /data/raffle.db"
        
        echo -e "${GREEN}✅ Database transfer complete!${NC}"
    else
        echo -e "${BLUE}ℹ️  Database transfer skipped. The app will use the template database.${NC}"
    fi
fi

echo ""
echo -e "${BLUE}🌐 Your application is available at:${NC} https://$APP_NAME.fly.dev"
echo -e "${BLUE}🏥 Health check:${NC} https://$APP_NAME.fly.dev/health"
echo ""
echo -e "${BLUE}📊 Monitor your app:${NC}"
echo "   flyctl logs --app $APP_NAME"
echo "   flyctl status --app $APP_NAME"
echo ""
echo -e "${BLUE}🔧 Useful commands:${NC}"
echo "   flyctl ssh console --app $APP_NAME     # SSH into the machine"
echo "   flyctl volumes list --app $APP_NAME   # Check volume status"
echo "   flyctl scale memory 1024 --app $APP_NAME  # Scale memory"
echo ""
echo -e "${BLUE}📤 Database management:${NC}"
echo "   # Upload local database:"
echo "   flyctl ssh sftp shell --app $APP_NAME --command 'put raffle.db /data/raffle.db'"
echo "   # Download database from server:"
echo "   flyctl ssh sftp shell --app $APP_NAME --command 'get /data/raffle.db raffle_backup.db'"
echo "   # Backup database on server:"
echo "   flyctl ssh console --app $APP_NAME -C 'cp /data/raffle.db /data/raffle.db.backup.\$(date +%Y%m%d_%H%M%S)'"
echo ""
echo -e "${BLUE}🔄 Deploy to other environments:${NC}"
echo "   ./deploy.sh dev     # Deploy to development"
echo "   ./deploy.sh test    # Deploy to test"
echo "   ./deploy.sh staging # Deploy to staging"
echo ""

# Show deployment summary
echo -e "${GREEN}📋 Deployment Summary:${NC}"
echo "   Environment: $ENVIRONMENT"
echo "   App Name: $APP_NAME"
echo "   Volume: $VOLUME_NAME (${VOLUME_SIZE}GB)"
echo "   Memory: $MEMORY_SIZE"
echo "   Debug Mode: $([[ $PYRAMID_DEBUG == "1" ]] && echo "Enabled" || echo "Disabled")"
echo "   Min Machines: $MIN_MACHINES"
