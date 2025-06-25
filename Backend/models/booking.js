// models/Booking.js
const mongoose = require('mongoose');


const bookingSchema = new mongoose.Schema({
  user : {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User',
          required: true
      }, 
  issueTitle: { type: String, required: true },
  issueDescription: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  email: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Booking', bookingSchema);
