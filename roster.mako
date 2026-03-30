<!DOCTYPE html>
<head>   
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
<link rel="stylesheet" href="static/css/main.css">
<link rel="stylesheet" href="static/css/admin.css">
<link rel="stylesheet" href="static/css/dropzone.css">
<script type="text/javascript" src="static/js/dropzone.js"></script>
<title>Roster Import</title>
<script>
$(document).ready(function () {
            window.setTimeout(function () {
            $("#dropzone_uploader")[0].dropzone.on("success", function (file, response) { 
                if (response.length == 0) { return; }
            }, 1000)
        })
    })
</script>
</head>
<body>
<div id="main">
<form action="roster/json/set/parse" class="dropzone" id="dropzone_uploader"></form>
</div>
</body>
</html>
