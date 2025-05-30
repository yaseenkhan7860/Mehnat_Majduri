const functions = require('firebase-functions');
const admin = require('firebase-admin');
const userManagement = require('./src/userManagement');

// Initialize Firebase Admin with application default credentials
admin.initializeApp();

// Export all user management functions
exports.createInstructorAccount = userManagement.createInstructorAccount;
exports.setUserRole = userManagement.setUserRole;
exports.verifyUserRole = userManagement.verifyUserRole; 