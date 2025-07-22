# Email Configuration Guide for Password Reset

## SMTP Configuration Options

### 1. Gmail SMTP (Recommended for testing)
```xml
<!-- In web.config -->
<system.net>
  <mailSettings>
    <smtp from="your-portal@gmail.com">
      <network host="smtp.gmail.com" 
               port="587" 
               enableSsl="true" 
               userName="your-portal@gmail.com" 
               password="your-app-password" />
    </smtp>
  </mailSettings>
</system.net>
```

**Setup Steps:**
1. Create a Gmail account for the portal (e.g., funaabportal@gmail.com)
2. Enable 2-factor authentication
3. Generate an "App Password" for the portal
4. Use the app password in the configuration

### 2. Outlook/Hotmail SMTP
```xml
<system.net>
  <mailSettings>
    <smtp from="your-portal@outlook.com">
      <network host="smtp-mail.outlook.com" 
               port="587" 
               enableSsl="true" 
               userName="your-portal@outlook.com" 
               password="your-password" />
    </smtp>
  </mailSettings>
</system.net>
```

### 3. Local SMTP Server (if available)
```xml
<system.net>
  <mailSettings>
    <smtp from="noreply@funaab.edu.ng">
      <network host="mail.funaab.edu.ng" 
               port="25" 
               enableSsl="false" />
    </smtp>
  </mailSettings>
</system.net>
```

## Implementation Steps

### 1. Deploy the Backend File
1. Save `flexible_reset_backend.aspx` to your web server
2. Update the connection string in the file
3. Configure SMTP settings

### 2. Update the Frontend
1. The modified `ResetPassword.html` now shows "Any valid email"
2. Users can enter any email address
3. Clear instructions are provided

### 3. Test the System
1. Try resetting a password with a test matriculation number
2. Use your personal email to receive the new password
3. Verify the password works for login

## Security Considerations

### ✅ Security Features Added:
- Secure password generation
- Multiple hashing method support
- Comprehensive logging
- Input validation
- Error handling without information disclosure

### ⚠️ Important Notes:
- Change the SMTP credentials regularly
- Monitor the password reset logs
- Consider rate limiting (max 3 resets per hour per matric number)
- Delete old log files periodically

## Troubleshooting

### Common Issues:
1. **Email not sending**: Check SMTP configuration and credentials
2. **Password not updating**: Verify database connection and table structure
3. **User not found**: Check matriculation number format and database

### Debug Mode:
Add this to web.config for detailed error messages (remove in production):
```xml
<system.web>
  <customErrors mode="Off" />
</system.web>
```