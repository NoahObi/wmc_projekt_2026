const express = require('express');
const router = express.Router();
const subscriptionService = require('../services/subscriptionService');
const { CreateSubscriptionDto } = require('../dtos/subscriptionDto');

// Alle Kategorien abrufen
router.get('/categories', async (req, res) => {
    try {
        const categories = await subscriptionService.getAllCategories();
        res.json(categories);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Alle Abonnements abrufen
router.get('/subscriptions', async (req, res) => {
    try {
        const subs = await subscriptionService.getAllSubscriptions();
        res.json(subs);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Neues Abonnement hinzufügen
router.post('/subscriptions', async (req, res) => {
    const dto = new CreateSubscriptionDto(req.body);
    
    if (!dto.isValid()) {
        return res.status(400).json({ error: 'Fehlerhafte oder unvollständige Daten' });
    }

    try {
        const result = await subscriptionService.addSubscription(dto);
        res.status(201).json(result);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Abonnement löschen
router.delete('/subscriptions/:id', async (req, res) => {
    try {
        const result = await subscriptionService.deleteSubscription(req.params.id);
        res.json(result);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Abonnement aktualisieren
router.put('/subscriptions/:id', async (req, res) => {
    const dto = new CreateSubscriptionDto(req.body);

    if (!dto.isValid()) {
        return res.status(400).json({ error: 'Fehlerhafte oder unvollständige Daten' });
    }

    try {
        const result = await subscriptionService.updateSubscription(req.params.id, dto);
        res.json(result);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;