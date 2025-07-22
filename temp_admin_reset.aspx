<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Text" %>

<!DOCTYPE html>
<html>
<head>
    <title>Emergency Admin Reset - FUNAAB Portal</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; max-width: 600px; margin: 0 auto; }
        .warning { background: #ffebee; border: 1px solid #f44336; padding: 15px; margin-bottom: 20px; border-radius: 4px; }
        .success { background: #e8f5e8; border: 1px solid #4caf50; padding: 15px; margin-bottom: 20px; border-radius: 4px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="password"], select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        .btn { background: #007cba; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        .btn:hover { background: #005a87; }
        .danger { background: #d32f2f; }
        .danger:hover { background: #b71c1c; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚨 Emergency Admin Reset Tool</h1>
        
        <div class="warning">
            <strong>WARNING:</strong> This is an emergency tool. Delete this file immediately after use!
            Only use this if you have legitimate administrative access to recover the system.
        </div>

        <script runat="server">
            protected void Page_Load(object sender, EventArgs e)
            {
                // Security check - only allow from localhost
                if (!Request.IsLocal)
                {
                    Response.StatusCode = 403;
                    Response.End();
                }
            }

            protected void ResetPassword_Click(object sender, EventArgs e)
            {
                string connectionString = txtConnectionString.Text;
                string username = txtUsername.Text;
                string newPassword = txtNewPassword.Text;
                string tableName = ddlUserTable.SelectedValue;
                
                try
                {
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        
                        // Hash the password (adjust based on your system's hashing method)
                        string hashedPassword = HashPassword(newPassword);
                        
                        // Update query - adjust column names based on your schema
                        string updateQuery = $@"
                            UPDATE {tableName} 
                            SET Password = @password, 
                                LastModified = GETDATE(),
                                FailedLoginAttempts = 0,
                                IsLocked = 0
                            WHERE Username = @username OR Email = @username OR MatricNo = @username";
                        
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@password", hashedPassword);
                            cmd.Parameters.AddWithValue("@username", username);
                            
                            int rowsAffected = cmd.ExecuteNonQuery();
                            
                            if (rowsAffected > 0)
                            {
                                lblResult.Text = $"✅ Password reset successful for user: {username}";
                                lblResult.CssClass = "success";
                                
                                // Log the reset attempt
                                LogPasswordReset(conn, username, Request.UserHostAddress);
                            }
                            else
                            {
                                lblResult.Text = "❌ User not found or no changes made";
                                lblResult.CssClass = "warning";
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    lblResult.Text = $"❌ Error: {ex.Message}";
                    lblResult.CssClass = "warning";
                }
            }
            
            private string HashPassword(string password)
            {
                // Use SHA256 - adjust based on your system's method
                using (SHA256 sha256Hash = SHA256.Create())
                {
                    byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(password));
                    return Convert.ToBase64String(bytes);
                }
            }
            
            private void LogPasswordReset(SqlConnection conn, string username, string ipAddress)
            {
                try
                {
                    string logQuery = @"
                        INSERT INTO PasswordResetLog (Username, ResetDate, IPAddress, ResetBy)
                        VALUES (@username, GETDATE(), @ip, 'EMERGENCY_RESET')";
                    
                    using (SqlCommand cmd = new SqlCommand(logQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@username", username);
                        cmd.Parameters.AddWithValue("@ip", ipAddress);
                        cmd.ExecuteNonQuery();
                    }
                }
                catch
                {
                    // Log table might not exist, ignore error
                }
            }
            
            protected void TestConnection_Click(object sender, EventArgs e)
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(txtConnectionString.Text))
                    {
                        conn.Open();
                        lblResult.Text = "✅ Database connection successful!";
                        lblResult.CssClass = "success";
                        
                        // Try to list user tables
                        string query = @"
                            SELECT TABLE_NAME 
                            FROM INFORMATION_SCHEMA.TABLES 
                            WHERE TABLE_TYPE = 'BASE TABLE' 
                            AND TABLE_NAME LIKE '%user%' OR TABLE_NAME LIKE '%student%' OR TABLE_NAME LIKE '%admin%'
                            ORDER BY TABLE_NAME";
                        
                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                ddlUserTable.Items.Clear();
                                ddlUserTable.Items.Add(new ListItem("Select a table...", ""));
                                
                                while (reader.Read())
                                {
                                    string tableName = reader["TABLE_NAME"].ToString();
                                    ddlUserTable.Items.Add(new ListItem(tableName, tableName));
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    lblResult.Text = $"❌ Connection failed: {ex.Message}";
                    lblResult.CssClass = "warning";
                }
            }
        </script>

        <form runat="server">
            <div class="form-group">
                <label>Database Connection String:</label>
                <asp:TextBox ID="txtConnectionString" runat="server" 
                    Text="Server=localhost;Database=FUNAAB_Portal;Integrated Security=true;" 
                    TextMode="MultiLine" Rows="3" />
                <small>Try: Server=localhost;Database=FUNAAB_Portal;User Id=sa;Password=yourpassword;</small>
            </div>
            
            <div class="form-group">
                <asp:Button ID="btnTestConnection" runat="server" Text="Test Connection" 
                    OnClick="TestConnection_Click" CssClass="btn" />
            </div>
            
            <div class="form-group">
                <label>User Table:</label>
                <asp:DropDownList ID="ddlUserTable" runat="server">
                    <asp:ListItem Text="Users" Value="Users" />
                    <asp:ListItem Text="Students" Value="Students" />
                    <asp:ListItem Text="Administrators" Value="Administrators" />
                    <asp:ListItem Text="UserAccounts" Value="UserAccounts" />
                </asp:DropDownList>
            </div>
            
            <div class="form-group">
                <label>Username/Email/Matric No:</label>
                <asp:TextBox ID="txtUsername" runat="server" />
            </div>
            
            <div class="form-group">
                <label>New Password:</label>
                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" />
            </div>
            
            <div class="form-group">
                <asp:Button ID="btnResetPassword" runat="server" Text="Reset Password" 
                    OnClick="ResetPassword_Click" CssClass="btn danger" 
                    OnClientClick="return confirm('Are you sure you want to reset this password?');" />
            </div>
            
            <asp:Label ID="lblResult" runat="server" />
        </form>
        
        <div style="margin-top: 30px; padding: 15px; background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px;">
            <h3>🔒 Security Checklist After Recovery:</h3>
            <ul>
                <li>✅ Delete this file immediately</li>
                <li>✅ Change all administrative passwords</li>
                <li>✅ Enable database auditing</li>
                <li>✅ Review user accounts for unauthorized access</li>
                <li>✅ Update connection strings with new credentials</li>
                <li>✅ Enable HTTPS and security headers</li>
            </ul>
        </div>
    </div>
</body>
</html>