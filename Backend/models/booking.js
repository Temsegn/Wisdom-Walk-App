// models/Booking.js
const mongoose = require('mongoose');


const bookingSchema = new mongoose.Schema({
  user : {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User',
          required: true
      }, 
  issueTitle: { type: String,     
     enum: ["Marriage and Ministry", "Single and Purposeful", "Healing and Forgiveness","Mental Health and Faith"],
     required: true 
    },
  issueDescription: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  email: { type: String, required: true },
  virtualSession: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now ,required: true },
  


});

module.exports = mongoose.model('Booking', bookingSchema);
