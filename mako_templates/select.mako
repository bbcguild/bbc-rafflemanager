<!DOCTYPE html>
<head>   
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
<title>Raffles!</title>
</head>
<body>
<div id="main">
    <p>Select a guild:</p>
    <p><ul>
    % for guild in guilds:
        <li><a href="${guild['guild_shortname']}/">${guild['guild_name']}</a></li>
    % endfor
    </ul></p>
</div>
</body>
</html>
