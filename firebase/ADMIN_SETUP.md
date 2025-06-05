# Firebase Admin Setup Guide

This guide provides instructions for setting up and managing admin users in Firebase for the AstroApp.

## Setting Up Admin Users

### 1. Create the Admin User in Firebase Authentication

1. Go to the [Firebase Console](https://console.firebase.google.com/) and select your project.
2. Navigate to **Authentication** > **Users**.
3. Click **Add User** and enter the admin email (`astroapp.admin@astroapp.com`) and a strong password.
4. Click **Add User** to create the account.

### 2. Set Up the Admin User in Firestore

1. Navigate to **Firestore Database** in the Firebase Console.
2. Create a new collection called `admins` (not `users`).
3. Add a new document with the ID matching the UID of the admin user you created in Authentication.
4. Add the following fields to the document:
   ```
   uid: <UID of the admin user>
   email: "astroapp.admin@astroapp.com"
   role: "admin"
   displayName: "Admin User"
   createdAt: <Timestamp - current date/time>
   ```

## Collection Structure

The AstroApp uses three separate collections for different user types:

1. **admins**: Contains documents for all administrator users
   - Document ID: User's UID from Firebase Authentication
   - Required fields: uid, email, role, displayName, createdAt

2. **instructors**: Contains documents for all instructor users
   - Document ID: User's UID from Firebase Authentication
   - Required fields: uid, email, role, displayName, createdAt

3. **users**: Contains documents for regular app users
   - Document ID: User's UID from Firebase Authentication
   - Required fields: uid, email, role, displayName, createdAt

### 3. Deploy Security Rules

1. Deploy the Firestore security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. Deploy the Storage security rules:
   ```bash
   firebase deploy --only storage:rules
   ```

## Security Best Practices

### Regular Security Reviews

1. **Review Access Logs**: Regularly check Firebase Authentication logs for suspicious activities.
2. **Audit User Roles**: Periodically review user roles in all collections to ensure proper access control.
3. **Update Security Rules**: Keep security rules updated as your application evolves.

### Password Policies

1. **Strong Passwords**: Enforce strong passwords for admin accounts (minimum 12 characters with a mix of uppercase, lowercase, numbers, and special characters).
2. **Regular Password Changes**: Change admin passwords every 90 days.
3. **Multi-Factor Authentication**: Enable MFA for all admin accounts.

### Limiting Admin Access

1. **IP Restrictions**: Consider using Firebase App Check or Cloud Functions to restrict admin access to specific IP addresses.
2. **Session Management**: Implement session timeouts for admin users.
3. **Least Privilege**: Grant only necessary permissions to admin users.

## Monitoring and Alerts

1. **Set Up Alerts**: Configure Firebase alerts for suspicious activities, such as multiple failed login attempts.
2. **Activity Logging**: Log all admin actions in a separate collection for audit purposes.
3. **Regular Backups**: Ensure regular backups of Firestore data.

## Managing Instructor Accounts

Instructor accounts should be created by admin users through the admin interface:

1. Log in to the admin app using the admin credentials.
2. Navigate to the "Users" section.
3. Click "Add Instructor" and fill in the required information.
4. The system will automatically create a document in the `instructors` collection and send a verification email.

## Troubleshooting

### Common Issues

1. **Access Denied Errors**:
   - Verify the user has the correct document in the appropriate collection (`admins`, `instructors`, or `users`).
   - Check security rules for any conflicts.
   - Ensure the user is properly authenticated.

2. **Security Rules Not Working**:
   - Verify rules are properly deployed.
   - Check for syntax errors in rules.
   - Test rules using the Firebase Console Rules Playground.
  
- ### Support
  
- For additional support, contact the development team or refer to the [Firebase Documentation](https://firebase.google.com/docs).

