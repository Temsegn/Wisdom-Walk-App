// routes/bookingRoutes.js
const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const { authenticateToken, requireAdmin } = require("../middleware/auth");


router.post('/book',authenticateToken, bookingController.createBooking);        // User books advice
router.get('/bookings',authenticateToken, bookingController.getAllBookings); // Admin view
router.get('/my-books',authenticateToken, bookingController.getMyBookings); 

module.exports = router;
