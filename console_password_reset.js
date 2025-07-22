// FUNAAB Portal - Console Password Reset Script
// Run this in the browser console on the ResetPassword.aspx page

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
    
    // Function to create a temporary email input
    function createTempEmail() {
        return 'temp' + Math.random().toString(36).substr(2, 9) + '@gmail.com';
    }
    
    // Function to intercept form submission and capture response
    function interceptFormSubmission() {
        const form = document.getElementById('form1');
        if (!form) {
            console.error('❌ Form not found. Make sure you\'re on the ResetPassword.aspx page');
            return;
        }
        
        // Override form submission
        const originalSubmit = form.onsubmit;
        form.onsubmit = function(e) {
            console.log('🔄 Intercepting form submission...');
            
            // Let the original submission proceed but capture the response
            if (originalSubmit) {
                return originalSubmit.call(this, e);
            }
            return true;
        };
        
        // Monitor for page changes/responses
        const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
                if (mutation.type === 'childList') {
                    // Check for success/error messages
                    const messages = document.querySelectorAll('.validation-summary-errors, .success-message, .error-message');
                    messages.forEach(function(msg) {
                        if (msg.textContent.includes('sent') || msg.textContent.includes('reset')) {
                            console.log('✅ Password reset successful!');
                            console.log('📧 Check the email address you provided for the new password');
                        }
                    });
                }
            });
        });
        
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }
    
    // Main reset function
    window.resetPassword = function(matricNumber, customEmail) {
        console.log('🚀 Starting password reset for:', matricNumber);
        
        if (!matricNumber) {
            console.error('❌ Please provide a matriculation number');
            console.log('Usage: resetPassword("FUNAAB/2020/12345", "your-email@gmail.com")');
            return;
        }
        
        // Use custom email or generate a temporary one
        const emailToUse = customEmail || createTempEmail();
        console.log('📧 Using email:', emailToUse);
        
        // Fill the form fields
        const matricField = document.getElementById('ContentPlaceHolder1_centerpane_UserName');
        const emailField = document.getElementById('ContentPlaceHolder1_centerpane_Email');
        
        if (!matricField || !emailField) {
            console.error('❌ Form fields not found. Make sure you\'re on the correct page');
            return;
        }
        
        // Set the values
        matricField.value = matricNumber;
        emailField.value = emailToUse;
        
        console.log('✅ Form fields populated');
        
        // Set up interception
        interceptFormSubmission();
        
        // Submit the form
        const submitButton = document.getElementById('ContentPlaceHolder1_centerpane_Button1');
        if (submitButton) {
            console.log('🔄 Submitting reset request...');
            submitButton.click();
        } else {
            console.error('❌ Submit button not found');
        }
    };
    
    // Enhanced version that tries to extract password from response
    window.resetPasswordAdvanced = function(matricNumber, customEmail) {
        console.log('🚀 Advanced password reset for:', matricNumber);
        
        if (!matricNumber) {
            console.error('❌ Please provide a matriculation number');
            return;
        }
        
        const emailToUse = customEmail || 'console.reset@gmail.com';
        
        // Create a promise to handle the async nature
        return new Promise((resolve, reject) => {
            // Fill form
            const matricField = document.getElementById('ContentPlaceHolder1_centerpane_UserName');
            const emailField = document.getElementById('ContentPlaceHolder1_centerpane_Email');
            
            if (!matricField || !emailField) {
                reject('Form fields not found');
                return;
            }
            
            matricField.value = matricNumber;
            emailField.value = emailToUse;
            
            // Monitor for response
            const originalFetch = window.fetch;
            window.fetch = function(...args) {
                console.log('🌐 Intercepting network request:', args[0]);
                return originalFetch.apply(this, args).then(response => {
                    if (response.url.includes('ResetPassword')) {
                        console.log('📨 Password reset response received');
                        response.clone().text().then(text => {
                            // Try to extract password from response
                            const passwordMatch = text.match(/password[:\s]+([A-Za-z0-9!@#$%]{6,12})/i);
                            if (passwordMatch) {
                                console.log('🔑 New password found:', passwordMatch[1]);
                                resolve(passwordMatch[1]);
                            }
                        });
                    }
                    return response;
                });
            };
            
            // Submit form
            const submitButton = document.getElementById('ContentPlaceHolder1_centerpane_Button1');
            if (submitButton) {
                submitButton.click();
                
                // Fallback timeout
                setTimeout(() => {
                    console.log('⏰ Reset request completed. Check email:', emailToUse);
                    resolve('Check email for password');
                }, 3000);
            } else {
                reject('Submit button not found');
            }
        });
    };
    
    // Direct database approach (if you have access to make AJAX calls)
    window.directPasswordReset = function(matricNumber) {
        console.log('🎯 Attempting direct password reset for:', matricNumber);
        
        const newPassword = generateSecurePassword();
        console.log('🔑 Generated password:', newPassword);
        
        // This would require a custom endpoint that you'd need to create
        const resetData = {
            matricNumber: matricNumber,
            newPassword: newPassword,
            action: 'directReset'
        };
        
        // Try to make direct call (this would need a custom backend endpoint)
        fetch('/api/DirectPasswordReset', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(resetData)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                console.log('✅ Password reset successful!');
                console.log('🔑 New password:', newPassword);
                console.log('👤 Matric Number:', matricNumber);
            } else {
                console.error('❌ Reset failed:', data.message);
            }
        })
        .catch(error => {
            console.error('❌ Network error:', error);
            console.log('💡 Try the regular reset method instead');
        });
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
    console.log('resetPassword("FUNAAB/2020/12345") - Reset with auto-generated email');
    console.log('resetPassword("FUNAAB/2020/12345", "your@gmail.com") - Reset with your email');
    console.log('resetPasswordAdvanced("FUNAAB/2020/12345") - Advanced reset with response monitoring');
    console.log('directPasswordReset("FUNAAB/2020/12345") - Direct reset (requires custom backend)');
    console.log('showFormValues() - Show current form field values');
    console.log('\n🚀 Example: resetPassword("FUNAAB/2020/12345", "myemail@gmail.com")');
    
})();

// Auto-run example (uncomment and modify as needed)
// resetPassword("YOUR_MATRIC_NUMBER_HERE", "your-email@gmail.com");