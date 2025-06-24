const mongoose = require('mongoose');

const movementSchema = new mongoose.Schema({
    user : {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    fromLocation: {
         city : String,
        country: String,
     },
    toLocation: {
        city: String,
        country: String,
    },
    note:{
        type: String,
        maxlength: 500,
    },
    movementDate: {
        type: Date,
        required: true,
        default: Date.now
    }

})

module.exports = mongoose.model('Movement', movementSchema);

