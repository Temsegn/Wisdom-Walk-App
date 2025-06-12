const User = require("../models/User")
const { generateToken, generateJWT, formatUserResponse } = require("../utils/helpers")
const { sendVerificationEmail, sendPasswordResetEmail, sendAdminNotificationEmail } = require("../utils/emailService")
const { saveVerificationDocument } = require("../utils/storageHelper")

// Register new user
const register = async (req, res) => {
  try {
    const { email, password, firstName, lastName, dateOfBirth, phoneNumber, location,bio } = req.body

    // Check if user already exists
    const existingUser = await User.findOne({ email })
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this email already exists',
      })
    }
 
    // Check if verification documents are uploaded
    if (!req.files?.livePhoto || !req.files?.nationalId) {
      return res.status(400).json({
        success: false,
        message: 'Live photo and national ID are required for registration',
      })
    }

    const sanitizedEmail = email.replace(/[^a-zA-Z0-9]/g, '_')

    // Upload documents (using buffer from memory storage)
    const livePhotoResult = await saveVerificationDocument(
      req.files.livePhoto[0].buffer,
      sanitizedEmail,
      'live_photo',
      req.files.livePhoto[0].originalname,
    )

    const nationalIdResult = await saveVerificationDocument(
      req.files.nationalId[0].buffer,
      sanitizedEmail,
      'national_id',
      req.files.nationalId[0].originalname,
    )

    // Generate email verification
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString()
    const emailVerificationExpires = new Date(Date.now() + 5 * 60 * 1000)

    // Create user
    const user = new User({
      email,
      password,
      firstName,
      lastName,
      dateOfBirth,
      phoneNumber,
      location,
      livePhoto: livePhotoResult.url,
      nationalId: nationalIdResult.url,
      verificationCode,
      emailVerificationExpires,
      bio
    })

    await user.save()

    // Send email to user
    await sendVerificationEmail(email, firstName, verificationCode)

    // Notify admin
    await sendAdminNotificationEmail(
      'tommr2323@gmail.com',
      'New User Registration Pending Verification',
      'A new user has registered and is pending admin verification.',
      user
    )

    res.status(201).json({
      success: true,
      message: 'Registration successful! Please check your email to verify your account.',
      data: {
        userId: user._id,
        email: user.email,
        emailVerificationSent: true,
        adminVerificationPending: true,
        verificationCode,
      },
    })
  } catch (error) {
    console.error('Registration error:', error)
    res.status(500).json({
      success: false,
      message: 'Registration failed',
      error: error.message,
    })
  }
}

module.exports = { register }


// Verify email
const verifyEmail = async (req, res) => {
  try {
    const { email, code } = req.body

    if (!email || !code) {
      return res.status(400).json({
        success: false,
        message: "Email and code are required",
      })
    }

    const user = await User.findOne({
      email,
      verificationCode: code,
      emailVerificationExpires: { $gt: Date.now() },
    })

    if (!user) {
      return res.status(400).json({
        success: false,
        message: "Invalid or expired verification code",
      })
    }

    user.isEmailVerified = true
    user.verificationCode = undefined
    user.emailVerificationExpires = undefined

    await user.save()

    res.json({
      success: true,
      message: "Email verified successfully! Your account is now pending admin verification.",
      data: {
        emailVerified: true,
        adminVerificationPending: !user.isAdminVerified,
      },
    })
  } catch (error) {
    console.error("Email verification error:", error)
    res.status(500).json({
      success: false,
      message: "Email verification failed",
      error: error.message,
    })
  }
}


// Login user
const login = async (req, res) => {
  try {
    const { email, password } = req.body

    // Find user and include password for comparison
    const user = await User.findOne({ email }).select("+password")

    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      })
    }

    // Check if user can access the app
    if (!user.canAccess()) {
      const statusMessages = {
        emailNotVerified: "Please verify your email address before logging in.",
        adminNotVerified: "Your account is pending admin verification. You will be notified once approved.",
        blocked: `Your account is temporarily blocked until ${user.blockedUntil?.toLocaleDateString()}.`,
        banned: "Your account has been permanently banned. Please contact support for more information.",
      }

      let message = "Account access restricted."
      if (!user.isEmailVerified) message = statusMessages.emailNotVerified
      else if (!user.isAdminVerified) message = statusMessages.adminNotVerified
      else if (user.status === "blocked") message = statusMessages.blocked
      else if (user.status === "banned") message = statusMessages.banned

      return res.status(403).json({
        success: false,
        message,
        details: {
          emailVerified: user.isEmailVerified,
          adminVerified: user.isAdminVerified,
          status: user.status,
          blockedUntil: user.blockedUntil,
        },
      })
    }

    // Update last active
    user.lastActive = new Date()
    await user.save()

    // Generate JWT token
    const token = generateJWT(user._id)

   

    res.cookie('token', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'Strict',
  maxAge: 24 * 60 * 60 * 1000, // 1 day
  
});
 res.json({
      success: true,
      message: "Login successful",
      data: {
        token,
        user: formatUserResponse(user),
      },
    })
  } catch (error) {
    console.error("Login error:", error)
    res.status(500).json({
      success: false,
      message: "Login failed",
      error: error.message,
    })
  }
}

// Request password reset
// Request password reset using verificationCode field
const requestPasswordReset = async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.json({
        success: true,
        message: "If an account with that email exists, a password reset code has been sent.",
      });
    }

    if (!user.isEmailVerified) {
      return res.status(403).json({
        success: false,
        message: "Email is not verified. Please verify your email before resetting your password.",
      });
    }

    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expires = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    // Store in shared fields
    await User.updateOne(
      { email },
      {
        $set: {
          verificationCode: resetCode,
          emailVerificationExpires: expires,
        },
      }
    );

    await sendPasswordResetEmail(email, resetCode, user.firstName);

    return res.json({
      success: true,
      message: "If an account with that email exists, a password reset code has been sent.",
    });
  } catch (error) {
    console.error("Password reset request error:", error);
    return res.status(500).json({
      success: false,
      message: "Password reset request failed",
      error: error.message,
    });
  }
};

const resetPassword = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    const user = await User.findOne({
      email,
      verificationCode: code,
      emailVerificationExpires: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: "Invalid or expired reset code",
      });
    }

    user.password = newPassword;
    user.verificationCode = undefined;
    user.emailVerificationExpires = undefined;

    await user.save();

    return res.json({
      success: true,
      message: "Password reset successful. You can now login with your new password.",
    });
  } catch (error) {
    console.error("Password reset error:", error);
    return res.status(500).json({
      success: false,
      message: "Password reset failed",
      error: error.message,
    });
  }
};



// Resend verification email using updateOne
const resendVerificationEmail = async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (user.isEmailVerified) {
      return res.status(400).json({
        success: false,
        message: "Email is already verified",
      });
    }

    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const emailVerificationExpires = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    await User.updateOne(
      { email },
      {
        verificationCode,
        emailVerificationExpires,
      }
    );

    await sendVerificationEmail(email, user.firstName, verificationCode);

    res.json({
      success: true,
      message: "Verification code resent successfully",
    });
  } catch (error) {
    console.error("Resend verification error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to resend verification code",
      error: error.message,
    });
  }
};
const logout = async (req, res) => {
  try {
    await res.clearCookie('token', {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'Strict',
    });

    res.json({
      success: true,
      message: "Logged out successfully",
    });
  } catch (error) {
    console.error("Logout error:", error);
    res.status(500).json({
      success: false,
      message: "Logout failed",
      error: error.message,
    });
  }
};




module.exports = {
  register,
  verifyEmail,
  login,
  requestPasswordReset,
  resetPassword,
  resendVerificationEmail,
  logout
}
