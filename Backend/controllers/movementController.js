const Movement = require("../models/movement.js");
const User = require("../models/User");

exports.postMove = async (req, res) => {
  try {
    const { fromLocation, toLocation, note } = req.body;
    const movement = await Movement.create({
      user: req.user._id,
      fromLocation,
      toLocation,
      note,
    });
    res.status(201).json(movement);
  } catch (error) {
    res.status(500).json({ message: "Error posting move", error });
  }
};

exports.getAllMoves=async (req,res)=>{
     const moves = Movement.find().sort({ movedAt: -1 }).populate("user", "firstName lastName profilePicture");
  try {
    const allMoves = await moves;
    res.status(200).json(allMoves);
  } catch (error) {
    res.status(500).json({ message: "Error fetching moves", error });
  }
}
exports.getMovesDetail= async (req, res) => {
  try {
    const { moveId } = req.params;
    const move = await Movement.findById(moveId).populate("user", "firstName lastName profilePicture");
    if (!move) {
      return res.status(404).json({ message: "Move not found" });
    }
    res.status(200).json(move);
  } catch (error) {
    res.status(500).json({ message: "Error fetching move details", error });
  }
};

exports.getMyMoves = async (req, res) => {
  try {
    const moves = await Movement.find({ user: req.user._id }).sort({ movedAt: -1 });
    res.status(200).json(moves);
  } catch (error) {
    res.status(500).json({ message: "Error fetching your moves", error });
  }
};

exports.getUserMoves = async (req, res) => {
  try {
    const { userId } = req.params;
    const moves = await Movement.find({ user: userId }).sort({ movedAt: -1 }).populate("user", "firstName lastName profilePicture");
    res.status(200).json(moves);
  } catch (error) {
    res.status(500).json({ message: "Error fetching user moves", error });
  }
};

exports.searchUsers = async (req, res) => {
  try {
    const { query } = req.query;
    const users = await User.find({
      $or: [
        { firstName: new RegExp(query, "i") },
        { lastName: new RegExp(query, "i") },
        { email: new RegExp(query, "i") },
      ],
    }).select("firstName lastName profilePicture email");
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: "Error searching users", error });
  }
};
 