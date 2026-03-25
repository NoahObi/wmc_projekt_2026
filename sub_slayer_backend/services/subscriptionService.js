const db = require('../db');

class SubscriptionService {
    getAllCategories() {
        return new Promise((resolve, reject) => {
            db.all('SELECT * FROM categories', [], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    getAllSubscriptions() {
        return new Promise((resolve, reject) => {
            // color_hex entfernt, billing_interval hinzugefügt
            const query = `
                SELECT s.id, s.name, s.price, s.description, s.start_date, s.billing_interval, c.name as category_name 
                FROM subscriptions s
                LEFT JOIN categories c ON s.category_id = c.id
            `;
            db.all(query, [], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    async getSubscriptionById(id) {
        const query = `
            SELECT s.id, s.name, s.price, s.description, s.start_date, s.billing_interval, s.category_id, c.name as category_name
            FROM subscriptions s
            LEFT JOIN categories c ON s.category_id = c.id
            WHERE s.id = ?
        `;
        return new Promise((resolve, reject) => {
            db.get(query, [id], (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        });
    }

    addSubscription(dto) {
        const self = this;
        return new Promise((resolve, reject) => {
            // billing_interval zur Datenbank-Abfrage hinzugefügt
            const query = `INSERT INTO subscriptions (name, price, description, start_date, billing_interval, category_id) VALUES (?, ?, ?, ?, ?, ?)`;
            db.run(query, [dto.name, dto.price, dto.description, dto.start_date, dto.billing_interval, dto.category_id], function(err) {
                if (err) return reject(err);

                const lastId = this.lastID;
                self.getSubscriptionById(lastId)
                    .then(resolve)
                    .catch(reject);
            });
        });
    }

    deleteSubscription(id) {
        return new Promise((resolve, reject) => {
            db.run(`DELETE FROM subscriptions WHERE id = ?`, [id], function(err) {
                if (err) reject(err);
                else resolve({ message: 'Abo gelöscht', changes: this.changes });
            });
        });
    }

    updateSubscription(id, dto) {
        const self = this;
        return new Promise((resolve, reject) => {
            const query = `UPDATE subscriptions SET name = ?, price = ?, description = ?, start_date = ?, billing_interval = ?, category_id = ? WHERE id = ?`;
            db.run(query, [dto.name, dto.price, dto.description, dto.start_date, dto.billing_interval, dto.category_id, id], function(err) {
                if (err) return reject(err);

                self.getSubscriptionById(id)
                    .then(resolve)
                    .catch(reject);
            });
        });
    }
}

module.exports = new SubscriptionService();