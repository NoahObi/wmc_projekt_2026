class CreateSubscriptionDto {
    constructor(data) {
        this.name = typeof data.name === 'string' ? data.name.trim() : '';
        this.price = typeof data.price === 'number' ? data.price : parseFloat(data.price);
        this.description = typeof data.description === 'string' ? data.description : '';
        this.start_date = typeof data.start_date === 'string' ? data.start_date : '';
        this.billing_interval = typeof data.billing_interval === 'string' && data.billing_interval.length > 0 ? data.billing_interval : 'monthly';
        this.category_id = typeof data.category_id === 'number' ? data.category_id : parseInt(data.category_id, 10);
    }

    isValid() {
        // Name darf nicht leer sein
        if (!this.name || typeof this.name !== 'string' || this.name.length < 2) return false;
        // Preis muss eine Zahl > 0 sein
        if (isNaN(this.price) || this.price <= 0) return false;
        // Startdatum muss gesetzt sein
        if (!this.start_date || typeof this.start_date !== 'string' || this.start_date.length < 8) return false;
        // Kategorie muss gesetzt sein
        if (isNaN(this.category_id) || this.category_id <= 0) return false;
        // Rechnungsintervall muss gesetzt sein
        if (!this.billing_interval || typeof this.billing_interval !== 'string') return false;
        return true;
    }
}

module.exports = { CreateSubscriptionDto };