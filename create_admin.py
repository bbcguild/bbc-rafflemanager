#!/usr/bin/env python3
"""
Create Admin User Script for BBC Guild Raffle Manager

This script creates an administrative user that can log into the raffle system.
Use this when you need to manually create admin accounts.

Usage:
    python create_admin.py
    python create_admin.py --username admin --password mypassword

Environment variables can be used to override the database path:
    DATABASE_PATH=/path/to/raffle.db python create_admin.py
"""

import argparse
import getpass
import os
import sqlite3
import sys

try:
    from cryptacular.bcrypt import BCRYPTPasswordManager
    HAS_BCRYPT = True
except ImportError:
    HAS_BCRYPT = False
    print("⚠️  Warning: cryptacular not available. Install requirements.txt for proper password hashing.")
    print("   Falling back to insecure hashing method for development only.")
    import hashlib


def get_database_path():
    """Get the database path using the same logic as the main application"""
    # Use environment variable first
    db_path = os.getenv('DATABASE_PATH')
    if db_path:
        return db_path
    
    # Determine based on environment (same logic as dbconf.py)
    current_dir = os.getcwd()
    
    if (current_dir == '/app' and 
        os.path.exists('/data') and 
        os.access('/data', os.W_OK)):
        return '/data/raffle.db'
    else:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        return os.path.join(script_dir, 'raffle.db')


def check_database_exists(db_path):
    """Check if the database exists and has the required tables"""
    if not os.path.exists(db_path):
        print(f"❌ Database not found at: {db_path}")
        print("   Please run the application first to initialize the database.")
        return False
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='auth_users'")
        result = cursor.fetchone()
        conn.close()
        
        if not result:
            print(f"❌ Database exists but auth_users table not found.")
            print("   Please run the application first to initialize the database schema.")
            return False
        
        return True
    except Exception as e:
        print(f"❌ Error checking database: {e}")
        return False


def user_exists(db_path, username):
    """Check if a user already exists"""
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT auth_id FROM auth_users WHERE auth_name = ?", (username,))
        result = cursor.fetchone()
        conn.close()
        return result is not None
    except Exception as e:
        print(f"❌ Error checking user existence: {e}")
        return False


def create_admin_user(db_path, username, password):
    """Create an admin user in the database"""
    try:
        # Hash the password
        if HAS_BCRYPT:
            password_manager = BCRYPTPasswordManager()
            hashed_password = password_manager.encode(password, rounds=12)
            print("Using BCrypt password hashing")
        else:
            # This is insecure and only for development
            hashed_password = hashlib.sha256(password.encode()).hexdigest()
            print("⚠️  Using insecure SHA256 hashing (development only)")
            print("   Install cryptacular for production use")
        
        # Insert into database
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO auth_users (auth_name, auth_password) VALUES (?, ?)",
            (username, hashed_password)
        )
        user_id = cursor.lastrowid
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS auth_user_roles (
                auth_user_role_id INTEGER PRIMARY KEY,
                auth_user INTEGER NOT NULL,
                auth_role TEXT NOT NULL,
                auth_guild INTEGER,
                CONSTRAINT uniq_auth_role UNIQUE (auth_user, auth_role, auth_guild)
            )
            """
        )
        cursor.execute(
            "INSERT OR IGNORE INTO auth_user_roles (auth_user, auth_role, auth_guild) VALUES (?, ?, NULL)",
            (user_id, "superadmin")
        )
        conn.commit()
        conn.close()
        
        print(f"✅ Admin user '{username}' created successfully!")
        print(f"   Database: {db_path}")
        print(f"   You can now log in at: http://your-app-url/auth/login")
        
        if not HAS_BCRYPT:
            print("⚠️  WARNING: Password hashed with insecure method!")
            print("   This user may not work in production. Use the container environment to create production users.")
        
        return True
        
    except Exception as e:
        print(f"❌ Error creating user: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Create an administrative user for the BBC Guild Raffle Manager",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python create_admin.py
  python create_admin.py --username myadmin --password secret123
  DATABASE_PATH=/custom/path/raffle.db python create_admin.py
        """
    )
    
    parser.add_argument('--username', '-u', 
                       help='Admin username (default: admin)')
    parser.add_argument('--password', '-p', 
                       help='Admin password (will prompt if not provided)')
    parser.add_argument('--force', '-f', action='store_true',
                       help='Force creation even if user already exists')
    
    args = parser.parse_args()
    
    print("🔐 BBC Guild Raffle Manager - Admin User Creator")
    print("=" * 50)
    
    # Get database path
    db_path = get_database_path()
    print(f"📁 Database location: {db_path}")
    
    # Check database
    if not check_database_exists(db_path):
        sys.exit(1)
    
    # Get username
    username = args.username
    if not username:
        username = input("Enter admin username [admin]: ").strip()
        if not username:
            username = 'admin'
    
    # Check if user exists
    if user_exists(db_path, username):
        if not args.force:
            print(f"❌ User '{username}' already exists!")
            print("   Use --force to overwrite, or choose a different username.")
            sys.exit(1)
        else:
            print(f"⚠️  User '{username}' already exists, but --force specified. Continuing...")
            # Note: This will fail with a database constraint error, which is fine
    
    # Get password
    password = args.password
    if not password:
        while True:
            password = getpass.getpass("Enter admin password: ")
            if not password:
                print("❌ Password cannot be empty!")
                continue
            
            if len(password) < 6:
                print("❌ Password must be at least 6 characters long!")
                continue
                
            confirm = getpass.getpass("Confirm password: ")
            if password != confirm:
                print("❌ Passwords don't match!")
                continue
                
            break
    
    # Create user
    print(f"👤 Creating admin user '{username}'...")
    
    if create_admin_user(db_path, username, password):
        print("\n🎉 Admin user created successfully!")
        print("\n📋 Next steps:")
        print("   1. Start your raffle application")
        print("   2. Navigate to the login page")
        print(f"   3. Log in with username: {username}")
        print("   4. Change your password for security")
    else:
        print("\n❌ Failed to create admin user.")
        sys.exit(1)


if __name__ == '__main__':
    main()
