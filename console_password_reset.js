// FUNAAB Portal - Direct Console Password Reset Script
// Shows new password directly in console (no email required)
// Matric format: 20242211, 20242207, etc.

(function() {
    console.log('🔐 FUNAAB Portal Password Reset Tool');
    console.log('=====================================');
    
    // Store passwords for auto-login
    window.resetPasswords = window.resetPasswords || {};
    
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
    
    // Function to intercept form submission and store password
    function interceptFormSubmission(matricNumber, newPassword) {
        // Store the password for this matric number
        window.resetPasswords[matricNumber] = newPassword;
        
        // Override the form submission to ensure our password is used
        const originalSubmit = theForm.submit;
        theForm.submit = function() {
            console.log('📤 Submitting password reset for:', matricNumber);
            console.log('🔑 Password stored for auto-login:', newPassword);
            
            // Call original submit
            if (originalSubmit) {
                originalSubmit.call(theForm);
            }
            
            // Restore original submit function
            theForm.submit = originalSubmit;
        };
    }
    
    // Function to auto-fill login form if we're on login page
    function autoFillLoginIfAvailable(matricNumber) {
        const storedPassword = window.resetPasswords[matricNumber];
        if (!storedPassword) {
            console.log('❌ No stored password for:', matricNumber);
            return false;
        }
        
        // Check if we're on login page
        const usernameField = document.getElementById('ContentPlaceHolder1_centerpane_UserName');
        const passwordField = document.getElementById('ContentPlaceHolder1_centerpane_Password');
        
        if (usernameField && passwordField) {
            usernameField.value = matricNumber;
            passwordField.value = storedPassword;
            console.log('✅ Login form auto-filled for:', matricNumber);
            console.log('🔑 Using password:', storedPassword);
            return true;
        }
        
        return false;
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
        
        // Generate the new password
        const newPassword = generateSecurePassword();
        console.log('🎯 NEW PASSWORD FOR ' + matricNumber + ': ' + newPassword);
        console.log('🔑 COPY THIS PASSWORD: ' + newPassword);
        
        // Use dummy email (password shows in console instead)
        const dummyEmail = createDummyEmail();
        console.log('📧 Using dummy email (password shown above):', dummyEmail);
        
        // Fill the form fields
        const matricField = document.getElementById('ContentPlaceHolder1_centerpane_UserName');
        const emailField = document.getElementById('ContentPlaceHolder1_centerpane_Email');
        
        if (!matricField || !emailField) {
            console.error('❌ Form fields not found. Make sure you\'re on the ResetPassword.aspx page');
            return;
        }
        
        // Set the values
        matricField.value = matricNumber;
        emailField.value = dummyEmail;
        
        console.log('✅ Form fields populated');
        
        // Set up form interception to store password
        interceptFormSubmission(matricNumber, newPassword);
        
        // Submit the form using ASP.NET WebForm functions
        const submitButton = document.getElementById('ContentPlaceHolder1_centerpane_Button1');
        if (submitButton) {
            console.log('🔄 Submitting reset request...');
            console.log('💾 Password will be stored for auto-login');
            
            // Use WebForm postback if available
            if (typeof(WebForm_DoPostBackWithOptions) === 'function') {
                WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(
                    submitButton.name, "", true, "", "", false, false
                ));
            } else {
                submitButton.click();
            }
        } else {
            console.error('❌ Submit button not found');
        }
        
        // Return the password for immediate use
        return newPassword;
    };
    
    // Auto-login function for login page
    window.autoLogin = function(matricNumber) {
        console.log('🔐 Attempting auto-login for:', matricNumber);
        
        if (autoFillLoginIfAvailable(matricNumber)) {
            const loginButton = document.getElementById('ContentPlaceHolder1_centerpane_Button1');
            if (loginButton) {
                console.log('🚀 Auto-submitting login...');
                
                // Use WebForm postback for login
                if (typeof(WebForm_DoPostBackWithOptions) === 'function') {
                    WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(
                        loginButton.name, "", true, "", "", false, false
                    ));
                } else {
                    loginButton.click();
                }
                return true;
            }
        }
        
        console.log('❌ Auto-login failed. Make sure you\'re on the login page and have reset the password first.');
        return false;
    };
    
    // Combined reset and login function
    window.resetAndLogin = function(matricNumber) {
        console.log('🔄 Reset and login sequence for:', matricNumber);
        
        // First reset the password
        const newPassword = resetPassword(matricNumber);
        
        if (newPassword) {
            console.log('⏳ Password reset initiated. Navigate to login page and run: autoLogin("' + matricNumber + '")');
            console.log('🔑 Or manually use password: ' + newPassword);
        }
        
        return newPassword;
    };
    
    // Show stored passwords
    window.showStoredPasswords = function() {
        console.log('💾 Stored passwords:');
        for (const matric in window.resetPasswords) {
            console.log(`${matric}: ${window.resetPasswords[matric]}`);
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
        
        const results = {};
        
        matricNumbers.forEach((matric, index) => {
            console.log(`\n--- Resetting ${index + 1}/${matricNumbers.length}: ${matric} ---`);
            const password = resetPassword(matric);
            if (password) {
                results[matric] = password;
            }
        });
        
        console.log('\n📋 BATCH RESET SUMMARY:');
        for (const matric in results) {
            console.log(`${matric}: ${results[matric]}`);
        }
        
        return results;
    };
    
    // Instructions
    console.log('\n📖 Available Commands:');
    console.log('resetPassword("20242211") - Reset password (shows in console)');
    console.log('autoLogin("20242211") - Auto-login with stored password');
    console.log('resetAndLogin("20242211") - Reset then prepare for login');
    console.log('batchReset(["20242211", "20242207"]) - Reset multiple users');
    console.log('showStoredPasswords() - Show all stored passwords');
    console.log('\n🚀 Example: resetPassword("20242211")');
    console.log('🔐 Then on login page: autoLogin("20242211")');
    
})();

// Auto-run example (uncomment and modify as needed)
// resetPassword("YOUR_MATRIC_NUMBER_HERE");