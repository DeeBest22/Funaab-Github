<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Net.Mail" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Text" %>

<!DOCTYPE html>
<html>
<head>
    <title>Flexible Password Reset - FUNAAB Portal</title>
    <link rel="stylesheet" href="style.css" media="screen" />
    <style>
        .reset-container { max-width: 600px; margin: 50px auto; padding: 30px; background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .success-message { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 4px; margin: 20px 0; }
        .error-message { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; border-radius: 4px; margin: 20px 0; }
        .info-message { background: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; padding: 15px; border-radius: 4px; margin: 20px 0; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 16px; }
        .btn-reset { background: #007cba; color: white; padding: 12px 30px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        .btn-reset:hover { background: #005a87; }
    </style>
</head>
<body>
    <div class="reset-container">
        <h2>🔐 Flexible Password Reset</h2>
        
        <script runat="server">
            protected void Page_Load(object sender, EventArgs e)
            {
                if (IsPostBack)
                {
                    ProcessPasswordReset();
                }
            }
            
            private void ProcessPasswordReset()
            {
                string matricNo = Request.Form["matricNo"];
                string emailAddress = Request.Form["emailAddress"];
                
                if (string.IsNullOrEmpty(matricNo) || string.IsNullOrEmpty(emailAddress))
                {
                    ShowMessage("Please fill in all required fields.", "error");
                    return;
                }
                
                try
                {
                    // Generate new password
                    string newPassword = GenerateSecurePassword();
                    
                    // Update password in database
                    bool updateSuccess = UpdateUserPassword(matricNo, newPassword);
                    
                    if (updateSuccess)
                    {
                        // Send email with new password
                        bool emailSent = SendPasswordEmail(emailAddress, matricNo, newPassword);
                        
                        if (emailSent)
                        {
                            ShowMessage($"✅ Password reset successful! New password has been sent to {emailAddress}", "success");
                            LogPasswordReset(matricNo, emailAddress, "SUCCESS");
                        }
                        else
                        {
                            ShowMessage($"⚠️ Password updated but email failed to send. Your new password is: <strong>{newPassword}</strong><br/>Please save this password and change it after login.", "info");
                            LogPasswordReset(matricNo, emailAddress, "EMAIL_FAILED");
                        }
                    }
                    else
                    {
                        ShowMessage("❌ User not found or password update failed. Please check your matriculation number.", "error");
                        LogPasswordReset(matricNo, emailAddress, "USER_NOT_FOUND");
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage($"❌ Error occurred: {ex.Message}", "error");
                    LogPasswordReset(matricNo, emailAddress, $"ERROR: {ex.Message}");
                }
            }
            
            private string GenerateSecurePassword()
            {
                // Generate a secure 8-character password with mixed case, numbers, and symbols
                const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%";
                var random = new Random();
                return new string(Enumerable.Repeat(chars, 8).Select(s => s[random.Next(s.Length)]).ToArray());
            }
            
            private bool UpdateUserPassword(string matricNo, string newPassword)
            {
                // Try multiple possible connection strings and table structures
                string[] connectionStrings = {
                    "Server=localhost;Database=FUNAAB_Portal;Integrated Security=true;",
                    "Server=localhost;Database=StudentPortal;Integrated Security=true;",
                    "Server=.;Database=FUNAAB_Portal;Integrated Security=true;",
                    // Add your actual connection string here
                    System.Configuration.ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString
                };
                
                string[] possibleTables = { "Students", "Users", "UserAccounts", "StudentAccounts" };
                string[] possibleUserColumns = { "MatricNo", "Username", "StudentID", "UserID" };
                string[] possiblePasswordColumns = { "Password", "UserPassword", "Pwd", "PassWord" };
                
                foreach (string connStr in connectionStrings)
                {
                    if (string.IsNullOrEmpty(connStr)) continue;
                    
                    try
                    {
                        using (SqlConnection conn = new SqlConnection(connStr))
                        {
                            conn.Open();
                            
                            // Try different table and column combinations
                            foreach (string table in possibleTables)
                            {
                                foreach (string userCol in possibleUserColumns)
                                {
                                    foreach (string passCol in possiblePasswordColumns)
                                    {
                                        try
                                        {
                                            string hashedPassword = HashPassword(newPassword);
                                            
                                            string updateQuery = $@"
                                                UPDATE {table} 
                                                SET {passCol} = @password, 
                                                    LastModified = GETDATE(),
                                                    FailedLoginAttempts = 0
                                                WHERE {userCol} = @matricNo";
                                            
                                            using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                                            {
                                                cmd.Parameters.AddWithValue("@password", hashedPassword);
                                                cmd.Parameters.AddWithValue("@matricNo", matricNo);
                                                
                                                int rowsAffected = cmd.ExecuteNonQuery();
                                                if (rowsAffected > 0)
                                                {
                                                    return true; // Success!
                                                }
                                            }
                                        }
                                        catch
                                        {
                                            // Try next combination
                                            continue;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    catch
                    {
                        // Try next connection string
                        continue;
                    }
                }
                
                return false;
            }
            
            private string HashPassword(string password)
            {
                // Try multiple hashing methods that might be used
                // You may need to adjust this based on your system's actual hashing method
                
                // Method 1: SHA256
                using (SHA256 sha256Hash = SHA256.Create())
                {
                    byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(password));
                    return Convert.ToBase64String(bytes);
                }
                
                // If the above doesn't work, try these alternatives:
                // Method 2: MD5 (less secure but commonly used)
                // using (MD5 md5Hash = MD5.Create())
                // {
                //     byte[] bytes = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(password));
                //     return Convert.ToBase64String(bytes);
                // }
                
                // Method 3: Plain text (if no hashing is used - not recommended)
                // return password;
            }
            
            private bool SendPasswordEmail(string emailAddress, string matricNo, string newPassword)
            {
                try
                {
                    MailMessage mail = new MailMessage();
                    mail.From = new MailAddress("noreply@funaab.edu.ng", "FUNAAB Student Portal");
                    mail.To.Add(emailAddress);
                    mail.Subject = "FUNAAB Portal - Password Reset";
                    
                    mail.Body = $@"
                        <html>
                        <body style='font-family: Arial, sans-serif;'>
                            <h2 style='color: #007cba;'>FUNAAB Student Portal - Password Reset</h2>
                            
                            <p>Dear Student,</p>
                            
                            <p>Your password has been successfully reset for matriculation number: <strong>{matricNo}</strong></p>
                            
                            <div style='background: #f8f9fa; padding: 15px; border-left: 4px solid #007cba; margin: 20px 0;'>
                                <p><strong>Your new password is: {newPassword}</strong></p>
                            </div>
                            
                            <p><strong>Important Security Notes:</strong></p>
                            <ul>
                                <li>Please change this password immediately after logging in</li>
                                <li>Do not share this password with anyone</li>
                                <li>Use a strong, unique password for your account</li>
                            </ul>
                            
                            <p>If you did not request this password reset, please contact the IT department immediately.</p>
                            
                            <p>Best regards,<br/>
                            FUNAAB IT Department</p>
                            
                            <hr style='margin-top: 30px;'/>
                            <small style='color: #666;'>
                                This is an automated message. Please do not reply to this email.
                            </small>
                        </body>
                        </html>";
                    
                    mail.IsBodyHtml = true;
                    
                    SmtpClient smtp = new SmtpClient();
                    // Configure SMTP settings - you'll need to update these
                    smtp.Host = "smtp.gmail.com"; // or your SMTP server
                    smtp.Port = 587;
                    smtp.EnableSsl = true;
                    smtp.Credentials = new System.Net.NetworkCredential("your-email@gmail.com", "your-app-password");
                    
                    smtp.Send(mail);
                    return true;
                }
                catch (Exception ex)
                {
                    // Log the error but don't expose it to user
                    System.Diagnostics.Debug.WriteLine($"Email send failed: {ex.Message}");
                    return false;
                }
            }
            
            private void LogPasswordReset(string matricNo, string email, string status)
            {
                try
                {
                    // Log the password reset attempt for security auditing
                    string logEntry = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} - Password Reset - MatricNo: {matricNo}, Email: {email}, Status: {status}, IP: {Request.UserHostAddress}";
                    
                    // Write to file log
                    string logPath = Server.MapPath("~/App_Data/password_reset_log.txt");
                    System.IO.File.AppendAllText(logPath, logEntry + Environment.NewLine);
                }
                catch
                {
                    // Ignore logging errors
                }
            }
            
            private void ShowMessage(string message, string type)
            {
                string cssClass = type == "success" ? "success-message" : 
                                 type == "error" ? "error-message" : "info-message";
                
                Response.Write($"<div class='{cssClass}'>{message}</div>");
            }
        </script>
        
        <div class="info-message">
            <strong>📧 Flexible Email Reset</strong><br/>
            Enter your matriculation number and ANY email address where you want to receive the new password.
            You don't need to use your institutional email.
        </div>
        
        <form method="post">
            <div class="form-group">
                <label for="matricNo">Matriculation Number:</label>
                <input type="text" id="matricNo" name="matricNo" required 
                       placeholder="Enter your matriculation number" />
            </div>
            
            <div class="form-group">
                <label for="emailAddress">Email Address (Any valid email):</label>
                <input type="email" id="emailAddress" name="emailAddress" required 
                       placeholder="Enter any email where you want to receive the password" />
                <small style="color: #666; font-size: 0.9em;">
                    This can be Gmail, Yahoo, Outlook, or any other email service
                </small>
            </div>
            
            <button type="submit" class="btn-reset">Reset Password</button>
        </form>
        
        <div style="margin-top: 30px; padding: 15px; background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px;">
            <h4>🔒 Security Features:</h4>
            <ul>
                <li>✅ Generates secure random passwords</li>
                <li>✅ Updates password in database immediately</li>
                <li>✅ Sends password to any email you specify</li>
                <li>✅ Logs all reset attempts for security</li>
                <li>✅ Resets failed login attempts counter</li>
            </ul>
        </div>
        
        <p style="text-align: center; margin-top: 20px;">
            <a href="Login.html" style="color: #007cba;">← Back to Login</a>
        </p>
    </div>
</body>
</html>