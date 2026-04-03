<!DOCTYPE html>
<head>   
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
<script src="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.js"></script>
<link rel="stylesheet" media="screen" href="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.css">
% if "guild" in request.matchdict:
<link rel="stylesheet" href="/static/css/main.css">
<link rel="stylesheet" href="/static/css/admin.css">
<link rel="stylesheet" href="/static/css/dropzone.css">
<script type="text/javascript" src="/static/js/dropzone.js"></script>
<script type="text/javascript" src="/static/js/dateformat.js"></script>
% else:
<link rel="stylesheet" href="/static/css/main.css">
<link rel="stylesheet" href="/static/css/admin.css">
<script type="text/javascript" src="/static/js/dropzone.js"></script>
<script type="text/javascript" src="/static/js/dateformat.js"></script>
<link rel="stylesheet" href="/static/css/dropzone.css">
%endif
<title>Raffles!</title>
<script>
jQuery.fn.center = function() {
    var container = $(window);
    var top = -this.height() / 2;
    var left = -this.width() / 2;
    return this.css('position', 'absolute').css({ 'margin-left': left + 'px', 'margin-top': top + 'px', 'left': '50%', 'top': '50%' });
}

$(document).ready(function() {
  $.ajaxSetup({cache:false});
});

// Some of my best friends use JSON!
var GLOBAL_PRIZE_ALERTED = false

var get_guild_header = function () {
        $.getJSON("json/get/guild", function (result) {
                $("#guild_header").text(result["guild_name"])
            });
    }
var get_raffle_info = function () {
        // #raffle_subheader, #raffle_time, #raffle_cost
        $.getJSON("json/get/raffle", function (result) {
                $("#raffle_subheader").val(result["raffle_guild_num"])
                $("#raffle_time").val(result["raffle_time"])
                $("#raffle_cost").val(result["raffle_ticket_cost"])
                $("#raffle_notes").val(result["raffle_notes"])
            })
}
var get_prize_info = function () {
        // deal with prizes
        $.getJSON("json/get/prizes", function (result) {
                $("#prize_info").empty()
                $.each(result, function (index, value) {
                    var template = $("#prize_template").clone()
                    var new_id = "prize_" + value["prize_text2"] + "_"
                    var id_id = "prize_" + value["prize_id"] + "_"
                    template.attr({"id": new_id + "block"})
                    // fix the prize number
                    $("#prize_number", template).attr({"id": new_id + "number"}).val(value["prize_text2"])
                    var pwinner = value["prize_winner"]
                    var pname = value["prize_winner_name"]
                    $("#prize_winner", template).attr({"id": new_id + "winner"}).val(pwinner)
                    if (value["prize_finalised"] != 0) {
                        $("#prize_winner_name", template).addClass("finalised")
                    }
                    $("#prize_winner_name", template).attr({"id": new_id + "winner_name"}).text(pname)

                    // at least the prize details are here
                    $("#prize_item", template).attr({"id": new_id + "item"}).val(value["prize_text"])
                    if (value["prize_finalised"] != 0) {
                        $("#prize_finalise", template).remove()
                        $("#prize_delete", template).remove()
                        $("#prize_roll", template).remove()
                    } else {
                        $("#prize_finalise", template).attr({"id": id_id + "finalise"})
                        $("#prize_delete", template).attr({"id": id_id + "delete"})
                        $("#prize_roll", template).attr({"id": id_id + "roll"})
                    }
                    $("#prize_template_form", template).attr({"id": "prize_" + value["prize_id"] + "_form"})
                    $(".prize_id", template).val(value["prize_id"])

                    $(".prize_delete", template).click(function () {
                        if (GLOBAL_PRIZE_ALERTED == false) {
                            GLOBAL_PRIZE_ALERTED = true
                            var r = confirm("Prize deletion is final and irreversible. You will only be shown this message once per session. Press OK to confirm deletion, or cancel to go back.")
                            if (r == false) {
                                return
                            }
                        }

                        $.getJSON("json/set/prize_delete/" + value["prize_id"], function (result) {
                            get_prize_info()
                            })
                        
                    })
                    $(".prize_finalise", template).click(function () {
                            $.getJSON("json/set/prize_finalise/" + value["prize_id"], function (result) {
                                get_prize_info()
                                })
                            })
                    $(".prize_roll", template).click(function () {
                            $.getJSON("json/set/prize_roll/" + value["prize_id"], function (result) {
                                get_prize_info()
                                })
                            })

                    $("input[type='text']", template).change(function () {
                            $.ajax({
                                type: "POST",
                                url: "json/set/prize",
                                data: $("#" + id_id + "form").serialize(),
                                success: function (result) {
                                    get_prize_info()
                                },
                                xhrFields: {
                                    withCredentials: true
                                },
                                })

                            })

                    $("#prize_info").append(template)
                })
            })
}

var save_ticket_data = function () {
}

var GUILD_ROSTER = null

var _get_guild_roster = function (query, process) {
    if (GUILD_ROSTER == null) {
        $.getJSON("json/get/roster", function (result) {
                    GUILD_ROSTER = result
                    process(result)
                })
    } else {
        process(GUILD_ROSTER)
    }
}

var get_ticket_table = function () {
        function after_row_create (index, amount) {
            setTimeout(function () {
                var ti = $("#ticket_info")
                
                // Ensure index is a number
                var rowIndex = parseInt(index, 10)
                
                if (isNaN(rowIndex) || rowIndex < 0) {
                    return
                }

                // Ensure all parameters are proper numbers
                var row = Number(rowIndex)
                var col = 0
                var value = Number(rowIndex + 1)
                
                try {
                    ti.handsontable("setDataAtCell", row, col, value)
                } catch (error) {
                    return
                }
% if request.extended_tickets:                
                // if paid is empty, make it 0
                var prevRow = Number(rowIndex - 1)
                if (prevRow >= 0) {
                    try {
                        if (ti.handsontable("getDataAtCell", prevRow, 3) == null)
                        { ti.handsontable("setDataAtCell", prevRow, 3, 0) }
                        // free
                        if (ti.handsontable("getDataAtCell", prevRow, 4) == null)
                        { ti.handsontable("setDataAtCell", prevRow, 4, 0) }
                        // barter
                        if (ti.handsontable("getDataAtCell", prevRow, 5) == null)
                        { ti.handsontable("setDataAtCell", prevRow, 5, 0) }
                    } catch (error) {
                        // Ignore errors setting default values
                    }
                }
% endif
            }, 100)

        }

        function after_cell_change (change, source) {
            if (source == "ignore") { return }

% if request.extended_tickets:
            if (change) {
                var row = parseInt(change[0][0], 10)
                if (isNaN(row) || row < 0) {
                    return
                }

                var ti = $("#ticket_info")

                var paid = ti.handsontable("getDataAtCell", row, 3)
                var free = ti.handsontable("getDataAtCell", row, 4)
                var bart = ti.handsontable("getDataAtCell", row, 5)
                
                // Ensure values are numbers
                paid = isNaN(paid) ? 0 : Number(paid)
                free = isNaN(free) ? 0 : Number(free)
                bart = isNaN(bart) ? 0 : Number(bart)

                var total = paid + free + bart

                ti.handsontable("setDataAtCell", row, 2, total, "ignore")
            }
% endif
            setTimeout(function () {
                var data = $("#ticket_info").handsontable("getData")
                $.ajax({
                    type: "POST",
% if request.extended_tickets:
                    url: "json/set/tickets_extended",
% else:
                    url: "json/set/tickets",
% endif
                    data: JSON.stringify(data),
                    contentType: "application/json",
                    success: function (result) {
                        if (result && result > 0) {
                            get_ticket_list()
                        }
                    },
                    xhrFields: {
                        withCredentials: true
                    },
                    })
    
            }, 100)
        }

        $.getJSON("json/get/timestamp", function (result) {
                if (!result) { return; }

                var updated = DateFormat.format.date(parseInt(result) * 1000, "yyyy-MM-dd hh:mm:ss")

                $("#raffle_updated").text("Updated: " + updated.toString())
                
                })
% if request.extended_tickets:
        $.getJSON("json/get/tickets_extended", function (result) {
                $("#ticket_info").handsontable("destroy")
                $("#ticket_info").handsontable({
                        data: result,
                        rowHeaders: false,
                        colHeaders: ["Participants", "Name", "Total", "Paid", "Free", "Bar"],
                        colWidths: [100, 180, 45, 45, 45, 45],
                        contextMenu: false,
                        enterMoves: {row: 0, col: 1},
                        columnSorting: true,
			licenseKey: "non-commercial-and-evaluation",
                        columns: [
                            {
                                readOnly: true,
                            },
                            {
                            }, // autocomplete column
                            {
                                type: 'numeric',
                                format: '1,000,000',
                                readOnly: true,
                                currentColClassName: 'totals-column',
                            },
                            {
                                type: 'numeric',
                                format: '1,000,000',
                                allowInvalid: false,
                            },
                            {
                                type: 'numeric',
                                format: '1,000,000',
                                allowInvalid: false,
                            },
                            {
                                type: 'numeric',
                                format: '1,000,000',
                                allowInvalid: false,
                            },
                        ],
                        isEmptyRow: function(row) {
                            var col, colLen, value, meta;

                            var col1 = this.getDataAtCell(row, 1)
                            var col3 = this.getDataAtCell(row, 3)
                            var col4 = this.getDataAtCell(row, 4)
                            var col5 = this.getDataAtCell(row, 5)

                            if ((col1 == null || col1 == '') || ((col3 == null || col3 == '') && (col4 == null || col4 == '') && (col5 == null || col5 == ''))) { return true }

                            return false
                        },
                        minSpareRows: 1,
                        afterCreateRow: after_row_create,
                        afterChange: after_cell_change,
                        })
                    var data = $("#ticket_info").handsontable("getData")
                    var total_tickets = 0
                    var total_participants = data.length - 1
                    for (var i = 0; i < data.length; i++) {
                        total_tickets = total_tickets + data[i][2]
                    }
                    $("#raffle_sold").text(total_tickets + " tickets sold.")
                    $("#raffle_participants").text(total_participants + " unique participants.")
                })
% else:
        $.getJSON("json/get/tickets", function (result) {
                //$("#raffle_participants").text(result.length + " unique participants.")
                //var total = 0
                //for (var i = 0; i < result.length; i++) {
                //    total += result[i][2] << 0
                //}
                // $("#raffle_sold").text(total + " tickets sold.")
                $("#ticket_info").handsontable("destroy")
                $("#ticket_info").handsontable({
                        data: result,
                        rowHeaders: false,
                        colHeaders: ["Participants", "Name", "Total"],
                        colWidths: [100, 300, 50],
                        contextMenu: false,
                        enterMoves: {row: 0, col: 1},
                        columnSorting: true,
			licenseKey: "non-commercial-and-evaluation",
                        columns: [
                            {},
                            {
                                type: 'autocomplete',
                                source: _get_guild_roster,
                                validator: function (value, callback) {
                                        var row, rowl, val

                                        var ti = $("#ticket_info")

                                        var rowl = ti.handsontable("countRows")

                                        for (row = 0; row < rowl; row++) {
                                            val = ti.handsontable("getDataAtCell", row, 1)
                                            if (this.row !== row && val == value) {
                                                callback(false)
                                            }
                                        }

                                        callback(true)
                                },
                                allowInvalid: false,
                            }, // autocomplete column
                            {
                                type: 'numeric',
                                format: '1,000,000',
                                allowInvalid: false,
                            },
                        ],
                        isEmptyRow: function(row) {
                            var col, colLen, value, meta;

                            var col1 = this.getDataAtCell(row, 1)
                            var col2 = this.getDataAtCell(row, 2)

                            if (col1 == null || col1 == '' || col2 == null || col2 == '') { 
                                return true
                            }

                            return false
                        },
                        minSpareRows: 1,
                        afterCreateRow: after_row_create,
                        afterChange: after_cell_change,
                        })//.handsontable("updateSettings", {cells: function (row, col, prop) {
                           /// if (col == 0) { return {"readOnly": true} }
                           /// }})
                    var data = $("#ticket_info").handsontable("getData")
                    var total_tickets = 0
                    var total_participants = data.length - 1
                    for (var i = 0; i < data.length; i++) {
                        total_tickets = total_tickets + data[i][2]
                    }
                    $("#raffle_sold").text(total_tickets + " tickets sold.")
                    $("#raffle_participants").text(total_participants + " unique participants.")

                })
% endif
}

var get_ticket_list = function () {
        $.getJSON("json/get/ticket_list", function (result) {
                $("#ticket_list").handsontable("destroy")
                $("#ticket_list").handsontable ({
                        data: result,
                        rowHeaders: false,
                        colHeaders: ["Ticket", "Name"],
                        colWidths: [70, 200],
                        contextMenu: false,
			licenseKey: "non-commercial-and-evaluation",
                        }).handsontable("updateSettings", {cells: function (row, col, prop) {
                            return {"readOnly": true}
                            }})
                })
}


var refresher = function () {
    get_guild_header()
    get_raffle_info()
    get_prize_info()
    get_ticket_table()
    get_ticket_list()
}

$(document).ready(refresher)
$(document).ready(function () {
            $(".ginfo_change_save").change(function () {
                $.ajax({
                    type: "POST",
                    url: "json/set/raffle",
                    data: $("#ginfo_form").serialize(),
                    success: function (result) { },
                    xhrFields: {
                        withCredentials: true
                    }
                })
            })
            $("#add_prize_button").click(function () {
                $.getJSON("json/set/prize_add", function (result) {
                        if (result) { get_prize_info() }
                    })
            })
            $("#manual_refresh").click(function () {
                get_ticket_table()
                get_ticket_list()
            })
            $("#new_raffle_button").click(function () {
                    var r = confirm("This will close the current raffle and activate a new one.  Are you sure?")
                    if (r == false) { return }

                    $.getJSON("json/set/open_raffle", function (result) {
                            refresher()
                        })
                    })
            $("#ticket_list").height($(window).height()-20)

            window.setTimeout(function () {
            $("#dropzone_uploader")[0].dropzone.on("success", function (file, response) { 
                // Check if response is a redirect (authentication failure)
                if (typeof response === 'string' && response.includes('redirected automatically')) {
                    alert('Authentication required. Please log in as an admin user first.');
                    window.location.href = 'auth/login';
                    return;
                }
                
                // Check if response is empty or invalid
                if (!response || response.length == 0) { 
                    alert('No ticket data found in uploaded file. Please check the file format.');
                    return; 
                }
                
                // Check if response is an error object
                if (response.error) {
                    alert('Error: ' + response.error);
                    return;
                }
                
                $("#import_template").css({'width': '900px', 'height': '600px', 'z-index': 100}).addClass("import").center().show()
                // get the first header
                var headline = $("#import_data_here tr").first().clone() 
                $("#import_data_here").empty().append(headline)
                var table = $("#import_data_here")
                $.each(response, function (key, item) {
                    var tr = $("<tr></tr>")
                    var td = $("<td></td>")
                    var name_td = td.clone()
                    var name = $("<input type='text' name='row"+key+"_name' />").val(item[0]).appendTo(name_td)
                    name_td.appendTo(tr)
                    var uid = $("<input type='hidden' name='row"+key+"_uid' />").val(item[4]).appendTo(name_td)
                    var amount = $("<input type='text' name='row"+key+"_amount' />").val(item[1]).appendTo(td.clone().appendTo(tr))
                    var sub
                    if (item[2] == "GUILD BANK DEPOSIT") { sub = "[Guild Bank]" } else { sub = item[2] }
                    var subject = td.clone().text(sub).appendTo(tr)
                    var time
                    if (item[3] == "MAILED IN") { time = "[Mail]" } else { time = item[3] }
                    var time_ = td.clone().text(time).appendTo(tr)
                    var check = $("<input type='checkbox' name='row"+key+"_confirmed' />").appendTo(td.clone().appendTo(tr))
                    table.append(tr)
                })
                $("#check_all").prop("checked", false)
            });
            
            $("#dropzone_uploader")[0].dropzone.on("error", function (file, errorMessage) {
                if (typeof errorMessage === 'string') {
                    alert('Upload error: ' + errorMessage);
                } else if (errorMessage.error) {
                    alert('Upload error: ' + errorMessage.error);
                } else {
                    alert('Upload failed. Please try again.');
                }
            });
            }, 1000)

            // "Select all" checkbox handler - using event delegation for dynamically created elements
            $(document).on('click', '#check_all', function () {
                if ($(this).is(":checked")) {
                    $("#import_data_here input[type=checkbox]:not(#check_all)").prop("checked", true)
                } else {
                    $("#import_data_here input[type=checkbox]:not(#check_all)").prop("checked", false)
                }
            })

            $("#import_close_button").click(function () { $("#import_template").hide() })
            $("#confirm_close_button").click(function () { $("#confirm_template").hide() })
            $("#barter_close_button").click(function () { $("#barter_template").hide() })
            $("#paid_close_button").click(function () { $("#paid_template").hide() })
            $("#clear_imported").click(function () {
                    $.getJSON("json/set/fix_dupes", function (result) { })
                    })
            $("#import_selected").click(function () {
                if ($("#import_template").is(":visible")) {
                        var formData = $("#import_this").serialize();
                        console.log("Form data:", formData);
                        
                        $.ajax({
                                type: "POST",
                                url: "json/set/tickets_import2",
                                data: formData,
                                success: function (result) {
                                    // refresh everything!
                                    refresher()
                                    $("#import_template").hide()
                                    $("#confirm_template").css({'width': '900px', 'height': '600px', 'z-index': 100}).addClass("import").center().show()
                                    $("#confirm_string").val(result[0])
                                    $("#confirm_names").val(result[1])
                                },
                                error: function (xhr, status, error) {
                                    alert("Import failed: " + error + "\nStatus: " + status + "\nResponse: " + xhr.responseText);
                                },
                                xhrFields: {
                                    withCredentials: true
                                },
                                })

                }
                    })
          $("#reshow_import").click(function () { $("#confirm_template").hide()
                                                  $("#import_template").show() })
          $("#reshow_confirm").click(function () { $("#confirm_template").show()
                                                  $("#import_template").hide() })
          $("#import_barter").click(function () { $("#confirm_template").hide()
                                                  $("#barter_template").css({'width': '900px', 'height': '600px', 'z-index': 100}).addClass("barter").center().show() })
          $("#import_paid").click(function () { $("#confirm_template").hide()
                                                  $("#paid_template").css({'width': '900px', 'height': '600px', 'z-index': 100, 'background-color': '#f8f8f8', 'border': '1px solid #000000', 'padding': '2px'}).addClass("paid").center().show() })
          $("#barter_import").click(function () {
                if ($("#barter_template").is(":visible")) {
                        $.ajax({
                                type: "POST",
                                url: "json/set/barter_import",
                                data: $("#barter_this").serialize(),
                                success: function (result) {
                                    // refresh everything!
                                    refresher()
                                    $("#barter_template").hide()
                                    $("#confirm_template").css({'width': '900px', 'height': '600px', 'z-index': 100}).addClass("import").center().show()
                                    $("#confirm_string").val(result[0])
                                    $("#confirm_names").val(result[1])
                                },
                                xhrFields: {
                                    withCredentials: true
                                },
                                })

                }
                    })
          $("#paid_import").click(function () {
                if ($("#paid_template").is(":visible")) {
                        $.ajax({
                                type: "POST",
                                url: "json/set/paid_import",
                                data: $("#paid_this").serialize(),
                                success: function (result) {
                                    // refresh everything!
                                    refresher()
                                    $("#paid_template").hide()
                                    $("#confirm_template").css({'width': '900px', 'height': '600px', 'z-index': 100}).addClass("import").center().show()
                                    $("#confirm_string").val(result[0])
                                    $("#confirm_names").val(result[1])
                                },
                                xhrFields: {
                                    withCredentials: true
                                },
                                })

                }
                    })

        })
$(window).resize(function () {
        $("#ticket_list").height($(window).height()-20)
        })
</script>
</head>
<body>
<div id="main">
<table id="main_table" valign="top">
    <tr>
        <td id="column_ticketlist">
            <div id="ticket_list">
            </div>
        </td>
        <td id="column_guildinfo">
    <div id="left" class="column">
            <span><a href="/bbc/auth/logout">[Logout]</a></span>
            <form id="ginfo_form">
            <span id="guild_header"></span>
            <br />
            Raffle #<input type="text" id="raffle_subheader" class="ginfo_change_save" name="raffle_guild_num"/>
            <br />
            <input type="text" id="raffle_time" class="ginfo_change_save" name="raffle_time"/>
            <br />
            Ticket cost: <input type="text" id="raffle_cost" class="ginfo_change_save" name="raffle_ticket_cost"/>
            <br />
            <span id="raffle_sold"></span>
            <br />
            <span id="raffle_participants"></span>
            <br >
            <span id="raffle_updated"></span>            <br />
            <form id="raffle_lookup_form" action="/${request.matchdict['guild']}/lookup" method="get" style="margin: 10px 0 0 0;">
                <label for="raffle_lookup" style="display:block; margin-bottom:4px;">Previous raffle lookup</label>
                <input type="text" id="raffle_lookup" name="raffle_lookup" placeholder="Enter raffle #" style="width: 140px;" />
                <input type="submit" value="Go" />
            </form>
            <br />
            % if request.bonus_tickets == 5:
            <br />
            <br />
            <span id="bonus_tickets">
                For every 5 tickets purchased, you get 1 bonus ticket!
            </span>
            % elif request.bonus_tickets == 2:
            <br />
            <br />
            <span id="bonus_tickets">
                For every 2 tickets purchased, you get 1 bonus ticket!
            </span>
            % endif
            <br />
            <textarea id="raffle_notes" name="raffle_notes" class="ginfo_change_save">
            </textarea>
            <br />
            <br />
            </form>
            <input type="submit" value="Open new raffle" id="new_raffle_button" />
            <br />
            <br />
            <input type="submit" value="Manually refresh" id="manual_refresh" />
            <br />
            <br />
            <input type="submit" value="Clear dupes" id="clear_imported" />
            <br />
            <br />
            <input type="submit" value="Re-Show Import Pane" id="reshow_import" />
            <br />
            <br />
            <input type="submit" value="Re-Show Confirmations Pane" id="reshow_confirm" />
            <br />
            <br />
% if request.extended_tickets:
            <input type="submit" value="Import barter tickets" id="import_barter" />
            <br />
            <br />
            <input type="submit" value="Import paid tickets" id="import_paid" />
            <br />
            <br />
% endif
            <a href="json/get/csv" target="_blank">Export as CSV</a>
            <br />
            <br />
            <form action="json/set/tickets_import" class="dropzone" id="dropzone_uploader"></form>
    </div>
        </td>
        <td id="column_prizeinfo">
    <div id="center" class="column">
        <div id="prize_info">
        </div>
        <div id="add_prize_block">
            <input type="submit" value="Add prize" id="add_prize_button" />
        </div>
    </div>
        </td>
        <td id="column_ticketinfo">
    <div id="right" class="column">
        <div id="ticket_info">
        </div>
    </div>
        </td>
    </tr>
</table>
</div>
<div id="prize_template">
<form id="prize_template_form">
<table class="prize">
    <tr>
        <th rowspan="3" class="prize_number_column"><input type="text" class="prize_number" id="prize_number" name="prize_text2" /></td>
        <td class="winning_number">Winning Number:</td>
        <td class="number_column"><input type="text" id="prize_winner" class="prize_winner" name="prize_winner"/></td>
        <td class="delete_button"><a href="#" id="prize_delete" class="prize_delete">x</a></td>
    </tr>
    <tr>
        <td class="winner">Winner:</td>
        <td class="winner_column"><span id="prize_winner_name" class="prize_winner_name"></span></td>
        <td class="roll_button"><a href="#" id="prize_roll" class="prize_roll">R</a></td>
    </tr>
    <tr>
        <td class="winning_prize">Prize:</td>
        <td class="prize_column"><input type="text" id="prize_item" class="prize_item" name="prize_text" /></td>
        <td class="finalise_button"><a href="#" id="prize_finalise" class="prize_finalise">f</a></td>
    </tr>
</table>
<input type="hidden" name="prize_id" value="" class="prize_id" />
</form>
</div>
<div id="import_template">
<div id="import_buttons"><input type="button" value="Close" id="import_close_button" /> <input type="submit" value="Import Selected" id="import_selected" /></div>
<div id="import_data">
    <form id="import_this">
        <table id="import_data_here">
            <tr>
                <th>User</th>
                <th>Amount</th>
                <th>Subject</th>
                <th>Time</th>
                <th><input type="checkbox" id="check_all" /></th>
            </tr>
        </table>
    </form>
</div>
</div>
 
<div id="confirm_template" class="confirm">
<div id="confirm_buttons"><input type="button" value="Close" id="confirm_close_button" /></div>
<div id="confirm_data">
    <br />
    <p>Confirmation string (copy &amp; paste into addon)</p>
    <textarea id="confirm_string"></textarea>
    <br />
    <p>Confirmation names</p>
    <br />
    <textarea id="confirm_names"></textarea>
</div>
</div>

<div id="barter_template" class="barter">
<div id="barter_buttons"><input type="button" value="Close" id="barter_close_button" /> <input type="submit" value="Import" id="barter_import" /></div>
<div id="barter_data">
    <br />
    <p>Barter imports:</p>
    <form id="barter_this">
    <textarea name="barter_import_string" id="barter_import_string"></textarea>
    <p>Confirmation string:</p>
    <textarea name="barter_confirm_string" id="barter_confirm_string"></textarea>
    </form>
</div>
</div>

<div id="paid_template" class="paid">
<div id="paid_buttons"><input type="button" value="Close" id="paid_close_button" /> <input type="submit" value="Import" id="paid_import" /></div>
<div id="paid_data">
    <br />
    <p>Paid ticket imports:</p>
    <form id="paid_this">
    <textarea name="paid_import_string" id="paid_import_string"></textarea>
    <p>Confirmation string:</p>
    <textarea name="paid_confirm_string" id="paid_confirm_string"></textarea>
    </form>
</div>
</div>


<script>
const bbcMenuWrap=document.getElementById('bbcMenuWrap');const bbcMenuTrigger=document.getElementById('bbcMenuTrigger');const templateSubmenuWrap=document.getElementById('templateSubmenuWrap');const templateSubmenuTrigger=document.getElementById('templateSubmenuTrigger');bbcMenuTrigger.addEventListener('click',function(e){e.stopPropagation();const open=bbcMenuWrap.classList.toggle('open');bbcMenuTrigger.setAttribute('aria-expanded',open?'true':'false');if(!open)templateSubmenuWrap.classList.remove('open');});document.addEventListener('click',function(e){if(!bbcMenuWrap.contains(e.target)){bbcMenuWrap.classList.remove('open');templateSubmenuWrap.classList.remove('open');bbcMenuTrigger.setAttribute('aria-expanded','false');}});
</script>

</body>
</html>
