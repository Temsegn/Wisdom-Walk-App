require('dotenv').config()  // Load env vars from .env file

const nodemailer = require('nodemailer')

// Create transporter with Mailtrap SMTP config
const Transport = nodemailer.createTransport({
  host: "sandbox.smtp.mailtrap.io",
  port: 2525,
  auth: {
    user: "6207eb4fcc2f09",
    pass: "45de75a4071a88"
  }
});
const sendVerificationEmail = async (email, firstName,verificationCode) => {
  try {
    // Generate a 6-digit numeric code
 
    const transporter = Transport

    const mailOptions = {
      from: process.env.EMAIL_USER || 'no-reply@wisdomwalk.com',
      to: email,
      subject: 'Welcome to WisdomWalk - Verify Your Email',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #D4A017;">Welcome to WisdomWalk, ${firstName}!</h2>
          <p>Thank you for joining our community of Christian women. Please verify your email address by entering the following verification code:</p>
          
          <div style="text-align: center; margin: 30px 0; font-size: 32px; letter-spacing: 8px; font-weight: bold; color: #D4A017;">
            ${verificationCode}
          </div>
          
          <p>If you did not sign up for WisdomWalk, please ignore this email.</p>
          
          <p style="margin-top: 30px; color: #666; font-size: 14px;">
            This code will expire in 24 hours.
          </p>
          
          <div style="border-top: 1px solid #eee; margin-top: 30px; padding-top: 20px; color: #666; font-size: 12px;">
            <p>Blessings,<br>The WisdomWalk Team</p>
            <p>"She is clothed with strength and dignity" - Proverbs 31:25</p>
          </div>
        </div>
      `,
    }

    await transporter.sendMail(mailOptions)
    console.log('Verification email with code sent to:', email)
  } catch (error) {
    console.error('Error sending verification email:', error)
    throw error
  }
}


// You can apply the same pattern to other email functions:
const sendAdminNotificationEmail = async (adminEmail, subject, message, user) => {
  try {
    const transporter = Transport;

    const mailOptions = {
      from: process.env.EMAIL_USER || 'no-reply@wisdomwalk.com',
      to: "tommr2323@gmail.com",
      subject,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #D4A017;">${subject}</h2>
          <p>${message}</p>

          <h4>User Details:</h4>
          <ul>
            <li><strong>Name:</strong> ${user.firstName} ${user.lastName}</li>
            <li><strong>Email:</strong> ${user.email}</li>
            <li><strong>Date of Birth:</strong> ${user.dateOfBirth}</li>
            <li><strong>Phone:</strong> ${user.phoneNumber}</li>
            <li><strong>Location:</strong> ${user.location}</li>
          </ul>

          <p>Please log in to the admin panel to verify the user's identity and documents.</p>

          <div style="border-top: 1px solid #eee; margin-top: 30px; padding-top: 20px; color: #666; font-size: 12px;">
            <p>WisdomWalk Admin Team</p>
          </div>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log('Admin notification sent to:', adminEmail);
  } catch (error) {
    console.error('Error sending admin notification email:', error);
    throw error;
  }
};
const sendPasswordResetEmail = async (email, code, firstName) => {
  try {
    const transporter = Transport;

    const mailOptions = {
      from: process.env.EMAIL_USER || 'no-reply@wisdomwalk.com',
      to: email,
      subject: 'WisdomWalk - Password Reset Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #D4A017;">Password Reset Request</h2>
          <p>Hello ${firstName},</p>
          <p>We received a request to reset your WisdomWalk account password.</p>
          <p>Please use the following code to reset your password:</p>
          <div style="font-size: 24px; font-weight: bold; margin: 20px 0;">${code}</div>
          <p>This code will expire in 15 minutes.</p>
          <p>If you didn’t request this, please ignore this email.</p>

          <div style="border-top: 1px solid #eee; margin-top: 30px; padding-top: 20px; color: #666; font-size: 12px;">
            <p>Blessings,<br>The WisdomWalk Team</p>
          </div>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log('Password reset email sent to:', email);
  } catch (error) {
    console.error('Error sending password reset email:', error);
    throw error;
  }
};
const sendUserNotificationEmail = async (userEmail, subject, message, firstName) => {
  try {
    const transporter = Transport;

    const mailOptions = {
      from: process.env.EMAIL_USER || 'no-reply@wisdomwalk.com',
      to: userEmail,
      subject,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #D4A017;">${subject}</h2>

          <p>Hi ${firstName},</p>

          <p>${message}</p>

          <p>We're excited to have you with us. Explore, connect, and grow with the WisdomWalk community of Christian women.</p>

          <p>If you have any questions, feel free to reply to this email or contact our support team.</p>

          <div style="border-top: 1px solid #eee; margin-top: 30px; padding-top: 20px; color: #666; font-size: 12px;">
            <p>Blessings,<br/>The WisdomWalk Team</p>
          </div>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log('Verification email sent to:', userEmail);
  } catch (error) {
    console.error('Error sending verification email:', error);
    throw error;
  }
};



// Export functions
module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendAdminNotificationEmail
  ,sendUserNotificationEmail
  // ...add others here as needed
}
