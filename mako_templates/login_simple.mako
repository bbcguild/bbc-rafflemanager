<!DOCTYPE html>
<html>
<head>
    <title>${title}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .login-form { max-width: 400px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="password"] { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 3px; }
        input[type="submit"] { background-color: #007cba; color: white; padding: 10px 20px; border: none; border-radius: 3px; cursor: pointer; }
        input[type="submit"]:hover { background-color: #005a87; }
    </style>
</head>
<body>
    <div class="login-form">
        <h2>${title}</h2>
        % if form:
            <form method="POST" action="">
                ${csrf_token_field | n}
                <div class="form-group">
                    <label for="username">Username:</label>
                    ${form.username()}
                </div>
                <div class="form-group">
                    <label for="password">Password:</label>
                    ${form.password()}
                </div>
                <div class="form-group">
                    <input type="submit" value="Login">
                </div>
            </form>
        % else:
            <p>Login form not available.</p>
        % endif
    </div>
</body>
</html>
