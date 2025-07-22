// Quick Console Reset - Minimal Version
// Copy and paste this into browser console on ResetPassword.aspx page

// Simple one-liner function
function quickReset(matric, email) {
    email = email || 'temp' + Math.random().toString(36).substr(2, 9) + '@gmail.com';
    document.getElementById('ContentPlaceHolder1_centerpane_UserName').value = matric;
    document.getElementById('ContentPlaceHolder1_centerpane_Email').value = email;
    document.getElementById('ContentPlaceHolder1_centerpane_Button1').click();
    console.log('✅ Reset submitted for:', matric, 'to email:', email);
    console.log('📧 Check the email for your new password');
}

// Usage: quickReset("FUNAAB/2020/12345", "your@gmail.com")
console.log('🔐 Quick Reset Loaded! Usage: quickReset("YOUR_MATRIC_NUMBER", "your@email.com")');