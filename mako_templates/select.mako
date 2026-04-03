<!DOCTYPE html>
<html>
<head>
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
<title>Raffles!</title>
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
        --link: #f4f7ff;
        --link-hover: #d8e4ff;
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

    #main {
        width: min(100%, 760px);
        padding: 34px 40px 38px;
        border: 1px solid var(--line);
        border-radius: 22px;
        background: linear-gradient(180deg, var(--panel), var(--panel2));
        box-shadow: var(--shadow);
        text-align: center;
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

    .intro {
        margin: 28px 0 18px;
        font-size: 1.1rem;
        color: var(--muted);
    }

    ul {
        list-style: none;
        margin: 0;
        padding: 0;
        display: grid;
        gap: 14px;
    }

    a {
        display: block;
        padding: 16px 18px;
        border: 1px solid var(--line);
        border-radius: 14px;
        background: rgba(12, 21, 38, 0.88);
        color: var(--link);
        text-decoration: none;
        font-size: 1.2rem;
        font-weight: 700;
    }

    a:hover {
        color: var(--link-hover);
        border-color: rgba(140, 170, 230, 0.35);
        background: rgba(18, 30, 54, 0.96);
    }
</style>
</head>
<body>
<div id="main">
    <div class="brand">
        <img src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="BBC logo">
        <h1>RAFFLES</h1>
    </div>

    <p class="intro">Select a guild:</p>
    <ul>
        <li><a href="bbc1/">Bleakrock Barter Co</a></li>
        <li><a href="bbc2/">Blackbriar Barter Co</a></li>
    </ul>
</div>
</body>
</html>
