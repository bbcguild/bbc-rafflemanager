<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<link rel="Stylesheet" type="text/css" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.17/themes/smoothness/jquery-ui.css">
<link href="static/css/main.css" type="text/css" rel="Stylesheet">
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.js"></script>
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.17/jquery-ui.js"></script>
<script type="text/javascript" src="static/js/themeswitchertool.js"></script>
<script type="text/javascript">
$(document).ready(function () {
    $("#submit").button()
    $("#clear").button()
    $("#password, #password2, #username, #old_password").addClass("ui-widget ui-corner-all ui-state-default password")

})
</script>
<title>Pyramid Apex</title>
<%namespace file="flash_template.mako" import="*"/>
<link rel="stylesheet" href="${request.static_url('auth:static/css/apex_forms.css')}" type="text/css" media="screen" charset="utf-8" />
${apex_head()}
<style type="text/css">
body { margin: 10px auto 10px auto; width: 400px; font-family: Verdana, sans;}
</style>
</head>
<body>
${apex_flash()}

<div id="login_window" class="ui-dialog ui-widget ui-widget-content ui-corner-all">
<h1>${title}</h1>
% if form:
${form.render()|n}
% endif
</div>
</body>
</html>
