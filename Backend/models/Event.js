const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title'],
    trim: true,
    maxlength: [100, 'Title cannot be more than 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Please add a description'],
    maxlength: [500, 'Description cannot be more than 500 characters']
  },
  platform: {
    type: String,
    required: [true, 'Please specify the platform'],
    enum: ['Zoom', 'Google Meet'],
    default: 'Zoom'
  },
  date: {
    type: Date,
    required: [true, 'Please add a date for the event']
  },
  time: {
    type: String,
    required: [true, 'Please add a time for the event']
  },
  duration: {
    type: Number, // in minutes
    required: [true, 'Please add duration of the event']
  },
  meetingLink: {
    type: String,
    required: [true, 'Please add the meeting link']
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Event', eventSchema);