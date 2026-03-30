#!/usr/bin/env python3
"""
Database initialization script for production deployment.
Ensures the database exists and is properly initialized.
"""

import os
import sqlite3
import shutil

def init_database():
    """Initialize the database if it doesn't exist.
    
    Returns:
        str: The path to the database that should be used.
    """
    
    # Determine database path based on environment
    # Check for specific container markers rather than just directory existence
    current_dir = os.getcwd()
    
    # Production container environment: /app working directory with writable /data
    if (current_dir == '/app' and 
        os.path.exists('/data') and 
        os.access('/data', os.W_OK) and
        os.path.exists('/app/schema.sql')):
        # Production container environment with persistent volume
        default_db_path = '/data/raffle.db'
        schema_path = '/app/schema.sql'
        test_data_path = '/app/test_data.sql'
        app_db_path = '/app/raffle.db'
        print("Detected environment: Production Container")
    else:
        # Local development or dev container environment
        # Use the directory where the script is located
        script_dir = os.path.dirname(os.path.abspath(__file__))
        default_db_path = os.path.join(script_dir, 'raffle.db')
        schema_path = os.path.join(script_dir, 'schema.sql')
        test_data_path = os.path.join(script_dir, 'test_data.sql')
        
        # For dev containers, also check common mounted locations
        possible_source_paths = [
            os.path.join(script_dir, 'raffle.db'),  # Same directory as script
            '/workspaces/bbc-rafflemanager/raffle.db',  # Common dev container mount
            default_db_path  # Default
        ]
        
        app_db_path = None
        for path in possible_source_paths:
            if os.path.exists(path) and path != default_db_path:
                app_db_path = path
                break
        
        if app_db_path is None:
            app_db_path = default_db_path  # Same location for local dev
            
        print(f"Detected environment: Local Development (working dir: {current_dir})")
        print(f"Script directory: {script_dir}")
        print(f"App database path: {app_db_path}")
    
    # Allow override via environment variable first
    db_path = os.getenv('DATABASE_PATH')
    
    if db_path:
        print(f"Using DATABASE_PATH environment variable: {db_path}")
        # For custom paths, use local schema files
        script_dir = os.path.dirname(os.path.abspath(__file__))
        schema_path = os.path.join(script_dir, 'schema.sql')
        test_data_path = os.path.join(script_dir, 'test_data.sql')
        app_db_path = db_path  # Same location
    else:
        db_path = default_db_path
    
    print(f"=== DATABASE INITIALIZATION ===")
    print(f"Target database path: {db_path}")
    print(f"Schema path: {schema_path}")
    print(f"Schema exists: {os.path.exists(schema_path)}")
    print(f"Current working directory: {os.getcwd()}")
    print(f"DATABASE_PATH env: {os.getenv('DATABASE_PATH', 'NOT SET')}")
    print(f"Environment type: {'Container' if '/data' in db_path else 'Local Development'}")
    
    # Check if we can write to the target database location
    db_dir = os.path.dirname(db_path)
    if db_dir and not os.access(db_dir, os.W_OK):
        print(f"WARNING: Cannot write to {db_dir}")
        # Fall back to a writable location
        script_dir = os.path.dirname(os.path.abspath(__file__))
        fallback_db_path = os.path.join(script_dir, 'raffle.db')
        print(f"Using fallback database path: {fallback_db_path}")
        
        # Update dbconf to use the fallback path
        import dbconf
        dbconf.DATABASE_PATH = fallback_db_path
        dbconf.DATABASE = fallback_db_path
        
        db_path = fallback_db_path
    
    # Ensure the directory exists
    db_dir = os.path.dirname(db_path)
    if db_dir:  # Only create directory if there is one (not for relative filenames)
        print(f"Creating directory: {db_dir}")
        os.makedirs(db_dir, exist_ok=True)
    else:
        print("Database is in current directory, no directory creation needed")
    
    # List contents of /data directory
    if os.path.exists('/data'):
        print(f"Contents of /data: {os.listdir('/data')}")
    else:
        print("/data directory does not exist")
    
    # Check if database already exists and has proper schema
    if os.path.exists(db_path):
        print(f"Database file exists at {db_path} (size: {os.path.getsize(db_path)} bytes)")
        try:
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()
            # Check if guilds table exists
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='guilds'")
            result = cursor.fetchone()
            if result:
                print("Database schema is valid, skipping initialization")
                conn.close()
                return db_path
            else:
                print("Database exists but lacks proper schema, reinitializing...")
                cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
                tables = cursor.fetchall()
                print(f"Existing tables: {[t[0] for t in tables]}")
                conn.close()
                print(f"Removing invalid database file: {db_path}")
                os.remove(db_path)
        except Exception as e:
            print(f"Error checking database schema: {e}")
            try:
                conn.close()
            except:
                pass
            print("Removing corrupted database file...")
            if os.path.exists(db_path):
                os.remove(db_path)
    else:
        print(f"Database file does not exist at {db_path}")
    
    # If there's an existing database in the app directory (containers), copy it
    # For local development, app_db_path equals db_path, so skip this step
    if app_db_path != db_path:
        print(f"Checking for source database at {app_db_path}")
        print(f"Source database exists: {os.path.exists(app_db_path)}")
        if os.path.exists(app_db_path):
            print(f"Found existing database at {app_db_path} (size: {os.path.getsize(app_db_path)} bytes)")
            # Verify the source database has proper schema
            try:
                conn = sqlite3.connect(app_db_path)
                cursor = conn.cursor()
                cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='guilds'")
                result = cursor.fetchone()
                if result:
                    print(f"Source database is valid, copying to {db_path}")
                    conn.close()
                    
                    # Check if we can write to the target directory
                    target_dir = os.path.dirname(db_path)
                    if target_dir and not os.access(target_dir, os.W_OK):
                        print(f"WARNING: Cannot write to target directory {target_dir}")
                        print(f"Using source database directly: {app_db_path}")
                        # Update the database path to use source directly
                        db_path = app_db_path
                        # Also update dbconf to use this path
                        import dbconf
                        dbconf.DATABASE_PATH = db_path
                        dbconf.DATABASE = db_path
                        return db_path
                    
                    shutil.copy2(app_db_path, db_path)
                    print(f"Database copy completed successfully (new size: {os.path.getsize(db_path)} bytes)")
                    # Verify copy worked
                    conn = sqlite3.connect(db_path)
                    cursor = conn.cursor()
                    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
                    tables = cursor.fetchall()
                    print(f"Copied database tables: {[t[0] for t in tables]}")
                    conn.close()
                    return db_path
                else:
                    print("Source database lacks proper schema, will create new one")
                    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
                    tables = cursor.fetchall()
                    print(f"Source database tables: {[t[0] for t in tables]}")
                    conn.close()
            except Exception as e:
                print(f"Error checking source database: {e}")
                print("Will create new database from schema")
    
    # Create new database from schema
    print("=== CREATING NEW DATABASE FROM SCHEMA ===")
    try:
        print(f"Connecting to database: {db_path}")
        conn = sqlite3.connect(db_path)
        
        # Read and execute schema
        if os.path.exists(schema_path):
            print(f"Reading schema from: {schema_path}")
            with open(schema_path, 'r', encoding='utf-8') as f:
                schema_sql = f.read()
            print(f"Schema content length: {len(schema_sql)} characters")
            print("Executing schema...")
            conn.executescript(schema_sql)
            print("Schema applied successfully")
            
            # Verify schema was applied
            cursor = conn.cursor()
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
            tables = cursor.fetchall()
            print(f"Created tables: {[t[0] for t in tables]}")
        else:
            # Try to use template database as fallback
            template_db_path = os.path.join(os.getcwd(), 'raffle_template.db')
            if os.path.exists(template_db_path):
                print(f"Schema file not found, using template database: {template_db_path}")
                conn.close()
                shutil.copy2(template_db_path, db_path)
                print(f"Template database copied successfully (size: {os.path.getsize(db_path)} bytes)")
                
                # Verify copy worked
                conn = sqlite3.connect(db_path)
                cursor = conn.cursor()
                cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
                tables = cursor.fetchall()
                print(f"Template database tables: {[t[0] for t in tables]}")
            else:
                print(f"ERROR: Schema file not found at {schema_path}")
                print(f"ERROR: Template database not found at {template_db_path}")
                raise FileNotFoundError(f"Neither schema file nor template database found")
        
        # Create default admin user if no auth users exist
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM auth_users")
        user_count = cursor.fetchone()[0]
        
        if user_count == 0:
            print("No admin users found. Creating default admin user...")
            # Create a default admin user using a pre-computed BCrypt hash
            # This hash corresponds to the password "admin123" with BCrypt rounds=12
            # Generated with: bcrypt.hashpw(b'admin123', bcrypt.gensalt(rounds=12))
            default_hash = "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LetoWOQF3gqoX/uUW"
            
            cursor.execute(
                "INSERT INTO auth_users (auth_name, auth_password) VALUES (?, ?)",
                ('admin', default_hash)
            )
            print("Default admin user created:")
            print("  Username: admin")
            print("  Password: admin123") 
            print("  ⚠️  IMPORTANT: Change this password immediately after first login!")
        else:
            print(f"Found {user_count} existing auth users, skipping default user creation")
        
        # Optionally load test data (only if explicitly requested)
        if os.path.exists(test_data_path) and os.getenv('LOAD_TEST_DATA', '').lower() == 'true':
            print("Loading test data...")
            with open(test_data_path, 'r', encoding='utf-8') as f:
                test_sql = f.read()
            conn.executescript(test_sql)
            print("Test data loaded")
        
        conn.commit()
        conn.close()
        
        print(f"Database initialization completed successfully (final size: {os.path.getsize(db_path)} bytes)")
        return db_path
        
    except Exception as e:
        print(f"ERROR initializing database: {e}")
        import traceback
        traceback.print_exc()
        if os.path.exists(db_path):
            print(f"Removing failed database file: {db_path}")
            os.remove(db_path)
        raise

def init_import_directory():
    """Ensure import directory exists."""
    import_path = os.getenv('IMPORT_PATH', '/data/import')
    os.makedirs(import_path, exist_ok=True)
    print(f"Import directory ready at: {import_path}")

if __name__ == "__main__":
    init_database()
    init_import_directory()
    print("Initialization complete!")
