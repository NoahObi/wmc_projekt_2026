class CreateSubscriptionDto {
    constructor(data) {
        this.name = data.name;
        this.price = parseFloat(data.price);
        this.description = data.description || '';
        this.start_date = data.start_date;
        this.billing_interval = data.billing_interval || 'monthly'; // Neues Feld!
        this.category_id = parseInt(data.category_id, 10);
    }

    isValid() {
        return this.name && !isNaN(this.price) && this.start_date && !isNaN(this.category_id);
    }
}

module.exports = { CreateSubscriptionDto };