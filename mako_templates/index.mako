<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>BBC Raffle</title>

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
% endif
% endif

<style>
:root{
  --panel:#091224;
  --panel2:#07101f;
  --line:rgba(80,120,210,.18);
  --line2:rgba(80,120,210,.34);
  --text:#f4f7ff;
  --muted:#9fb0cf;
  --shadow:0 18px 48px rgba(0,0,0,.38);
  --hover:rgba(80,120,210,.08);
}

*{box-sizing:border-box}
html,body{margin:0;padding:0}
body{
  font-family:Inter,system-ui,Arial,sans-serif;
  color:var(--text);
  background:radial-gradient(circle at top left, rgba(40,76,166,.18), transparent 24%),linear-gradient(180deg,#05070d 0%,#060a12 100%);
}

.page{padding:10px;display:grid;gap:14px}
.card{background:linear-gradient(180deg,var(--panel),var(--panel2));border:1px solid var(--line);border-radius:22px;box-shadow:var(--shadow)}

/* Header */
.header{display:flex;align-items:center;gap:18px;padding:14px 20px}
.header img#mainLogo{width:72px;height:72px;object-fit:contain}
.title-block{display:flex;flex-direction:column;gap:2px;min-width:320px}
.title-block h1{margin:0;font-size:2.2rem;line-height:1.05;font-weight:700}
.title-block .sub{color:var(--muted);font-size:1rem}
.title-block .updated{color:#e6d77a;font-size:.9rem}
.stats-inline{display:flex;gap:10px;margin-left:6px}
.stat{border-radius:14px;padding:10px 14px;background:rgba(8,17,31,.86);border:1px solid var(--line);text-align:center;min-width:120px}
.stat .k{color:var(--muted);font-size:.8rem;margin-bottom:4px}
.stat .v{font-size:1.6rem;font-weight:800}
.header-right{margin-left:auto;display:grid;grid-template-columns:auto auto;align-items:center;gap:18px;min-width:0}
.live-public{
  border:2px solid rgba(56,255,142,.75);
  box-shadow:0 0 10px rgba(56,255,142,.35), inset 0 0 14px rgba(56,255,142,.12);
  background:rgba(8,20,16,.7);
  display:flex;flex-direction:column;align-items:center;justify-content:center;
  width:140px;min-height:72px;padding:10px 18px;border-radius:18px;
}
.live-public .big{font-size:1.25rem;font-weight:900;letter-spacing:.08em;color:#eefff5;line-height:1.1;text-shadow:0 0 6px rgba(255,255,255,.45),0 0 14px rgba(56,255,142,.38)}
.live-public .small{font-size:.75rem;font-weight:800;letter-spacing:.12em;margin-top:6px;color:#eefff5;text-shadow:0 0 6px rgba(255,255,255,.35),0 0 12px rgba(56,255,142,.28)}
.search-wrap{display:flex;align-items:center;border:1px solid var(--line2);border-radius:999px;background:#f3f4f6;padding:6px 12px;height:34px;min-width:220px}
.search-wrap span{color:#6b7280;margin-right:6px}
.search-wrap input{border:none;outline:none;background:transparent;color:#000;font-weight:700;width:100%}

/* Mid row */
.mid-row{display:grid;grid-template-columns:1fr 1fr;gap:14px;align-items:stretch}
.info-panel{min-height:190px;border-radius:14px;overflow:hidden;display:flex;flex-direction:column}
.info-bar{height:34px;display:flex;align-items:center;padding:0 14px;background:linear-gradient(90deg,#17398a 0%, #1f4ca8 100%);color:var(--text);font-size:.95rem;font-weight:800;border-bottom:1px solid rgba(255,255,255,.06)}
.info-body{min-height:156px;flex:1;background:linear-gradient(180deg,rgba(11,19,35,.96),rgba(8,14,24,.98));padding:16px 18px;white-space:pre-line;line-height:1.55;color:#d7e2f5}

/* Bottom row */
.bottom-row{
  display:grid;
  grid-template-columns:1.42fr .78fr;
  gap:14px;
  align-items:start;
}
.prizes-panel,
.entrants-panel{
  display:flex;
  flex-direction:column;
  min-width:0;
}
.prizes{
  padding:14px;
  display:grid;
  gap:14px;
  align-content:start;
}
.entrants-panel{
  overflow:hidden;
}
.entrants-body{
  display:flex;
  flex-direction:column;
  min-height:0;
}
.entrants-scroll{
  overflow:auto;
  padding:0 12px 16px 12px;
  max-height:1250px;
}

/* Prize cards */
.prize{
  display:grid;
  grid-template-columns:96px minmax(0,1fr);
  gap:18px;
  align-items:stretch;
  padding:14px;
  border-radius:24px;
  border:1px solid var(--line);
  background:linear-gradient(180deg,rgba(11,19,35,.96),rgba(8,14,24,.98));
  width:100%;
}
.num{
  display:flex;
  align-items:center;
  justify-content:center;
  min-height:148px;
  border-radius:20px;
  border:1px solid var(--line);
  background:linear-gradient(180deg,rgba(15,28,51,.96),rgba(8,16,29,.98));
  font-size:2.4rem;
  font-weight:900;
}
.pmid{
  display:grid;
  grid-template-rows:auto auto auto;
  gap:12px;
  min-width:0;
}
.ptitle{
  width:100%;
  min-height:54px;
  padding:12px 18px;
  border-radius:18px;
  border:1px solid var(--line);
  background:rgba(10,20,38,.88);
  display:flex;
  align-items:center;
  font-size:1.34rem;
  font-weight:850;
  line-height:1.22;
}
.pmeta{
  color:var(--muted);
  font-size:.95rem;
  padding:0 6px;
}
.pwinner{
  width:100%;
  padding:12px 18px;
  border-radius:16px;
  background:rgba(255,255,255,.03);
  border:1px solid rgba(255,255,255,.05);
  display:grid;
  gap:6px;
}
.pwinner .label{
  font-size:.8rem;
  color:var(--muted);
  text-transform:uppercase;
  letter-spacing:.08em;
  font-weight:800;
}
.pwinner .value{font-size:1rem;font-weight:700}

/* Entrants panel */
.table-headline{padding:18px 20px 8px 20px;font-size:1.15rem;font-weight:800}
.table-sub{padding:0 20px 12px 20px;color:var(--muted);font-size:.92rem}
.entrants-controls{padding:0 20px 12px 20px;display:grid;gap:10px}
.lookup-input{
  width:100%;
  padding:10px 12px;
  border-radius:10px;
  border:none;
  outline:none;
  background:#fff;
  color:#000;
  font:inherit;
}
.thead,.row{display:grid;grid-template-columns:.5fr 1.8fr .8fr;gap:10px;align-items:center}
.thead{
  padding:14px 8px 12px 8px;
  border-top:1px solid var(--line);
  color:#eef5ff;
  font-size:1rem;
  font-weight:900;
  margin:0 8px;
}
.row{
  padding:12px 8px;
  margin:0 8px;
  border-top:1px solid rgba(255,255,255,.05);
}
.row.hoverable:hover{background:var(--hover)}
.idx,.total{text-align:right;font-variant-numeric:tabular-nums}
.name{font-weight:750}
.empty-state{
  padding:16px 8px;
  margin:0 8px;
  border-top:1px solid rgba(255,255,255,.05);
  color:var(--muted);
  font-size:.95rem;
}

/* Hide old stuff we don't want */
#ticket_list,
#raffle_cost,
#barter_area,
.barter-area,
.barter-panel,
.barter-view,
.barter-section{
  display:none !important;
}

/* Mobile */
@media (max-width:1180px){
  .header-right{
    width:100%;
    margin-left:0 !important;
    display:flex !important;
    justify-content:flex-start !important;
    align-items:center !important;
    gap:14px !important;
    flex-wrap:wrap;
  }
}

@media (max-width:1100px){
  .mid-row,.bottom-row{grid-template-columns:1fr}
  .entrants-scroll{overflow:visible;max-height:none}
}

@media (max-width:700px){
  .page{padding:12px;gap:12px}
  .header{
    display:grid;
    grid-template-columns:56px 1fr;
    grid-template-areas:
      'logo title'
      'stats stats'
      'right right';
    align-items:start;
    gap:12px;
    padding:14px
  }
  .header img#mainLogo{grid-area:logo;width:56px;height:56px}
  .title-block{grid-area:title;min-width:0}
  .title-block h1{font-size:1.5rem;line-height:1.06}
  .title-block .sub{font-size:.92rem}
  .title-block .updated{font-size:.82rem}
  .stats-inline{grid-area:stats;margin-left:0;display:grid;grid-template-columns:1fr 1fr;gap:10px}
  .stat{min-width:0;padding:10px 10px}
  .stat .v{font-size:1.25rem}
  .header-right{grid-area:right !important;width:100%;display:grid !important;grid-template-columns:1fr 1fr;gap:10px !important;align-items:stretch !important}
  .header-right > div:first-child{justify-content:stretch !important}
  .live-public{width:100%;min-height:64px;border-radius:16px}
  .live-public .big{font-size:1.05rem}
  .live-public .small{font-size:.68rem;margin-top:4px}
  .search-wrap{min-width:0;width:100%;height:64px;padding:0 14px;border-radius:16px}
  .search-wrap span{font-size:1rem}
  .search-wrap input{font-size:.98rem}
  .info-bar{height:36px;font-size:.92rem}
  .info-body{padding:14px 15px;font-size:.95rem;line-height:1.5}
  .prize{grid-template-columns:62px 1fr;gap:12px;padding:10px;border-radius:18px}
  .num{min-height:98px;border-radius:14px;font-size:1.7rem}
  .ptitle{min-height:42px;padding:10px 12px;border-radius:12px;font-size:1.06rem}
  .pmeta{font-size:.88rem}
  .pwinner{padding:10px 12px;border-radius:12px}
  .pwinner .value{font-size:.95rem}
}
</style>

<script>
$(document).ready(function() {
  $.ajaxSetup({cache:false});
});

function escapeHtml(str) {
  return String(str == null ? "" : str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function buildPrizeCards(result) {
  $("#prize_info").empty();

  if (!result || !result.length) {
    $("#prize_info").append('<div class="empty-state">No prize cards yet.</div>');
    return;
  }

  $.each(result, function(index, value) {
    var winnerName = "TBD";
    if (value["prize_finalised"] != 0 && value["prize_winner_name"]) {
      winnerName = value["prize_winner_name"];
    }

    var metaText = value["prize_text2"] || "";
    var prizeText = value["prize_text"] || "";

    var card = ''
      + '<div class="prize">'
      + '  <div class="num">' + escapeHtml(metaText) + '</div>'
      + '  <div class="pmid">'
      + '    <div class="ptitle">' + escapeHtml(prizeText) + '</div>'
      + '    <div class="pmeta"></div>'
      + '    <div class="pwinner">'
      + '      <div class="label">Winner</div>'
      + '      <div class="value">' + escapeHtml(winnerName) + '</div>'
      + '    </div>'
      + '  </div>'
      + '</div>';

    $("#prize_info").append(card);
  });
}

function buildEntrantsTable(result) {
  var $all = $("#allEntrants");
  $all.empty();

  if (!result || !result.length) {
    $all.append('<div class="empty-state">No entrants yet.</div>');
    return;
  }

  var rows = [];
  for (var i = 0; i < result.length; i++) {
    var r = result[i];
    rows.push(
      '<div class="row hoverable">'
      + '<div class="idx">' + escapeHtml(r[0]) + '</div>'
      + '<div class="name">' + escapeHtml(r[1]) + '</div>'
      + '<div class="total">' + escapeHtml(r[2]) + '</div>'
      + '</div>'
    );
  }

  $all.append(rows.join(''));
}

function refresher() {
  $.getJSON("json/get/guild", function(result) {
    $("#guild_header").text(result["guild_name"]);
  });

  $.getJSON("json/get/raffle", function(result) {
    $("#raffle_subheader").text("#" + result["raffle_guild_num"] + " Raffle • Drawing: " + result["raffle_time"]);
    $("#raffle_lookup").attr("placeholder", "Enter Week #");
    $("#raffle_notes").html(result["raffle_notes"] || "Welcome to this week's raffle.");
    $("#entrants_headline").text("#" + result["raffle_guild_num"] + " Raffle Entrants");
  });

  $.getJSON("json/get/prizes", function(result) {
    buildPrizeCards(result);
  });

  $.getJSON("json/get/timestamp", function(result) {
    if (!result) return;
    var updated = DateFormat.format.date(parseInt(result) * 1000, "yyyy-MM-dd hh:mm:ss");
    $("#raffle_updated").text("Last Updated " + updated.toString());
  });

  $.getJSON("json/get/tickets", function(result) {
    $("#raffle_participants").text(result.length);

    var total = 0;
    for (var i = 0; i < result.length; i++) {
      total += result[i][2] << 0;
    }
    $("#raffle_sold").text(total.toLocaleString());

    buildEntrantsTable(result);
  });
}

$(document).ready(refresher);
$(document).ready(function () {
  window.setInterval(refresher, 30000);
});
</script>
</head>
<body>
<div class="page">

  <section class="card header">
    <img id="mainLogo" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="BBC logo">

    <div class="title-block">
      <h1 id="guild_header">Bleakrock Barter Co</h1>
      <div class="sub" id="raffle_subheader">#2613 Raffle • Drawing: Tuesday 11PM EDT</div>
      <div class="updated" id="raffle_updated">Last Updated</div>
    </div>

    <div class="stats-inline">
      <div class="stat"><div class="k">Total Tickets</div><div class="v" id="raffle_sold">0</div></div>
      <div class="stat"><div class="k">Participants</div><div class="v" id="raffle_participants">0</div></div>
    </div>

    <div class="header-right">
      <div style="display:flex;justify-content:center;">
        <div class="live-public">
          <div class="big">LIVE</div>
          <div class="small">GET TICKETS!</div>
        </div>
      </div>
      <form id="raffle_lookup_form" action="/${request.matchdict['guild']}/lookup" method="get" class="search-wrap" style="margin:0;">
        <span>🔍</span>
        <input type="text" id="raffle_lookup" name="raffle_lookup" placeholder="Enter Week #" />
      </form>
    </div>
  </section>

  <section class="mid-row">
    <div class="card info-panel">
      <div class="info-bar">Raffle Notes</div>
      <div class="info-body" id="raffle_notes">Welcome to this week's raffle.</div>
    </div>

    <div class="card info-panel">
      <div class="info-bar">Raffle Info</div>
      <div class="info-body">🎟 Ticket numbers are assigned just prior to draw and will be listed below.

🕒 Ticket Deadline: 10:30P EDT Tuesday
🎲 Winners announced: 11P EDT Tuesday
📍 Rolls in Discord #bleakrock-diceroom
📦 All prizes mailed within 7 days</div>
    </div>
  </section>

  <section class="bottom-row">
    <div class="card prizes-panel">
      <div class="prizes" id="prize_info">
        <div class="empty-state">No prize cards yet.</div>
      </div>
    </div>

    <div class="card entrants-panel">
      <div class="table-headline" id="entrants_headline">Raffle Entrants</div>
      <div class="table-sub">Tickets Lookup</div>

      <div class="entrants-controls">
        <input type="text" class="lookup-input" placeholder="Find: ex. '@name'">
      </div>

      <div class="entrants-body">
        <div class="thead">
          <div class="idx">#</div>
          <div>Name</div>
          <div class="total">Total</div>
        </div>

        <div class="entrants-scroll">
          <div id="allEntrants">
            <div class="empty-state">No entrants yet.</div>
          </div>
        </div>
      </div>
    </div>
  </section>

</div>
</body>
</html>