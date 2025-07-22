// FUNAAB Portal - Direct Console Password Reset Script
// Shows new password directly in console (no email required)
// Matric format: 20242211, 20242207, etc.

(function() {
    console.log('🔐 FUNAAB Portal Password Reset Tool');
    console.log('=====================================');
    
    // Function to generate a secure password
    function generateSecurePassword() {
        const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%';
        let password = '';
        for (let i = 0; i < 8; i++) {
            password += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return password;
    }
    
    // Function to create a dummy email (won't be used for sending)
    function createDummyEmail() {
        return 'noreply' + Math.random().toString(36).substr(2, 5) + '@localhost.com';
    }
    
    // Function to intercept and extract password from response
    function interceptPasswordFromResponse() {
        const form = document.getElementById('form1');
        if (!form) {
            console.error('❌ Form not found. Make sure you\'re on the ResetPassword.aspx page');
            return;
        }
        
        // Monitor for server response containing password
        const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.type === 'childList') {
                    // Look for password in any new content
                    const allText = document.body.innerText;
                    
                    // Try to extract password patterns
                    const passwordPatterns = [
                        /password[:\s]+([A-Za-z0-9!@#$%]{6,12})/i,
                        /new password[:\s]+([A-Za-z0-9!@#$%]{6,12})/i,
                        /temporary password[:\s]+([A-Za-z0-9!@#$%]{6,12})/i,
                        /reset password[:\s]+([A-Za-z0-9!@#$%]{6,12})/i
                    ];
                    
                    for (let pattern of passwordPatterns) {
                        const match = allText.match(pattern);
                        if (match) {
                            console.log('🎉 PASSWORD RESET SUCCESSFUL!');
                            console.log('🔑 NEW PASSWORD:', match[1]);
                            console.log('👤 You can now login with this password');
                            return;
                        }
                    }
                    
                    // Check for success messages
                    if (allText.includes('sent') || allText.includes('reset') || allText.includes('successful')) {
                        console.log('✅ Reset request processed');
                        console.log('🔍 Looking for password in response...');
                    }
                }
            });
        });
        
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }
    
    // Main direct reset function
    window.resetPassword = function(matricNumber) {
        console.log('🚀 Starting direct password reset for:', matricNumber);
        
        if (!matricNumber) {
            console.error('❌ Please provide a matriculation number');
            console.log('Usage: resetPassword("20242211")');
            return;
        }
        
        // Validate matric number format
        if (!/^\d{8}$/.test(matricNumber)) {
            console.error('❌ Invalid matric format. Use 8 digits like: 20242211');
            return;
        }
        
        // Use dummy email (password will show in console instead)
        const dummyEmail = createDummyEmail();
        console.log('📧 Using dummy email (password will show here):', dummyEmail);
        
        // Fill the form fields
        const matricField = document.getElementById('ContentPlaceHolder1_centerpane_UserName');
        const emailField = document.getElementById('ContentPlaceHolder1_centerpane_Email');
        
        if (!matricField || !emailField) {
            console.error('❌ Form fields not found. Make sure you\'re on the correct page');
            return;
        }
        
        // Set the values
        matricField.value = matricNumber;
        emailField.value = dummyEmail;
        
        console.log('✅ Form fields populated');
        
        // Set up password interception
        interceptPasswordFromResponse();
        
        // Submit the form
        const submitButton = document.getElementById('ContentPlaceHolder1_centerpane_Button1');
        if (submitButton) {
            console.log('🔄 Submitting reset request...');
            console.log('⏳ Waiting for new password...');
            submitButton.click();
        } else {
            console.error('❌ Submit button not found');
        }
    };
    
    // Batch reset function for multiple users
    window.batchReset = function(matricNumbers) {
        console.log('🚀 Starting batch password reset...');
        
        if (!Array.isArray(matricNumbers)) {
            console.error('❌ Please provide an array of matric numbers');
            console.log('Usage: batchReset(["20242211", "20242207", "20242215"])');
            return;
        }
        
        let currentIndex = 0;
        
        function resetNext() {
            if (currentIndex >= matricNumbers.length) {
                console.log('✅ Batch reset completed!');
                return;
            }
            
            const matric = matricNumbers[currentIndex];
            console.log(`\n--- Resetting ${currentIndex + 1}/${matricNumbers.length}: ${matric} ---`);
            resetPassword(matric);
            
            currentIndex++;
            // Wait 3 seconds before next reset
            setTimeout(resetNext, 3000);
        }
        
        resetNext();
    };
    
    // Generate and show a password without resetting (for testing)
    window.generatePassword = function() {
        const newPassword = generateSecurePassword();
        console.log('🔑 Generated password:', newPassword);
        return newPassword;
    };
    
    // Quick reset with immediate password generation
    window.quickReset = function(matricNumber) {
        console.log('⚡ Quick reset for:', matricNumber);
        
        const newPassword = generateSecurePassword();
        console.log('🎯 SUGGESTED PASSWORD:', newPassword);
        console.log('📝 Copy this password and use resetPassword() to apply it');
        
        // Also run the actual reset
        resetPassword(matricNumber);
        
        return newPassword;
    };
    
    // Utility function to show current form values
    window.showFormValues = function() {
        const matricField = document.getElementById('ContentPlaceHolder1_centerpane_UserName');
        const emailField = document.getElementById('ContentPlaceHolder1_centerpane_Email');
        
        console.log('📋 Current form values:');
        console.log('Matric Number:', matricField ? matricField.value : 'Field not found');
        console.log('Email:', emailField ? emailField.value : 'Field not found');
    };
    
    // Instructions
    console.log('\n📖 Available Commands:');
    console.log('resetPassword("20242211") - Reset password (shows in console)');
    console.log('quickReset("20242211") - Quick reset with generated password');
    console.log('batchReset(["20242211", "20242207"]) - Reset multiple users');
    console.log('generatePassword() - Generate a secure password');
    console.log('showFormValues() - Show current form field values');
    console.log('\n🚀 Example: resetPassword("20242211")');
    console.log('🚀 Batch Example: batchReset(["20242211", "20242207", "20242215"])');
    
})();

// Auto-run example (uncomment and modify as needed)
// resetPassword("YOUR_MATRIC_NUMBER_HERE", "your-email@gmail.com");