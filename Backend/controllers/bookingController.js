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
    const bookings = await Booking.find()
      .sort({ createdAt: -1 })
      .populate({
        path: 'user',
        select: 'firstName lastName email profilePicture', // Only include needed fields
        match: { _id: { $exists: true } } // Ensure user exists
      })
      .lean(); // Convert to plain JS object

    // Normalize the data structure
    const normalizedBookings = bookings.map(booking => ({
      _id: booking._id,
      user: booking.user || { // Provide fallback user object
        firstName: 'Unknown',
        lastName: 'User',
        email: '',
        profilePicture: ''
      },
      issueTitle: booking.issueTitle,
      issueDescription: booking.issueDescription,
      phoneNumber: booking.phoneNumber,
      email: booking.email || booking.user?.email || '', // Fallback email
      virtualSession: booking.virtualSession || false,
      createdAt: booking.createdAt
    }));

    res.status(200).json(normalizedBookings);
  } catch (error) {
    console.error('Error fetching booking:', error);
    res.status(500).json({ 
      message: 'Error fetching bookings',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
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
