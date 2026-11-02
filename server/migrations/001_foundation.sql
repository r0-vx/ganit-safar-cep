CREATE TABLE IF NOT EXISTS users(id TEXT PRIMARY KEY,email TEXT UNIQUE,name TEXT,role TEXT,salt TEXT,password_hash TEXT);
CREATE TABLE IF NOT EXISTS sessions(token_hash TEXT PRIMARY KEY,user_id TEXT,expires REAL);
CREATE TABLE IF NOT EXISTS classrooms(id TEXT PRIMARY KEY,name TEXT,school TEXT,grade INTEGER,teacher_id TEXT);
CREATE TABLE IF NOT EXISTS devices(id TEXT PRIMARY KEY,secret_hash TEXT,name TEXT,classroom_id TEXT,active INTEGER DEFAULT 1,revoked INTEGER DEFAULT 0,last_seen REAL,last_sync REAL,version TEXT,activity INTEGER DEFAULT 0,health TEXT DEFAULT 'ok');
CREATE TABLE IF NOT EXISTS audit(id INTEGER PRIMARY KEY,at REAL,actor TEXT,action TEXT,target TEXT);
