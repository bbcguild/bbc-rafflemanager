<!DOCTYPE html>
<html>
<head>
    <title>${title}</title>
    <link rel="icon" type="image/x-icon" href="/static/favicon.ico">
    <link rel="icon" type="image/png" sizes="32x32" href="/static/favicon-256.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/static/favicon-256.png">
    <style>
        :root {
            --bg: #060a12;
            --panel: #0b1220;
            --panel2: #0f1728;
            --line: rgba(90, 125, 210, 0.22);
            --text: #f4f7ff;
            --muted: #a6b5d1;
            --input-bg: #182233;
            --input-line: rgba(140, 170, 230, 0.24);
            --button1: #0f58c9;
            --button2: #0a459e;
            --shadow: 0 18px 48px rgba(0, 0, 0, 0.38);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 32px;
            background:
                radial-gradient(circle at top left, rgba(40, 76, 166, 0.18), transparent 24%),
                linear-gradient(180deg, #05070d 0%, #060a12 100%);
            color: var(--text);
            font-family: Inter, Arial, sans-serif;
        }

        .login-form {
            width: min(100%, 760px);
            padding: 34px 40px 38px;
            border: 1px solid var(--line);
            border-radius: 22px;
            background: linear-gradient(180deg, var(--panel), var(--panel2));
            box-shadow: var(--shadow);
        }

        .brand {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            margin-bottom: 28px;
        }

        .brand img {
            width: 110px;
            height: 110px;
            object-fit: contain;
            margin-bottom: 8px;
        }

        .brand h1 {
            margin: 0;
            font-size: 2.25rem;
            line-height: 1;
            letter-spacing: 0.04em;
            font-weight: 800;
        }

        .brand-spacer {
            height: 28px;
        }

        .intro {
            margin: 0 0 22px;
            font-size: 1.1rem;
            color: var(--muted);
            text-align: center;
        }

        .form-group {
            margin-bottom: 22px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 800;
            font-size: 1.05rem;
            color: var(--text);
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid var(--input-line);
            border-radius: 12px;
            background: var(--input-bg);
            color: var(--text);
            font-size: 1.2rem;
            outline: none;
        }

        input[type="text"]:focus,
        input[type="password"]:focus {
            border-color: rgba(140, 170, 230, 0.4);
            box-shadow: 0 0 0 3px rgba(61, 112, 223, 0.14);
        }

        input[type="submit"] {
            background: linear-gradient(180deg, var(--button1), var(--button2));
            color: white;
            padding: 14px 28px;
            border: 1px solid rgba(140, 170, 230, 0.2);
            border-radius: 12px;
            cursor: pointer;
            font-size: 1.1rem;
            font-weight: 800;
            min-width: 150px;
        }

        input[type="submit"]:hover {
            filter: brightness(1.08);
        }

        .fallback {
            color: var(--muted);
            text-align: center;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="login-form">
        <div class="brand">
            <img src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="BBC logo">
            <h1>RAFFLES</h1>
        </div>

        <div class="brand-spacer"></div>

        <p class="intro">Please log in:</p>

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
            <p class="fallback">Login form not available.</p>
        % endif
    </div>
</body>
</html>
