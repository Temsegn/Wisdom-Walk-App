const jwt = require("jsonwebtoken")
const User = require("../models/User")

 
// Middleware to verify JWT stored in cookie
const authenticateToken = async (req, res, next) => {
  try {
    // Try cookie first
    let token = req.cookies?.token;

    // If no token in cookie, check Authorization header
    if (!token && req.headers.authorization?.startsWith("Bearer ")) {
      token = req.headers.authorization.split(" ")[1];
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Access denied. No token provided.",
      });
    }

    // Verify token
    const decoded = jwt.verify(token, "wisdom"); // ideally use process.env.JWT_SECRET
    const user = await User.findById(decoded.userId).select("-password");

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid token - user not found",
      });
    }

    if (!user.canAccess()) {
      return res.status(403).json({
        success: false,
        message: "Account access restricted. Please contact support.",
        details: {
          emailVerified: user.isEmailVerified,
          adminVerified: user.isAdminVerified,
          status: user.status,
          blockedUntil: user.blockedUntil,
        },
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({ success: false, message: "Invalid token" });
    }
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({ success: false, message: "Token expired" });
    }

    console.error("Auth middleware error:", error);
    res.status(500).json({ success: false, message: "Authentication failed" });
  }
};



// Check if user is admin
const requireAdmin = async (req, res, next) => {
  try {
    if (!req.user.isGlobalAdmin) {
      return res.status(403).json({
        success: false,
        message: "Admin access required",
      })
    }
    next()
  } catch (error) {
    console.error("Admin middleware error:", error)
    res.status(500).json({
      success: false,
      message: "Authorization error",
    })
  }
}

// Check specific admin permission
const requirePermission = (permission) => {
  return async (req, res, next) => {
    try {
      if (!req.user.isGlobalAdmin && !req.user.adminPermissions.includes(permission)) {
        return res.status(403).json({
          success: false,
          message: `Permission required: ${permission}`,
        })
      }
      next()
    } catch (error) {
      console.error("Permission middleware error:", error)
      res.status(500).json({
        success: false,
        message: "Authorization error",
      })
    }
  }
}

// Check if user is group admin
const requireGroupAdmin = (groupType) => {
  return async (req, res, next) => {
    try {
      const isGroupAdmin = req.user.isGroupAdmin(groupType)
      const isGlobalAdmin = req.user.isGlobalAdmin

      if (!isGroupAdmin && !isGlobalAdmin) {
        return res.status(403).json({
          success: false,
          message: `Admin access required for ${groupType} group`,
        })
      }
      next()
    } catch (error) {
      console.error("Group admin middleware error:", error)
      res.status(500).json({
        success: false,
        message: "Authorization error",
      })
    }
  }
}

// Optional authentication (for public endpoints that can benefit from user context)
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization
    const token = authHeader && authHeader.split(" ")[1]

    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET)
      const user = await User.findById(decoded.userId).select("-password")

      if (user && user.canAccess()) {
        req.user = user
      }
    }

    next()
  } catch (error) {
    // Silently fail for optional auth
    next()
  }
}

module.exports = {
  authenticateToken,
  requireAdmin,
  requirePermission,
  requireGroupAdmin,
  optionalAuth,
}
