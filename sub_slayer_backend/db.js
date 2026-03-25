const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'subslayer.sqlite');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Fehler beim Verbinden mit der SQLite Datenbank:', err.message);
    } else {
        console.log('Verbunden mit der SQLite Datenbank.');
    }
});

db.serialize(() => {
    // 1. Tabelle: Kategorien
    db.run(`CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
    )`);

    // 2. Tabelle: Abonnements 
    db.run(`CREATE TABLE IF NOT EXISTS subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        start_date TEXT NOT NULL,
        billing_interval TEXT NOT NULL DEFAULT 'monthly', -- z.B. 'monthly', 'yearly'
        category_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id)
    )`);

    // 3. Tabelle: Zahlungsverlauf 
    db.run(`CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subscription_id INTEGER NOT NULL,
        payment_date TEXT NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (subscription_id) REFERENCES subscriptions (id) ON DELETE CASCADE
    )`);

    // Standard-Kategorien
    db.get("SELECT COUNT(*) AS count FROM categories", (err, row) => {
        if (row.count === 0) {
            const stmt = db.prepare("INSERT INTO categories (name) VALUES (?)");
            ['Gaming', 'Streaming', 'Mobile', 'Musik', 'Bildung'].forEach(cat => stmt.run(cat));
            stmt.finalize();
        }
    });
});

module.exports = db;