<!DOCTYPE html>
<head>   
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.js"></script>
<script src="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.js"></script>
<link rel="stylesheet" media="screen" href="https://cdn.jsdelivr.net/npm/handsontable/dist/handsontable.full.min.css">
% if "raffle" in request.matchdict:
<link rel="stylesheet" href="../../static/css/main.css">
<script type="text/javascript" src="../../static/js/dateformat.js"></script>
% else:
% if "guild" in request.matchdict:
<link rel="stylesheet" href="../static/css/main.css">
<script type="text/javascript" src="../static/js/dateformat.js"></script>
% else:
<link rel="stylesheet" href="static/css/main.css">
<script type="text/javascript" src="static/js/dateformat.js"></script>
%endif
%endif
<title>Raffles!</title>
<script>
$(document).ready(function() {
  $.ajaxSetup({cache:false});
});

// Some of my best friends use JSON!
var refresher = function () {
        // #guild_header
        $.getJSON("json/get/guild", function (result) {
                $("#guild_header").text(result["guild_name"])
            })
        // #raffle_subheader, #raffle_time, #raffle_cost
        $.getJSON("json/get/raffle", function (result) {
                $("#raffle_subheader").text("Raffle #" + result["raffle_guild_num"])
                $("#raffle_time").text(result["raffle_time"])
                $("#raffle_cost").text("Ticket cost: "+result["raffle_ticket_cost"])
                $("#raffle_titlebar").text((result["raffle_status"] || "LIVE") + " - " + (result["raffle_title"] || "Raffle"))
                $("#raffle_notes").html(result["raffle_notes"])
            })
        // deal with prizes
        $.getJSON("json/get/prizes", function (result) {
                $("#prize_info").empty()
                $.each(result, function (index, value) {
                    var template = $("#prize_template").clone()
                    var new_id = "prize_" + value["prize_text2"] + "_"
                    template.attr({"id": new_id + "block"})
                    // fix the prize number
                    $("#prize_number", template).attr({"id": new_id + "number"}).text(value["prize_text2"])
                    var pwinner
                    var pname
                    if (value["prize_finalised"] == 0) {
                        pwinner = ""
                        pname = ""
                    } else {
                        pwinner = "#" + value["prize_winner"]
                        pname = value["prize_winner_name"]
                    }
                    $("#prize_winner", template).attr({"id": new_id + "winner"}).text(pwinner)
                    // we really need to come up with some way of resolving the name simply
                    // get_prize_winner?
                    $("#prize_winner_name", template).attr({"id": new_id + "winner_name"}).text(pname)
                    // at least the prize details are here
                    $("#prize_item", template).attr({"id": new_id + "item"}).text(value["prize_text"])
                    $("#prize_info").append(template)
                })
            })
        $.getJSON("json/get/timestamp", function (result) {
                if (!result) { return; }

                var updated = DateFormat.format.date(parseInt(result) * 1000, "yyyy-MM-dd hh:mm:ss")

                $("#raffle_updated").text("Updated: " + updated.toString())
                
                })
        $.getJSON("json/get/tickets", function (result) {
                $("#raffle_participants").text(result.length + " unique participants.")
                var total = 0
                for (var i = 0; i < result.length; i++) {
                    total += result[i][2] << 0
                }
                $("#raffle_sold").text(total + " tickets sold.")
                $("#ticket_info").handsontable("destroy")
                $("#ticket_info").handsontable({
                        data: result,
                        rowHeaders: false,
                        colHeaders: ["Participants", "Name", "Total"],
                        colWidths: [100, 300, 50],
                        contextMenu: false,
			licenseKey: "non-commercial-and-evaluation",			
                        }).handsontable("updateSettings", {cells: function (row, col, prop) {
                            return {"readOnly": true}
                            }})
                })
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



$(document).ready(refresher)
$(document).ready(function () {
        window.setInterval(refresher, 30000)
        $("#ticket_list").height($(window).height()-20)
        })
$(window).resize(function () {
        $("#ticket_list").height($(window).height()-20)
        })

</script>
</head>
<body>
<div id="main">
<table id="main_table">
    <tr>
        <td id="column_ticketlist">
            <div id="ticket_list">
            </div>
        </td>
        <td id="column_guildinfo">
    <div id="left" class="column">
            <span id="guild_header"></span>
            <br />
            <span id="raffle_subheader"></span>
            <br />
            <span id="raffle_time"></span>
            <br />
            <span id="raffle_cost"></span>
            <br />
            <span id="raffle_sold"></span>
            <br />
            <span id="raffle_participants"></span>
            <br />
            <span id="raffle_updated"></span>            <br />
            <form id="raffle_lookup_form" action="/${request.matchdict['guild']}/lookup" method="get" style="margin: 10px 0 0 0;">
                <label for="raffle_lookup" style="display:block; margin-bottom:4px;">Previous raffle lookup</label>
                <input type="text" id="raffle_lookup" name="raffle_lookup" placeholder="Enter raffle #" style="width: 140px;" />
                <input type="submit" value="Go" />
            </form>
            <br />
            <br />
            <strong id="raffle_titlebar">LIVE - Raffle</strong>
            <br />
            <span id="raffle_notes"></span>
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
            <br />
            <br />
            % endif
    </div>
        </td>
        <td id="column_prizeinfo">
    <div id="center" class="column">
        <div id="prize_info">
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
<table id="prize_template" class="prize">
    <tr>
        <th rowspan="3" class="prize_number_column"><span class="prize_number" id="prize_number"></span></td>
        <td class="winning_number">Winning Number:</td>
        <td class="number_column"><span id="prize_winner" class="prize_winner"></span></td>
    </tr>
    <tr>
        <td class="winner">Winner:</td>
        <td class="winner_column"><span id="prize_winner_name" class="prize_winner_name"></span></td>
    </tr>
    <tr>
        <td class="winning_prize">Prize:</td>
        <td class="prize_column"><span id="prize_item" class="prize_item"></span></td>
    </tr>
</table>
</body>
</html>
