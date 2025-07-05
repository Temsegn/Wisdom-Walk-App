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

}
, {
    timestamps: true, // Automatically manage createdAt and updatedAt fields
});


movementSchema.pre('save', function(next) {
    // Ensure movementDate is set to current date if not provided
    if (!this.movementDate) {
        this.movementDate = new Date();
    }
    next();
});

movementSchema.index({ user: 1, movementDate: -1 }); // Index for efficient querying

module.exports = mongoose.model('Movement', movementSchema);

