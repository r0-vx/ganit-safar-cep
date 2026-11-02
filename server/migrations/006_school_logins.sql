CREATE TABLE school_logins(school_id TEXT PRIMARY KEY REFERENCES schools(id),user_id TEXT UNIQUE NOT NULL REFERENCES users(id),created_at REAL NOT NULL);
