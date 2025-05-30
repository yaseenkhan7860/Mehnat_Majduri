const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * Creates an instructor account with admin privileges
 * Only callable by admin users
 */
exports.createInstructorAccount = functions.https.onCall(async (data, context) => {
  // Check if the caller is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'You must be signed in to create an instructor account'
    );
  }

  try {
    // Get the caller's user record to check if they're an admin
    const callerUid = context.auth.uid;
    const callerUserRecord = await admin.auth().getUser(callerUid);
    const callerCustomClaims = callerUserRecord.customClaims || {};

    // Verify the caller is an admin
    if (!callerCustomClaims.role || callerCustomClaims.role !== 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Only administrators can create instructor accounts'
      );
    }

    // Validate required fields
    const { email, password, displayName } = data;
    if (!email || !password || !displayName) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Email, password, and display name are required'
      );
    }

    // Validate password strength
    if (!isStrongPassword(password)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character'
      );
    }

    // Create the user account
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: displayName,
      emailVerified: false, // Instructors will need to verify their email
    });

    // Set custom claims for the user (role = instructor)
    await admin.auth().setCustomUserClaims(userRecord.uid, { role: 'instructor' });

    // Store additional user data in Firestore
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email: email,
      displayName: displayName,
      role: 'instructor',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: callerUid,
    });

    // Log the action for audit purposes
    await logAdminAction(callerUid, 'create_instructor', {
      targetUid: userRecord.uid,
      email: email,
      displayName: displayName,
    });

    return {
      success: true,
      uid: userRecord.uid,
    };
  } catch (error) {
    console.error('Error creating instructor account:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Sets a user's role
 * Only callable by admin users
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
  // Check if the caller is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'You must be signed in to set user roles'
    );
  }

  try {
    // Get the caller's user record to check if they're an admin
    const callerUid = context.auth.uid;
    const callerUserRecord = await admin.auth().getUser(callerUid);
    const callerCustomClaims = callerUserRecord.customClaims || {};

    // Verify the caller is an admin
    if (!callerCustomClaims.role || callerCustomClaims.role !== 'admin') {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Only administrators can set user roles'
      );
    }

    // Validate required fields
    const { uid, role } = data;
    if (!uid || !role) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'User ID and role are required'
      );
    }

    // Validate role is one of the allowed values
    const validRoles = ['user', 'instructor', 'admin'];
    if (!validRoles.includes(role)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Role must be one of: user, instructor, admin'
      );
    }

    // Get the target user
    const userRecord = await admin.auth().getUser(uid);

    // Set custom claims for the user
    await admin.auth().setCustomUserClaims(uid, { role: role });

    // Update user data in Firestore
    await admin.firestore().collection('users').doc(uid).update({
      role: role,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: callerUid,
    });

    // Log the action for audit purposes
    await logAdminAction(callerUid, 'set_user_role', {
      targetUid: uid,
      email: userRecord.email,
      oldRole: userRecord.customClaims?.role || 'none',
      newRole: role,
    });

    return {
      success: true,
    };
  } catch (error) {
    console.error('Error setting user role:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Verifies a user's role
 * This can be called by any authenticated user to verify their own role
 */
exports.verifyUserRole = functions.https.onCall(async (data, context) => {
  // Check if the caller is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'You must be signed in to verify your role'
    );
  }

  try {
    const uid = context.auth.uid;
    const userRecord = await admin.auth().getUser(uid);
    const customClaims = userRecord.customClaims || {};
    const role = customClaims.role || 'user'; // Default to 'user' if no role is set

    // Get additional user data from Firestore
    const userDoc = await admin.firestore().collection('users').doc(uid).get();
    const userData = userDoc.exists ? userDoc.data() : {};

    return {
      uid: uid,
      email: userRecord.email,
      displayName: userRecord.displayName,
      role: role,
      emailVerified: userRecord.emailVerified,
      ...userData,
    };
  } catch (error) {
    console.error('Error verifying user role:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Helper function to log admin actions for auditing
 */
async function logAdminAction(adminUid, actionType, details) {
  await admin.firestore().collection('admin_logs').add({
    adminUid: adminUid,
    actionType: actionType,
    details: details,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    ipAddress: '', // In a real app, you would get this from the request
  });
}

/**
 * Helper function to validate password strength
 */
function isStrongPassword(password) {
  // Password must be at least 8 characters long
  if (password.length < 8) {
    return false;
  }

  // Check for at least one uppercase letter
  if (!/[A-Z]/.test(password)) {
    return false;
  }

  // Check for at least one lowercase letter
  if (!/[a-z]/.test(password)) {
    return false;
  }

  // Check for at least one number
  if (!/[0-9]/.test(password)) {
    return false;
  }

  // Check for at least one special character
  if (!/[^A-Za-z0-9]/.test(password)) {
    return false;
  }

  return true;
} 