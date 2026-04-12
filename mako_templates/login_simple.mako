<%
ga4_site_area = 'admin_auth'
ga4_raffle_view = 'current'
ga4_raffle_number = ''
ga4_guild_slug = request.matchdict.get('guild', '')
is_staging = (request.registry.settings.get("app_env") == "staging")
stage_label = (request.registry.settings.get("app_stage_label") or "STAGING").strip()
%>
<%namespace file="flash_template.mako" import="apex_flash"/>
<!DOCTYPE html>
<html>
<head>
    <title>${('[%s] ' % stage_label) if is_staging else ''}${title}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <%include file="analytics_snippet.mako"/>
    <style>
        :root {
            --bg: #060a12;
            --bg2: #0b1220;
            --panel: #0c1526;
            --panel2: #08101d;
            --line: rgba(95, 132, 212, 0.24);
            --text: #f4f7ff;
            --muted: #b1bfd9;
            --input-bg: #111a2a;
            --input-border: rgba(140, 170, 230, 0.18);
            --button1: #1e63d8;
            --button2: #164ca8;
            --shadow: 0 22px 60px rgba(0, 0, 0, 0.42);
        }

        * { box-sizing: border-box; }

        html, body {
            margin: 0;
            padding: 0;
            min-height: 100%;
            font-family: Inter, system-ui, Arial, sans-serif;
            color: var(--text);
            background:
                radial-gradient(circle at top left, rgba(40, 76, 166, 0.20), transparent 24%),
                linear-gradient(180deg, #05070d 0%, #060a12 100%);
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        body.is-staging {
            box-shadow: inset 0 6px 0 #d94a4a;
        }

        .stage-banner {
            position: fixed;
            top: 16px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 20;
            padding: 10px 16px;
            border: 1px solid rgba(217, 74, 74, 0.55);
            background: linear-gradient(180deg, rgba(123, 21, 21, 0.96), rgba(95, 16, 16, 0.96));
            color: #fff3f3;
            font-size: 13px;
            font-weight: 900;
            letter-spacing: .16em;
            text-transform: uppercase;
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.28);
        }

        .login-wrap {
            width: min(100%, 520px);
            background: linear-gradient(180deg, var(--panel), var(--panel2));
            border: 1px solid var(--line);
            border-radius: 24px;
            box-shadow: var(--shadow);
            padding: 28px 28px 24px;
        }

        .brand {
            text-align: center;
            margin-bottom: 18px;
        }

        .brand img {
            width: 86px;
            height: 86px;
            object-fit: contain;
            display: block;
            margin: 0 auto 10px;
        }

        .brand-title {
            margin: 0;
            font-size: 1.9rem;
            line-height: 1;
            font-weight: 800;
            letter-spacing: 0.06em;
        }

        .prompt {
            margin: 18px 0 18px;
            color: var(--muted);
            font-size: 1rem;
            text-align: center;
        }

        .login-form h2 {
            display: none;
        }

        .login-flash {
            margin: 0 0 16px;
        }

        .login-flash .flash {
            margin: 0 0 10px;
        }

        .login-flash .flash p {
            margin: 0;
            padding: 12px 14px;
            border-radius: 12px;
            font-weight: 700;
        }

        .login-flash .flash p.error {
            background: rgba(132, 34, 34, 0.28);
            border: 1px solid rgba(214, 96, 96, 0.32);
            color: #ffd6d6;
        }

        .login-flash .flash p.notice,
        .login-flash .flash p.success,
        .login-flash .flash p.warning {
            background: rgba(40, 76, 166, 0.18);
            border: 1px solid rgba(95, 132, 212, 0.24);
            color: var(--text);
        }

        .form-group {
            margin-bottom: 16px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-size: 1rem;
            font-weight: 800;
            color: var(--text);
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 14px 16px;
            border-radius: 12px;
            border: 1px solid var(--input-border);
            background: var(--input-bg);
            color: var(--text);
            font-size: 1.05rem;
            outline: none;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.02);
        }

        input[type="text"]:focus,
        input[type="password"]:focus {
            border-color: rgba(140, 170, 230, 0.36);
            box-shadow: 0 0 0 3px rgba(50, 94, 184, 0.18);
        }

        input[type="submit"] {
            margin-top: 4px;
            min-width: 150px;
            padding: 13px 22px;
            border: none;
            border-radius: 14px;
            background: linear-gradient(180deg, var(--button1), var(--button2));
            color: white;
            font-size: 1rem;
            font-weight: 800;
            cursor: pointer;
            box-shadow: 0 12px 28px rgba(14, 38, 84, 0.35);
        }

        input[type="submit"]:hover {
            filter: brightness(1.05);
        }

        .login-missing {
            color: var(--muted);
            text-align: center;
            margin: 0;
        }

        @media (max-width: 640px) {
            body {
                align-items: flex-start;
                padding: 16px;
            }

            .login-wrap {
                padding: 22px 18px 20px;
                border-radius: 20px;
            }

            .brand img {
                width: 74px;
                height: 74px;
            }

            .brand-title {
                font-size: 1.65rem;
            }
        }
    </style>
</head>
<body class="${'is-staging' if is_staging else ''}">
% if is_staging:
    <div class="stage-banner">${stage_label} ENVIRONMENT</div>
% endif
    <div class="login-wrap">
        <div class="brand">
            <img src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="BBC logo">
            <h1 class="brand-title">RAFFLES</h1>
        </div>

        <div class="prompt">Please log in:</div>

        <div class="login-form">
            <h2>${title}</h2>
            <div class="login-flash">${apex_flash()}</div>
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
                <p class="login-missing">Login form not available.</p>
            % endif
        </div>
    </div>
</body>
</html>
