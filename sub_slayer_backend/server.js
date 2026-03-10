const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes/subscriptionRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Alle Routen unter /api einhängen
app.use('/api', apiRoutes);

const PORT = 3000;
app.listen(PORT, () => {
    console.log("Server läuft auf Port " + PORT);
});