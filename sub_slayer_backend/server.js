require('dotenv').config();
const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes/subscriptionRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Alle Routen unter /api einhängen
app.use('/api', apiRoutes);

// Port aus .env oder default
const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;
app.listen(PORT, () => {
    console.log(`Server läuft auf Port ${PORT}`);
});