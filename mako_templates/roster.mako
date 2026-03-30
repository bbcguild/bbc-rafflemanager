<!DOCTYPE html>
<head>   
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
<link rel="stylesheet" href="../static/css/main.css">
<link rel="stylesheet" href="../static/css/admin.css">
<link rel="stylesheet" href="../static/css/dropzone.css">
<script type="text/javascript" src="../static/js/dropzone.js"></script>
<title>Roster Import</title>
<script>
$(document).ready(function() {
  $.ajaxSetup({cache:false});
  
  // Configure Dropzone
  Dropzone.options.dropzoneUploader = {
    url: "json/set/parse",
    maxFiles: 1,
    acceptedFiles: ".lua",
    init: function() {
      this.on("success", function(file, response) {
        if (response && response.length > 0) {
          $("#output_data").val(response);
          $("#result_section").show();
        } else {
          $("#output_data").val("No data returned or upload failed");
          $("#result_section").show();
        }
      });
      
      this.on("error", function(file, errorMessage) {
        $("#output_data").val("Error: " + errorMessage);
        $("#result_section").show();
      });
    }
  };
});
</script>
</head>
<body>
<div id="main">
<h2>Roster Import</h2>
<p>Upload your RaffleManager.lua file:</p>
<form action="json/set/parse" class="dropzone" id="dropzone_uploader">
  <div class="dz-message">
    Drop RaffleManager.lua file here or click to upload
  </div>
</form>

<div id="result_section" style="display:none;">
  <h3>Import Result:</h3>
  <textarea id="output_data" rows="10" cols="80" readonly></textarea>
  <p><em>Copy this formula and paste it into your spreadsheet</em></p>
</div>
</div>
</body>
</html>
