<!DOCTYPE html>
<html>
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
<title>Raffle Admin</title>
<link rel="icon" type="image/x-icon" href="/static/favicon.ico">
<link rel="icon" type="image/png" sizes="32x32" href="/static/favicon-256.png">
<link rel="icon" type="image/png" sizes="16x16" href="/static/favicon-256.png">

<style>
:root{
  --bg:#060a12;
  --panel:#091224;
  --panel2:#07101f;
  --line:rgba(80,120,210,.18);
  --line2:rgba(80,120,210,.34);
  --text:#f4f7ff;
  --muted:#9fb0cf;
  --blue:#244fb3;
  --blue2:#183a8f;
  --shadow:0 18px 48px rgba(0,0,0,.38);
}

html,body{
  margin:0;
  padding:0;
  background:radial-gradient(circle at top left, rgba(40,76,166,.18), transparent 24%),linear-gradient(180deg,#05070d 0%,#060a12 100%);
  color:var(--text);
  font-family:Inter,system-ui,Arial,sans-serif;
}

.page-shell{
  max-width:1880px;
  margin:0 auto;
  padding:18px;
}

.card{
  background:linear-gradient(180deg,var(--panel),var(--panel2));
  border:1px solid var(--line);
  border-radius:22px;
  box-shadow:var(--shadow);
}

/* NEW HEADER */
.admin-header{
  display:flex;
  align-items:center;
  gap:18px;
  padding:14px 20px;
  margin-bottom:14px;
  margin-right:10px;
  min-width:0;
}
.header-left{
  display:flex;
  align-items:center;
  gap:18px;
  min-width:0;
  flex:1 1 auto;
}
.admin-header img#mainLogo{
  width:72px;
  height:72px;
  object-fit:contain;
  flex:0 0 auto;
}
.title-block{
  display:flex;
  flex-direction:column;
  gap:2px;
  min-width:0;
  flex:0 1 auto;
}
.title-block h1{
  margin:0;
  font-size:2.2rem;
  line-height:1.05;
  font-weight:700;
  white-space:nowrap;
}
.title-block .sub{
  color:var(--muted);
  font-size:1rem;
}
.title-block .updated{
  color:#e6d77a;
  font-size:.9rem;
}
.stats-inline{
  display:flex;
  gap:10px;
  margin-left:6px;
  flex:0 1 auto;
}
.stat{
  border-radius:14px;
  padding:10px 12px;
  background:rgba(8,17,31,.86);
  border:1px solid var(--line);
  text-align:center;
  min-width:104px;
}
.stat .k{
  color:var(--muted);
  font-size:.8rem;
  margin-bottom:4px;
}
.stat .v{
  font-size:1.6rem;
  font-weight:800;
}
.header-right{
  display:flex;
  align-items:center;
  gap:10px;
  position:relative;
  flex:0 1 auto;
  min-width:0;
}
.admin-flags{
  display:flex;
  flex-direction:column;
  gap:4px;
  align-items:center;
  margin-right:4px;
  min-width:70px;
}
.admin-flag{
  display:flex;
  flex-direction:column;
  gap:2px;
  align-items:center;
  width:100%;
}
.admin-flag-label{
  font-weight:700;
  line-height:1;
  text-align:center;
}
.admin-status-label{
  display:flex;
  align-items:center;
  gap:6px;
  justify-content:center;
  color:#eefff5;
}
.admin-status-dot{
  width:8px;
  height:8px;
  border-radius:50%;
  background:#2bff9d;
  box-shadow:0 0 8px rgba(43,255,157,.75);
  display:inline-block;
  flex:0 0 auto;
}
.admin-status-dice{
  display:none;
  align-items:center;
  justify-content:center;
  font-size:.95rem;
  line-height:1;
  flex:0 0 auto;
}
.admin-flag.status-live .admin-status-label{
  color:#eefff5;
  text-shadow:0 0 6px rgba(43,255,157,.4), 0 0 14px rgba(43,255,157,.22);
}
.admin-flag.status-live .admin-status-dot{
  background:#2bff9d;
  box-shadow:0 0 8px rgba(43,255,157,.75);
}
.admin-flag.status-live .admin-flag-bar{
  background:#1fe38f;
}
.admin-flag.status-complete .admin-status-label{
  color:#ffd6d6;
  text-shadow:0 0 6px rgba(255,0,0,.45), 0 0 14px rgba(255,0,0,.28);
}
.admin-flag.status-complete .admin-status-dot{
  background:#ff0000;
  box-shadow:0 0 8px rgba(255,0,0,.82);
}
.admin-flag.status-complete .admin-flag-bar{
  background:#ff0000;
}
.admin-flag.status-rolling .admin-status-label{
  color:#ffe3c2;
  text-shadow:0 0 6px rgba(201,122,31,.45), 0 0 14px rgba(201,122,31,.26);
}
.admin-flag.status-rolling .admin-status-dot{
  display:none;
}
.admin-flag.status-rolling .admin-status-dice{
  display:inline-flex;
  color:#c97a1f;
  text-shadow:0 0 6px rgba(201,122,31,.45), 0 0 14px rgba(201,122,31,.26);
}
.admin-flag.status-rolling .admin-flag-bar{
  background:#c97a1f;
}
.admin-flag-bar{
  height:6px;
  width:100%;
}
.search-wrap{
  display:flex;
  align-items:center;
  border:1px solid rgba(140,170,230,.12);
  border-radius:999px;
  background:#0f1622;
  padding:6px 8px;
  height:34px;
  min-width:96px;
  max-width:106px;
  flex:0 0 96px;
}
.search-wrap span{
  color:#8ea0bf;
  margin-right:2px;
}
.search-wrap input{
  border:none;
  outline:none;
  background:transparent;
  color:#d6deeb;
  font-weight:600;
  font-size:.74rem;
  width:100%;
  min-width:0;
}
.search-wrap input::placeholder{
  color:#8ea0bf;
  font-weight:500;
}
.profile-menu{
  position:relative;
  flex:0 0 auto;
}
.profile-menu-trigger{
  display:flex;
  align-items:center;
  gap:10px;
  min-height:52px;
  padding:5px 14px 5px 10px;
  border-radius:999px;
  border:1px solid rgba(80,120,210,.34);
  background:rgba(10,18,32,.9);
  color:var(--text);
  box-shadow:var(--shadow);
  cursor:pointer;
}
.profile-menu-trigger:focus{
  outline:none;
  border-color:rgba(140,170,230,.45);
}
.profile-menu-logo{
  width:36px;
  height:36px;
  border-radius:50%;
  object-fit:cover;
  border:1px solid rgba(255,255,255,.1);
  flex:0 0 auto;
}
.profile-menu-caret{
  font-size:.85rem;
  line-height:1;
  color:#f4f7ff;
}
.profile-menu-panel{
  position:absolute;
  top:calc(100% + 14px);
  right:0;
  min-width:250px;
  padding:18px;
  border-radius:28px;
  border:1px solid rgba(80,120,210,.34);
  background:linear-gradient(180deg,rgba(10,18,32,.98),rgba(7,15,28,.98));
  box-shadow:var(--shadow);
  display:none;
  z-index:60;
}
.profile-menu.open .profile-menu-panel{
  display:block;
}
.profile-menu-list,
.profile-submenu-list{
  display:grid;
  gap:14px;
}
.profile-menu-item,
.profile-submenu-trigger{
  width:100%;
  min-height:56px;
  padding:0 20px;
  border:none;
  border-radius:18px;
  background:transparent;
  color:var(--text);
  font-size:1.15rem;
  font-weight:850;
  text-align:right;
  text-decoration:none;
  cursor:pointer;
}
.profile-menu-item:hover,
.profile-submenu-trigger:hover,
.profile-menu-item:focus,
.profile-submenu-trigger:focus{
  background:rgba(80,120,210,.15);
  outline:none;
}
.profile-submenu{
  position:relative;
}
.profile-submenu-trigger{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
}
.profile-submenu-arrow{
  font-size:.95rem;
  line-height:1;
}
.profile-submenu-panel{
  position:absolute;
  top:0;
  right:calc(100% + 16px);
  min-width:250px;
  padding:18px;
  border-radius:28px;
  border:1px solid rgba(80,120,210,.34);
  background:linear-gradient(180deg,rgba(10,18,32,.98),rgba(7,15,28,.98));
  box-shadow:var(--shadow);
  display:none;
}
.profile-submenu.open .profile-submenu-panel{
  display:block;
}
.profile-submenu:hover .profile-submenu-panel{
  display:block;
}
.profile-submenu-item{
  width:100%;
  min-height:56px;
  padding:0 20px;
  border:none;
  border-radius:18px;
  background:transparent;
  color:var(--text);
  font-size:1.15rem;
  font-weight:850;
  text-align:right;
  cursor:pointer;
}
.profile-submenu-item:hover,
.profile-submenu-item:focus{
  background:rgba(80,120,210,.15);
  outline:none;
}

/* NEW BUTTON BAR */
.button-bar{
  display:grid;
  grid-template-columns:repeat(6,minmax(0,1fr));
  gap:12px;
  margin-bottom:14px;
}
.action-btn{
  height:44px;
  border-radius:18px;
  border:1px solid var(--line2);
  background:linear-gradient(180deg,#0b1a34,#09142a);
  color:#f4f7ff;
  font-size:1rem;
  font-weight:850;
  box-shadow:var(--shadow);
  cursor:pointer;
}

/* LEGACY LAYOUT CLEANUP */
#main{
  max-width:none;
  margin:0;
  padding:0;
}

#main_table{
  width:100%;
}

#column_guildinfo{
  width:210px;
  vertical-align:top;
}

#column_prizeinfo{
  vertical-align:top;
}

#column_ticketinfo{
  width:260px;
  vertical-align:top;
}

#column_ticketlist{
  display:none;
}

#left,
#center,
#right{
  background:linear-gradient(180deg,var(--panel),var(--panel2));
  border:1px solid var(--line);
  border-radius:22px;
  box-shadow:var(--shadow);
  padding:14px;
  margin:0 6px;
}

#ticket_list{
  background:linear-gradient(180deg,var(--panel),var(--panel2));
  border:1px solid var(--line);
  border-radius:22px;
  box-shadow:var(--shadow);
  padding:10px;
  margin:0 6px;
  overflow:hidden;
}

/* hide legacy top summary now shown in new header */
.legacy-summary-hide{
  display:none !important;
}

/* give settings area some structure */
.settings-block-label{
  display:block;
  margin:10px 0 4px 0;
  color:var(--muted);
  font-size:.92rem;
  font-weight:700;
}

#raffle_notes{
  width:100%;
  max-width:220px;
  min-height:180px;
  background:#182233;
  color:#f4f7ff;
  border:1px solid rgba(140,170,230,.20);
  border-radius:10px;
  padding:10px;
  box-sizing:border-box;
}

#raffle_subheader,
#raffle_time,
#raffle_cost,
#raffle_title,
#raffle_status{
  width:100%;
  max-width:220px;
background:#0f1622;
color:#d6deeb;
border:1px solid rgba(140,170,230,.12);
  border-radius:10px;
  padding:8px 10px;
  box-sizing:border-box;
}

#dropzone_uploader{
  width:100%;
  max-width:220px;
  box-sizing:border-box;
}

#add_prize_block{
  margin-top:12px;
}

#add_prize_button,
#new_raffle_button,
#manual_refresh,
#clear_imported,
#reshow_import,
#reshow_confirm,
#import_barter,
#import_paid{
  border-radius:12px;
  border:1px solid var(--line2);
  background:linear-gradient(180deg,#0b1a34,#09142a);
  color:#f4f7ff;
  padding:10px 14px;
  font-weight:800;
  cursor:pointer;
}

.hidden-original-action{
  display:none !important;
}

/* keep legacy prize/table styling functional */
.prize{
  width:100%;
}

.prize input[type="text"]{
  background:#0f1622;
  color:#d6deeb;
  border:1px solid rgba(140,170,230,.12);
  border-radius:8px;
}

.prize input[type="text"]:focus{
  outline:none;
  border-color:rgba(140,170,230,.28);
}

@media (max-width:1200px){
  .admin-header{
    flex-wrap:wrap;
  }
  .header-left{
    width:100%;
    flex-wrap:wrap;
  }
  .header-right{
    width:100%;
    justify-content:flex-end;
    flex-wrap:wrap;
  }
  .button-bar{
    grid-template-columns:repeat(3,minmax(0,1fr));
  }
  .search-wrap{
    flex:1 1 96px;
    max-width:130px;
  }
}

@media (max-width:1450px){
  .admin-header{
    flex-wrap:wrap;
  }
  .header-right{
    width:100%;
    justify-content:flex-end;
    flex-wrap:wrap;
  }
}

@media (max-width:1100px){
  .button-bar{
    grid-template-columns:repeat(2,minmax(0,1fr));
  }
  .profile-submenu-panel{
    right:0;
    top:calc(100% + 12px);
  }
}

@media (max-width:900px){
  .button-bar{
    grid-template-columns:1fr;
  }
}
</style>

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

var openRaffleLookup = function () {
        var raffleCode = $.trim($("#raffle_lookup").val())
        if (!raffleCode) {
            return false
        }

        window.open("/${request.matchdict['guild']}/lookup?raffle_lookup=" + encodeURIComponent(raffleCode), "_blank")
        return false
}

function normalizeRaffleStatus(status) {
        var value = (status || "LIVE").toString().trim().toUpperCase()
        if (value === "CLOSED") {
                return "ROLLING"
        }
        if (value !== "LIVE" && value !== "ROLLING" && value !== "COMPLETE") {
                return "LIVE"
        }
        return value
}

function applyAdminStatus(status) {
        var normalizedStatus = normalizeRaffleStatus(status)
        var statusFlag = $("#adminStatusFlag")
        var statusLabel = $("#adminStatusLabel")

        statusFlag.removeClass("status-live status-rolling status-complete")
        statusFlag.addClass("status-" + normalizedStatus.toLowerCase())
        statusLabel.text(normalizedStatus)
}


// Some of my best friends use JSON!
var GLOBAL_PRIZE_ALERTED = false
var CURRENT_RAFFLE_INFO = {
    raffle_subheader: "",
    raffle_time: "",
    raffle_cost: ""
}

function normalizeFieldValue(value) {
    if (value === null || value === undefined) {
        return ""
    }
    return $.trim(String(value))
}

function confirmDangerousFieldChange(fieldId, oldValue, newValue) {
    if (oldValue === newValue) {
        return true
    }

    if (fieldId === "raffle_subheader") {
        return confirm("Are you sure you want to change the raffle number from " + oldValue + " to " + newValue + "?")
    }

    if (fieldId === "raffle_time") {
        return confirm("Are you sure you want to change the raffle drawing time from \"" + oldValue + "\" to \"" + newValue + "\"?")
    }

    if (fieldId === "raffle_cost") {
        return confirm("Are you sure you want to change the ticket cost from " + oldValue + " to " + newValue + "?")
    }

    return true
}


var get_guild_header = function () {
        $.getJSON("json/get/guild", function (result) {
                $("#guild_header").text(result["guild_name"])
                $("#display_guild_header").text(result["guild_name"])
            });
    }
var get_raffle_info = function () {
        // #raffle_subheader, #raffle_time, #raffle_cost
        $.getJSON("json/get/raffle", function (result) {
                $("#raffle_subheader").val(result["raffle_guild_num"])
$("#raffle_time").val(result["raffle_time"])
$("#raffle_cost").val(result["raffle_ticket_cost"])
$("#raffle_title").val(result["raffle_title"] || "")
$("#raffle_status").val(normalizeRaffleStatus(result["raffle_status"]))
$("#raffle_notes").val(result["raffle_notes"])
                applyAdminStatus(result["raffle_status"])

                CURRENT_RAFFLE_INFO.raffle_subheader = normalizeFieldValue(result["raffle_guild_num"])
                CURRENT_RAFFLE_INFO.raffle_time = normalizeFieldValue(result["raffle_time"])
                CURRENT_RAFFLE_INFO.raffle_cost = normalizeFieldValue(result["raffle_ticket_cost"])

                $("#display_raffle_subheader").text("#" + result["raffle_guild_num"] + " Raffle")
                $("#display_raffle_time").text("Drawing: " + result["raffle_time"])
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

function addTicketRanges(rows, extended) {
    var runningStart = 1
    var output = []

    for (var i = 0; i < rows.length; i++) {
        var row = rows[i]
        if (!row) {
            output.push(row)
            continue
        }

        var total = Number(row[2]) || 0
        var rangeText = ""

        if (total > 0) {
            var runningEnd = runningStart + total - 1
            rangeText = runningStart + "-" + runningEnd
            runningStart = runningEnd + 1
        }

        var newRow = row.slice()
        newRow.push(rangeText)
        output.push(newRow)
    }

    return output
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
                // if paid or bar is empty, make it 0
                var prevRow = Number(rowIndex - 1)
                if (prevRow >= 0) {
                    try {
                        if (ti.handsontable("getDataAtCell", prevRow, 3) == null)
                        { ti.handsontable("setDataAtCell", prevRow, 3, 0) }
                        // barter
                        if (ti.handsontable("getDataAtCell", prevRow, 4) == null)
                        { ti.handsontable("setDataAtCell", prevRow, 4, 0) }
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

                var updated = DateFormat.format.date(parseInt(result) * 1000, "M/d/yyyy h:mm:ss a") + " EDT"

                $("#raffle_updated").text("Updated: " + updated.toString())
                $("#display_raffle_updated").text("Last Updated " + updated.toString())
                
                })
% if request.extended_tickets:
        $.getJSON(window.location.pathname + "json/get/tickets_extended", function (result) {
                result = addTicketRanges(result, true)
                $("#ticket_info").handsontable("destroy")
                $("#ticket_info").handsontable({
                        data: result,
                        rowHeaders: false,
                        colHeaders: ["#", "Name", "Total", "Paid", "Bar", "Range"],
                        colWidths: [42, 180, 55, 55, 55, 110],
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
                                readOnly: true,
                            },
                        ],
                        isEmptyRow: function(row) {
                            var col, colLen, value, meta;

                            var col1 = this.getDataAtCell(row, 1)
                            var col3 = this.getDataAtCell(row, 3)
                            var col4 = this.getDataAtCell(row, 4)

                            if ((col1 == null || col1 == '') || ((col3 == null || col3 == '') && (col4 == null || col4 == ''))) { return true }

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
                    $("#display_raffle_sold").text(total_tickets)
                    $("#display_raffle_participants").text(total_participants)
                })
% else:
        $.getJSON(window.location.pathname + "json/get/tickets", function (result) {
                result = addTicketRanges(result, false)
                $("#ticket_info").handsontable("destroy")
                $("#ticket_info").handsontable({
                        data: result,
                        rowHeaders: false,
                        colHeaders: ["#", "Name", "Total", "Range"],
                        colWidths: [100, 220, 55, 110],
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
                                                    {
                                readOnly: true,
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
                        })
                    var data = $("#ticket_info").handsontable("getData")
                    var total_tickets = 0
                    var total_participants = data.length - 1
                    for (var i = 0; i < data.length; i++) {
                        total_tickets = total_tickets + data[i][2]
                    }
                    $("#raffle_sold").text(total_tickets + " tickets sold.")
                    $("#raffle_participants").text(total_participants + " unique participants.")
                    $("#display_raffle_sold").text(total_tickets)
                    $("#display_raffle_participants").text(total_participants)

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
                var $field = $(this)
                var fieldId = $field.attr("id")
                var trackedMap = {
                    "raffle_subheader": "raffle_subheader",
                    "raffle_time": "raffle_time",
                    "raffle_cost": "raffle_cost"
                }

                if (trackedMap[fieldId]) {
                    var oldValue = normalizeFieldValue(CURRENT_RAFFLE_INFO[trackedMap[fieldId]])
                    var newValue = normalizeFieldValue($field.val())

                    if (oldValue !== "" && oldValue !== newValue) {
                        if (!confirmDangerousFieldChange(fieldId, oldValue, newValue)) {
                            $field.val(oldValue)
                            return
                        }
                    }
                }

                $.ajax({
                    type: "POST",
                    url: "json/set/raffle",
                    data: $("#ginfo_form").serialize(),
                    success: function (result) {
                        if (trackedMap[fieldId]) {
                            CURRENT_RAFFLE_INFO[trackedMap[fieldId]] = normalizeFieldValue($field.val())
                        }
                    },
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
                    var r = confirm("This will close the current raffle, open a new raffle, carry forward the drawing time and ticket cost, and auto-increment the raffle number. Are you sure?")
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

document.addEventListener('DOMContentLoaded', function () {
        var menu = document.getElementById('adminProfileMenu')
        var trigger = document.getElementById('adminProfileMenuTrigger')
        var submenu = document.getElementById('adminTemplateSubmenu')
        var submenuTrigger = document.getElementById('adminTemplateSubmenuTrigger')

        if (!menu || !trigger || !submenu || !submenuTrigger) {
                return
        }

        function setMenuOpen(open) {
                menu.classList.toggle('open', open)
                trigger.setAttribute('aria-expanded', open ? 'true' : 'false')
                if (!open) {
                        submenu.classList.remove('open')
                        submenuTrigger.setAttribute('aria-expanded', 'false')
                }
        }

        function setSubmenuOpen(open) {
                submenu.classList.toggle('open', open)
                submenuTrigger.setAttribute('aria-expanded', open ? 'true' : 'false')
        }

        submenu.addEventListener('mouseenter', function () {
                if (menu.classList.contains('open')) {
                        setSubmenuOpen(true)
                }
        })

        submenu.addEventListener('mouseleave', function () {
                setSubmenuOpen(false)
        })

        trigger.addEventListener('click', function (event) {
                event.preventDefault()
                event.stopPropagation()
                setMenuOpen(!menu.classList.contains('open'))
        })

        submenuTrigger.addEventListener('click', function (event) {
                event.preventDefault()
                event.stopPropagation()
                if (!menu.classList.contains('open')) {
                        setMenuOpen(true)
                }
                setSubmenuOpen(!submenu.classList.contains('open'))
        })

        document.addEventListener('click', function (event) {
                if (!menu.contains(event.target)) {
                        setMenuOpen(false)
                }
        })

        document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                        setMenuOpen(false)
                }
        })
})
</script>
</head>
<body>
<div class="page-shell">

<section class="card admin-header">
  <div class="header-left">
  <img id="mainLogo" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="BBC logo">

  <div class="title-block">
    <h1 id="display_guild_header">Guild</h1>
    <div class="sub"><strong id="display_raffle_subheader">Raffle</strong> • <span id="display_raffle_time">Drawing</span></div>
    <div class="updated" id="display_raffle_updated">Last Updated</div>
  </div>

  <div class="stats-inline">
    <div class="stat"><div class="k">Total Tickets</div><div class="v" id="display_raffle_sold">0</div></div>
    <div class="stat"><div class="k">Participants</div><div class="v" id="display_raffle_participants">0</div></div>
  </div>
  </div>

  <div class="header-right">
    <div class="admin-flags">
      <div class="admin-flag">
        <div class="admin-flag-label">ADMIN</div>
        <div class="admin-flag-bar" style="background:#c97a1f;"></div>
      </div>
      <div class="admin-flag status-live" id="adminStatusFlag">
        <div class="admin-flag-label admin-status-label">
          <span class="admin-status-dot"></span>
          <span class="admin-status-dice" aria-hidden="true">🎲</span>
          <span id="adminStatusLabel">LIVE</span>
        </div>
        <div class="admin-flag-bar"></div>
      </div>
    </div>

    <div class="search-wrap">
      <span>🔍</span>
      <input type="text" id="raffle_lookup" name="raffle_lookup" placeholder="Enter raffle #" onkeydown="if (event.key === 'Enter') { event.preventDefault(); openRaffleLookup(); }" />
    </div>
    <div class="profile-menu" id="adminProfileMenu">
      <button type="button" class="profile-menu-trigger" id="adminProfileMenuTrigger" aria-expanded="false" aria-haspopup="true">
        <img class="profile-menu-logo" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="Guild logo">
        <span class="profile-menu-caret">▼</span>
      </button>

      <div class="profile-menu-panel" id="adminProfileMenuPanel">
        <div class="profile-menu-list">
          <div class="profile-submenu" id="adminTemplateSubmenu">
            <button type="button" class="profile-submenu-trigger" id="adminTemplateSubmenuTrigger" aria-expanded="false">
              <span class="profile-submenu-arrow">◀</span>
              <span>Template</span>
            </button>

            <div class="profile-submenu-panel" id="adminTemplateSubmenuPanel">
              <div class="profile-submenu-list">
                <button type="button" class="profile-submenu-item">Holiday</button>
                <button type="button" class="profile-submenu-item">Halloween</button>
                <button type="button" class="profile-submenu-item">Birthday</button>
                <button type="button" class="profile-submenu-item">Default</button>
              </div>
            </div>
          </div>

          <a class="profile-menu-item" href="/${request.matchdict.get('guild')}/auth/logout">Logout</a>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="button-bar">
  <button type="button" class="action-btn" onclick="$('#new_raffle_button').click()">Open New Raffle</button>
  <button type="button" class="action-btn" onclick="$('#reshow_import').click()">Re-Show Imports</button>
  <button type="button" class="action-btn" onclick="$('#reshow_confirm').click()">Re-Show Confirms</button>
  <button type="button" class="action-btn" onclick="$('#import_paid').click()">Import Paid</button>
  <button type="button" class="action-btn" onclick="$('#import_barter').click()">Import Barter</button>
  <button type="button" class="action-btn" onclick="$('#manual_refresh').click()">Manual Refresh</button>
</section>

<div id="main">
<table id="main_table" valign="top">
    <tr>
        
        <td id="column_guildinfo">
    <div id="left" class="column">
            <form id="ginfo_form">
            <span id="guild_header" class="legacy-summary-hide"></span>

            <label class="settings-block-label" for="raffle_subheader">Raffle Number</label>
            <input type="text" id="raffle_subheader" class="ginfo_change_save" name="raffle_guild_num"/>

            <label class="settings-block-label" for="raffle_time">Drawing Time</label>
            <input type="text" id="raffle_time" class="ginfo_change_save" name="raffle_time"/>

            <label class="settings-block-label" for="raffle_cost">Ticket Cost</label>
            <input type="text" id="raffle_cost" class="ginfo_change_save" name="raffle_ticket_cost"/>

            <label class="settings-block-label" for="raffle_title">Raffle Title</label>
<input type="text" id="raffle_title" class="ginfo_change_save" name="raffle_title"/>

<label class="settings-block-label" for="raffle_status">Status</label>
<select id="raffle_status" class="ginfo_change_save" name="raffle_status">
    <option value="LIVE">LIVE</option>
    <option value="ROLLING">ROLLING</option>
    <option value="COMPLETE">COMPLETE</option>
</select>

            <span id="raffle_sold" class="legacy-summary-hide"></span>
            <span id="raffle_participants" class="legacy-summary-hide"></span>
            <span id="raffle_updated" class="legacy-summary-hide"></span>

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

            <label class="settings-block-label" for="raffle_notes">Admin Notes</label>
            <textarea id="raffle_notes" name="raffle_notes" class="ginfo_change_save">
            </textarea>
            <br />
            <br />
            </form>

            <input type="submit" value="Open new raffle" id="new_raffle_button" class="hidden-original-action" />
            <input type="submit" value="Manually refresh" id="manual_refresh" class="hidden-original-action" />
            <input type="submit" value="Re-Show Import Pane" id="reshow_import" class="hidden-original-action" />
            <input type="submit" value="Re-Show Confirmations Pane" id="reshow_confirm" class="hidden-original-action" />
            <br />
            <br />
% if request.extended_tickets:
            <input type="submit" value="Import barter tickets" id="import_barter" class="hidden-original-action" />
            <input type="submit" value="Import paid tickets" id="import_paid" class="hidden-original-action" />
            <br />
            <br />
% endif
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

</body>
</html>
