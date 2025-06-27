// controllers/bookingController.js
const Booking = require('../models/booking');

// Create new booking
exports.createBooking = async (req, res) => {
  try {
    const { issueTitle, issueDescription, phoneNumber, email } = req.body;
    const authorId = req.user._id

    const booking = new Booking({user:authorId,issueTitle, issueDescription, phoneNumber, email });
    await booking.save();
    res.status(201).json({ message: 'Booking created successfully', booking });
  } catch (error) {
    res.status(500).json({ message: 'Error creating booking', error });
  }
};

// Get all bookings (admin view)
exports.getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.find().sort({ createdAt: -1 });
    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching bookings', error });
  }
};
exports.getMyBookings = async (req, res) => {
  try {
    const user=req.user._id;

    const bookings = await Booking.find({
        user:user
    }).sort({ createdAt: -1 });
    
    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching bookings', error });
  }
};
