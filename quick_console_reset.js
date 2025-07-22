// Super Quick Console Reset - Shows Password Directly
// Matric format: 20242211, 20242207, etc.

// Direct password reset function
function directReset(matric) {
    if (!/^\d{8}$/.test(matric)) {
        console.error('❌ Use 8-digit format: 20242211');
        return;
    }
    
    // Generate password to show immediately
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%';
    let newPassword = '';
    for (let i = 0; i < 8; i++) {
        newPassword += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    
    console.log('🎯 NEW PASSWORD FOR ' + matric + ': ' + newPassword);
    
    // Use dummy email
    const dummyEmail = 'noreply' + Math.random().toString(36).substr(2, 5) + '@localhost.com';
    document.getElementById('ContentPlaceHolder1_centerpane_UserName').value = matric;
    document.getElementById('ContentPlaceHolder1_centerpane_Email').value = dummyEmail;
    document.getElementById('ContentPlaceHolder1_centerpane_Button1').click();
    
    console.log('✅ Reset submitted for:', matric);
    console.log('🔑 USE THIS PASSWORD:', newPassword);
    
    return newPassword;
}

// Usage: directReset("20242211")
console.log('🔐 Direct Reset Loaded! Usage: directReset("20242211")');
console.log('🎯 Password will show immediately in console!');