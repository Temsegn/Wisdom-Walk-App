require('dotenv').config();
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: "tommr2323@gmail.com",
    pass: "ihes tjso xeff afdz",
  },
});

const wrapEmail = (title, content) => `
  <div style="font-family: 'Segoe UI', sans-serif; background-color: #fdf9f4; padding: 40px 20px; border-radius: 12px; max-width: 600px; margin: auto; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
    <div style="text-align: center;">
      <h2 style="color: #A67B5B; font-size: 26px;">${title}</h2>
    </div>
    <div style="font-size: 16px; color: #555; line-height: 1.6;">
      ${content}
    </div>
    <hr style="border: none; border-top: 1px solid #e8ddd3; margin: 30px 0;" />
    <div style="font-size: 14px; color: #777; text-align: center;">
      <p>"She is clothed with strength and dignity, and she laughs without fear of the future."<br><strong>– Proverbs 31:25</strong></p>
      <p>Blessings,<br><strong>The WisdomWalk Team</strong></p>
    </div>
  </div>
`;

const sendEmail = async (to, subject, html) => {
  await transporter.sendMail({ from: process.env.GMAIL_USER, to, subject, html });
};

const sendVerificationEmail = async (email, firstName, code) => {
  const content = `
    <p>Hi ${firstName},</p>
    <p>Please verify your email by using the following code:</p>
    <div style="font-size: 32px; font-weight: bold; color: #A67B5B; letter-spacing: 8px; text-align: center;">${code}</div>
    <p>This code will expire in 24 hours.</p>
  `;
  await sendEmail(email, '🌸 Verify Your Email - WisdomWalk', wrapEmail('Email Verification', content));
};

const sendPasswordResetEmail = async (email, code, firstName) => {
  const content = `
    <p>Hello ${firstName},</p>
    <p>We received a request to reset your password. Use the code below:</p>
    <div style="font-size: 24px; font-weight: bold; color: #A67B5B; text-align: center;">${code}</div>
    <p>This code will expire in 15 minutes.</p>
  `;
  await sendEmail(email, '🔐 Reset Your Password - WisdomWalk', wrapEmail('Password Reset', content));
};

const sendAdminNotificationEmail = async (adminEmail, subject, message, user) => {
  const content = `
    <p>${message}</p>
    <h4>User Details:</h4>
    <ul>
      <li><strong>Name:</strong> ${user.firstName} ${user.lastName}</li>
      <li><strong>Email:</strong> ${user.email}</li>
      <li><strong>Date of Birth:</strong> ${user.dateOfBirth}</li>
      <li><strong>Phone:</strong> ${user.phoneNumber}</li>
      <li><strong>Location:</strong> ${user.location}</li>
    </ul>
  `;
  await sendEmail(adminEmail, subject, wrapEmail(subject, content));
};

const sendUserNotificationEmail = async (userEmail, subject, message, firstName) => {
  const content = `
    <p>Hi ${firstName},</p>
    <p>${message}</p>
  `;
  await sendEmail(userEmail, subject, wrapEmail(subject, content));
};

const sendReportEmailToAdmin = async (adminEmail, post, reportedBy) => {
  const content = `
    <p>A new report has been submitted.</p>
    <p><strong>Reported By:</strong> ${reportedBy}</p>
    <p><strong>Post ID:</strong> ${post.id}</p>
    <p><strong>Reason:</strong> ${post.reason}</p>
  `;
  await sendEmail(adminEmail, '🚨 New Post Report - WisdomWalk', wrapEmail('Reported Content Alert', content));
};

const sendNewPostEmailToAdmin = async (adminEmail, post) => {
  const content = `
    <p>A new post has been published by <strong>${post.author}</strong>.</p>
    <p><strong>Title:</strong> ${post.title}</p>
    <p><strong>Category:</strong> ${post.category}</p>
    <p><strong>Preview:</strong> ${post.content}</p>
  `;
  await sendEmail(adminEmail, '📝 New Post Submitted - WisdomWalk', wrapEmail('New Community Post', content));
};

const sendBlockedEmailToUser = async (userEmail, reason, firstName) => {
  const content = `
    <p>Hi ${firstName},</p>
    <p>Your account has been temporarily blocked for the following reason:</p>
    <blockquote>${reason}</blockquote>
    <p>Please contact support if you believe this was a mistake.</p>
  `;
  await sendEmail(userEmail, '🚫 Account Blocked - WisdomWalk', wrapEmail('Account Notice', content));
};

const sendUnblockedEmailToUser = async (userEmail, firstName) => {
  const content = `
    <p>Hi ${firstName},</p>
    <p>Your account has been unblocked and is now active.</p>
    <p>Welcome back to WisdomWalk 🌼</p>
  `;
  await sendEmail(userEmail, '✅ Account Unblocked - WisdomWalk', wrapEmail('You’re Back Online!', content));
};

const sendBannedEmailToUser = async (userEmail, reason, firstName) => {
  const content = `
    <p>Hi ${firstName},</p>
    <p>Your account has been permanently banned for the following reason:</p>
    <blockquote>${reason}</blockquote>
    <p>You may contact our admin team for further details.</p>
  `;
  await sendEmail(userEmail, '❌ Account Banned - WisdomWalk', wrapEmail('Account Termination', content));
};

const sendLikeNotificationEmail = async (userEmail, likerName, postTitle) => {
  const content = `
    <p>Your post titled <strong>"${postTitle}"</strong> received a new like from <strong>${likerName}</strong>! 💖</p>
    <p>Keep sharing your wisdom!</p>
  `;
  await sendEmail(userEmail, '👍 New Like on Your Post - WisdomWalk', wrapEmail('Post Appreciation', content));
};

const sendCommentNotificationEmail = async (userEmail, commenterName, comment, postTitle) => {
  const content = `
    <p><strong>${commenterName}</strong> commented on your post <strong>"${postTitle}"</strong>:</p>
    <blockquote>${comment}</blockquote>
    <p>Join the conversation and connect with the community!</p>
  `;
  await sendEmail(userEmail, '💬 New Comment on Your Post - WisdomWalk', wrapEmail('New Comment Received', content));
};

module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendAdminNotificationEmail,
  sendUserNotificationEmail,
  sendReportEmailToAdmin,
  sendNewPostEmailToAdmin,
  sendBlockedEmailToUser,
  sendUnblockedEmailToUser,
  sendBannedEmailToUser,
  sendLikeNotificationEmail,
  sendCommentNotificationEmail,
};
