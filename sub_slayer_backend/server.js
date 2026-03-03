const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// 1. Datenbank erstellen & verbinden (macht SQLite automatisch)
const db = new sqlite3.Database('./subslayer.db', (err) => {
    if (err) {
        console.error('Datenbank-Fehler:', err.message);
    } else {
        console.log('Erfolgreich mit der eingebauten SQLite-Datenbank verbunden!');
    }
});

// 2. Tabellen anlegen (2 Tabellen, 1:n)
db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT
    )`);

    db.run(`CREATE TABLE IF NOT EXISTS subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        start_date TEXT NOT NULL,
        category_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories(id)
    )`);

    // Standard-Kategorien einfügen, wenn sie nicht existieren
    const insertCat = db.prepare(`INSERT INTO categories (name, color_hex) SELECT ?, ? WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = ?)`);
    insertCat.run('Gaming', '#6B48FF', 'Gaming');
    insertCat.run('Streaming', '#FF4858', 'Streaming');
    insertCat.run('Mobile', '#4885FF', 'Mobile');
    insertCat.run('Musik', '#B848FF', 'Musik');
    insertCat.run('Bildung', '#48FF85', 'Bildung');
    insertCat.finalize();
});

// ==========================================
// REST-API ENDPUNKTE
// ==========================================

// Alle Kategorien abrufen
app.get('/api/categories', (req, res) => {
    db.all('SELECT * FROM categories', [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// Alle Abonnements abrufen
app.get('/api/subscriptions', (req, res) => {
    const query = `
        SELECT s.id, s.name, s.price, s.description, s.start_date, c.name as category_name, c.color_hex 
        FROM subscriptions s
        LEFT JOIN categories c ON s.category_id = c.id
    `;
    db.all(query, [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// Neues Abonnement hinzufügen
app.post('/api/subscriptions', (req, res) => {
    const { name, price, description, start_date, category_id } = req.body;
    db.run(`INSERT INTO subscriptions (name, price, description, start_date, category_id) VALUES (?, ?, ?, ?, ?)`, 
        [name, price, description, start_date, category_id], 
        function(err) {
            if (err) return res.status(500).json({ error: err.message });
            res.status(201).json({ id: this.lastID, message: 'Abo erfolgreich hinzugefügt' });
        }
    );
});

// Abonnement löschen
app.delete('/api/subscriptions/:id', (req, res) => {
    db.run(`DELETE FROM subscriptions WHERE id = ?`, req.params.id, function(err) {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Abo gelöscht', changes: this.changes });
    });
});

// Server starten
const PORT = 3000;
app.listen(PORT, () => {
    console.log("Server läuft auf Port " + PORT);
});