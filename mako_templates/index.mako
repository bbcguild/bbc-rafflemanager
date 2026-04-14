<%
initial_lookup_raffle = (request.matchdict.get('raffle') or request.params.get('raffle_lookup') or '').strip()
initial_display_raffle = initial_lookup_raffle if initial_lookup_raffle else '2613'
ga4_site_area = 'public'
ga4_raffle_view = 'archive' if initial_lookup_raffle else 'current'
ga4_raffle_number = initial_lookup_raffle
ga4_guild_slug = request.matchdict.get('guild', '')
is_staging = (request.registry.settings.get("app_env") == "staging")
stage_label = (request.registry.settings.get("app_stage_label") or "STAGING").strip()
%>
<!DOCTYPE html>
<html lang="en">
<head>
<link rel="icon" id="appFaviconIco" type="image/x-icon" href="/static/favicon.ico">
<link rel="icon" id="appFavicon32" type="image/png" sizes="32x32" href="/static/favicon-256.png">
<link rel="icon" id="appFavicon16" type="image/png" sizes="16x16" href="/static/favicon-256.png">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>${('[%s] ' % stage_label) if is_staging else ''}BBC Raffle</title>
<%include file="analytics_snippet.mako"/>

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
  --brand-primary:#284CA6;
  --brand-accent:#5078D2;
  --brand-primary-rgb:40,76,166;
  --brand-accent-rgb:80,120,210;
  --panel:#091224;
  --panel2:#07101f;
  --line:rgba(var(--brand-accent-rgb),.18);
  --line2:rgba(var(--brand-accent-rgb),.34);
  --text:#f4f7ff;
  --muted:#9fb0cf;
  --shadow:0 18px 48px rgba(0,0,0,.38);
  --hover:rgba(var(--brand-accent-rgb),.08);
  --danger:#ff6b6b;
}

*{box-sizing:border-box}
html,body{margin:0;padding:0;max-width:100%;overflow-x:hidden}
body{
  font-family:Inter,system-ui,Arial,sans-serif;
  color:var(--text);
  background:radial-gradient(circle at top left, rgba(var(--brand-primary-rgb),.18), transparent 24%),linear-gradient(180deg,#05070d 0%,#060a12 100%);
  overflow-x:hidden;
}

body.is-staging{
  box-shadow:inset 0 6px 0 #d94a4a;
}

.stage-banner{
  width:min(100%, 1180px);
  margin:14px auto 0;
  padding:10px 14px;
  border:1px solid rgba(217,74,74,.55);
  background:linear-gradient(180deg, rgba(123,21,21,.96), rgba(95,16,16,.96));
  color:#fff3f3;
  text-align:center;
  font-size:13px;
  font-weight:900;
  letter-spacing:.16em;
  text-transform:uppercase;
  box-shadow:0 12px 28px rgba(0,0,0,.28);
}

.page{
  padding:10px;
  display:grid;
  gap:14px;
  width:100%;
  max-width:100%;
}
.card{
  background:linear-gradient(180deg,var(--panel),var(--panel2));
  border:1px solid var(--line);
  border-radius:22px;
  box-shadow:var(--shadow);
  min-width:0;
}

/* Header */
.header{
  position:relative;
  display:flex;
  align-items:center;
  gap:14px;
  padding:14px 20px;
  min-width:0;
  overflow:hidden;
  background:
    linear-gradient(90deg, rgba(8,12,20,.84) 0%, rgba(8,12,20,.72) 24%, rgba(8,12,20,.34) 58%, rgba(8,12,20,.12) 100%),
    linear-gradient(180deg, rgba(18,27,44,.38), rgba(10,18,32,.48)),
    url("/static/cakes2026.png") center 48% / 95% auto no-repeat;
}
.header > *{
  position:relative;
  z-index:1;
}
.header-left{
  display:flex;
  align-items:center;
  gap:14px;
  min-width:0;
  flex:1 1 auto;
}
.header img#mainLogo{
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
  flex:1 1 240px;
}
.title-block h1{
  margin:0;
  font-size:1.95rem;
  line-height:1.04;
  font-weight:700;
  white-space:nowrap;
  overflow:hidden;
  text-overflow:ellipsis;
}
.title-block .sub{
  color:var(--muted);
  font-size:.88rem;
  white-space:nowrap;
  overflow:hidden;
  text-overflow:ellipsis;
}
.title-block .updated{
  color:#e6d77a;
  font-size:.82rem;
  white-space:nowrap;
  overflow:hidden;
  text-overflow:ellipsis;
}
.title-block .updated.closed{
  color:var(--danger);
  font-weight:800;
}
.stats-inline{
  display:flex;
  gap:8px;
  margin-left:auto;
  justify-content:flex-end;
  flex:0 1 auto;
  min-width:0;
}
.stat{
  border-radius:14px;
  padding:10px 10px;
  background:rgba(8,17,31,.86);
  border:1px solid #ffffff !important;
  text-align:center;
  min-width:92px;
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

.mobile-stats-row{
  display:none;
}

.header-right{
  display:none;
}

.mobile-search-toggle-inline,
.header-right .search-wrap{
  display:none !important;
}

.search-wrap{
  display:flex;
  align-items:center;
  border:1px solid rgba(140,170,230,.12);
  border-radius:999px;
  background:#0f1622;
  padding:6px 12px;
  height:34px;
  min-width:0;
  width:100%;
}
.search-wrap span{
  color:#8ea0bf;
  margin-right:6px;
}
.search-wrap input{
  border:none;
  outline:none;
  background:transparent;
  color:#d6deeb;
  font-weight:600;
  width:100%;
  min-width:0;
}
.search-wrap input::placeholder{
  color:#8ea0bf;
  font-weight:500;
}

.raffle-nav{
  display:flex;
  gap:8px;
  flex-wrap:nowrap;
  justify-content:flex-end;
  align-items:center;
  width:auto;
}

.archive-nav-link,
.archive-nav-disabled{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  min-height:24px;
  min-width:24px;
  padding:0 4px;
  border-radius:0;
  font-size:.98rem;
  font-weight:800;
  line-height:1;
  text-decoration:none;
}

.archive-nav-link{
  color:var(--text);
  background:rgba(255,255,255,.04);
  border:1px solid var(--line2);
}

.archive-nav-link.archive-nav-home{
  background:rgba(90,129,214,.16);
  border-color:rgba(137,176,255,.34);
}

.archive-nav-home-icon{
  width:16px;
  height:16px;
  display:block;
}

.archive-nav-home-icon path,
.archive-nav-home-icon line{
  fill:none;
  stroke:currentColor;
  stroke-width:1.9;
  stroke-linecap:round;
  stroke-linejoin:round;
}

.archive-nav-link:hover{
  background:rgba(255,255,255,.08);
}

.archive-nav-link.archive-nav-home:hover{
  background:rgba(90,129,214,.24);
}

.archive-nav-disabled{
  color:rgba(244,247,255,.45);
  background:rgba(255,255,255,.02);
  border:1px solid rgba(255,255,255,.08);
  cursor:default;
}

.archive-nav-label{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  min-height:24px;
  padding:0 8px;
  border:1px solid rgba(255,255,255,.12);
  background:rgba(255,255,255,.05);
  color:var(--text);
  font-size:.72rem;
  font-weight:800;
  letter-spacing:.08em;
  text-transform:uppercase;
  white-space:nowrap;
}

.info-bar.with-archives{
  justify-content:space-between;
  gap:12px;
}

.info-bar-title{
  min-width:0;
}

.barter-list-button{
  display:none;
  align-items:center;
  justify-content:center;
  min-height:24px;
  padding:0 10px;
  border:1px solid rgba(255,255,255,.18);
  background:rgba(255,255,255,.08);
  color:var(--text);
  font-size:.72rem;
  font-weight:800;
  letter-spacing:.06em;
  text-transform:uppercase;
  white-space:nowrap;
  cursor:pointer;
}

.barter-list-button.is-visible{
  display:inline-flex;
}

.barter-list-button:hover{
  background:rgba(255,255,255,.14);
}

.barter-list-modal{
  position:fixed;
  inset:0;
  display:none;
  align-items:center;
  justify-content:center;
  padding:24px;
  background:rgba(4,8,15,.72);
  z-index:1200;
}

.barter-list-modal.is-open{
  display:flex;
}

.barter-list-dialog{
  width:min(920px, 100%);
  max-height:min(80vh, 820px);
  overflow:auto;
  background:linear-gradient(180deg,var(--panel),var(--panel2));
  border:1px solid var(--line2);
  box-shadow:var(--shadow);
  padding:18px 18px 20px;
}

.barter-list-dialog-header{
  display:flex;
  align-items:flex-start;
  justify-content:space-between;
  gap:12px;
  margin-bottom:14px;
}

.barter-list-dialog-title{
  margin:0;
  font-size:1.1rem;
  font-weight:900;
  letter-spacing:.04em;
  text-transform:uppercase;
}

.barter-list-dialog-subtitle{
  margin:6px 0 0;
  color:var(--muted);
  font-size:.9rem;
}

.barter-list-close{
  border:1px solid rgba(255,255,255,.18);
  background:rgba(255,255,255,.08);
  color:var(--text);
  font-weight:800;
  padding:8px 12px;
  cursor:pointer;
}

.barter-list-table{
  width:100%;
  border-collapse:collapse;
}

.barter-list-table th,
.barter-list-table td{
  padding:10px 12px;
  border-bottom:1px solid rgba(255,255,255,.08);
  text-align:left;
}

.barter-list-table th{
  color:var(--muted);
  font-size:.78rem;
  letter-spacing:.08em;
  text-transform:uppercase;
}

.barter-list-empty{
  padding:20px 12px;
  color:var(--muted);
}

/* Mid row */
.mid-row{
  display:grid;
  grid-template-columns:1fr 1fr;
  gap:14px;
  align-items:stretch;
}
.info-panel{
  min-height:140px;
  border-radius:14px;
  overflow:hidden;
  display:flex;
  flex-direction:column;
  min-width:0;
}
.info-bar{
  height:34px;
  display:flex;
  align-items:center;
  padding:0 14px;
  background:linear-gradient(90deg,#17398a 0%, #1f4ca8 100%);
  color:var(--text);
  font-size:.95rem;
  font-weight:800;
  border-bottom:1px solid rgba(255,255,255,.06);
}
.raffle-live-header{
  display:flex;
  justify-content:flex-start;
  gap:10px;
}
.raffle-live-title{
  min-width:0;
  display:flex;
  align-items:center;
  justify-content:flex-start;
  gap:10px;
  flex:1 1 auto;
  margin-right:auto;
}
#raffle_titlebar{
  min-width:0;
  display:flex;
  align-items:center;
  justify-content:flex-start;
  text-align:left;
  flex:0 1 auto;
}
.raffle-live-header .barter-list-button{
  margin-left:auto;
  flex:0 0 auto;
}
.raffle-live-header.status-live .live-dot{
  background:#36ff8e;
  box-shadow:0 0 8px rgba(54,255,142,.8);
}
.raffle-live-header.status-live #raffle_titlebar{
  color:#eafff3;
}
.raffle-live-header.status-live .raffle-status-text{
  text-shadow:0 0 6px rgba(54,255,142,.45), 0 0 14px rgba(54,255,142,.28);
}
.raffle-live-header.status-rolling .live-dot{
  display:none;
}
.raffle-live-header.status-rolling .status-dice{
  display:inline-flex;
  color:#c97a1f;
  text-shadow:0 0 6px rgba(201,122,31,.48), 0 0 14px rgba(201,122,31,.3);
}
.raffle-live-header.status-rolling #raffle_titlebar{
  color:#ffe2b3;
}
.raffle-live-header.status-rolling .raffle-status-text{
  text-shadow:0 0 6px rgba(201,122,31,.48), 0 0 14px rgba(201,122,31,.3);
}
.raffle-live-header.status-closed .live-dot{
  background:#c97a1f;
  box-shadow:0 0 8px rgba(201,122,31,.85);
}
.raffle-live-header.status-complete .live-dot{
  background:#ff0000;
  box-shadow:0 0 8px rgba(255,0,0,.82);
}
.raffle-live-header.status-complete #raffle_titlebar{
  color:#ffd6d6;
}
.raffle-live-header.status-complete .raffle-status-text{
  text-shadow:0 0 6px rgba(255,0,0,.45), 0 0 14px rgba(255,0,0,.26);
}
.live-dot{
  width:10px;
  height:10px;
  border-radius:50%;
  background:#36ff8e;
  box-shadow:0 0 8px rgba(54,255,142,.8);
  flex:0 0 auto;
}
.status-dice{
  display:none;
  align-items:center;
  justify-content:center;
  font-size:1rem;
  line-height:1;
  flex:0 0 auto;
}
.live-label{
  font-weight:900;
  letter-spacing:.08em;
  font-size:.82rem;
  color:#eafff3;
  line-height:1;
  flex:0 0 auto;
}
.raffle-name-label{
  font-weight:800;
  font-size:.95rem;
  line-height:1;
  flex:0 1 auto;
  white-space:nowrap;
  overflow:hidden;
  text-overflow:ellipsis;
}
.raffle-status-text{
  font-weight:900;
}
.raffle-title-sep{
  opacity:.78;
  margin:0 .22em;
}
.info-body{
  min-height:106px;
  flex:1;
  background:linear-gradient(180deg,rgba(11,19,35,.96),rgba(8,14,24,.98));
  padding:16px 18px;
  white-space:pre-line;
  line-height:1.55;
  color:#d7e2f5;
}
.rich-notes{
  white-space:normal;
}
.rich-notes.pending-note{
  visibility:hidden;
}
.rich-notes p:first-child{
  margin-top:0;
}
.rich-notes p:last-child{
  margin-bottom:0;
}
.rich-notes ul,
.rich-notes ol{
  margin:0;
  padding-left:1.4em;
}
.rich-notes a{
  color:#85bbff;
}

/* Bottom row */
.bottom-row{
  display:grid;
  grid-template-columns:minmax(0,1fr) minmax(0,1fr);
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
  padding:0 16px 16px 10px;
  max-height:2200px;
  margin-right:20px;
}

/* Prize cards */
.prize{
  display:grid;
  grid-template-columns:84px minmax(0,1fr);
  gap:14px;
  align-items:stretch;
  padding:12px;
  border-radius:0;
  border:1px solid var(--line);
  background:linear-gradient(180deg,rgba(11,19,35,.96),rgba(8,14,24,.98));
  width:100%;
  position:relative;
  overflow:hidden;
  box-shadow:inset 0 0 0 1px rgba(80,120,210,.16);
}
.prize::before{
  content:"";
  position:absolute;
  inset:0 auto 0 0;
  width:4px;
  background:transparent;
  pointer-events:none;
}
.prize.prize-style-featured{
  border-width:1px;
  border-color:rgba(125,148,192,.26);
  box-shadow:inset 0 0 0 1px rgba(125,148,192,.16), inset 0 3px 0 rgba(130,205,255,.26);
}
.prize.prize-style-featured::before{
  background:linear-gradient(180deg,rgba(130,205,255,.82),rgba(130,205,255,.18));
}
.prize.prize-style-grand{
  border-width:1px;
  border-color:rgba(205,166,92,.34);
  box-shadow:inset 0 0 0 1px rgba(205,166,92,.18), inset 0 4px 0 rgba(223,186,97,.44), 0 6px 18px rgba(0,0,0,.14);
}
.prize.prize-style-grand::before{
  background:linear-gradient(180deg,rgba(223,186,97,.9),rgba(223,186,97,.18));
}
.prize.prize-style-jackpot{
  border-width:1px;
  border-color:rgba(193,227,255,.52);
  background:
    radial-gradient(circle at 88% 24%, rgba(154,211,255,.14), transparent 22%),
    radial-gradient(circle at right center, rgba(154,211,255,.085), transparent 30%),
    linear-gradient(270deg, rgba(154,211,255,.055), rgba(154,211,255,.02) 16%, transparent 40%),
    linear-gradient(180deg,rgba(12,26,45,.98),rgba(7,14,28,.99));
  box-shadow:inset 0 0 0 1px rgba(193,227,255,.16), 0 16px 34px rgba(0,0,0,.28), inset 0 0 22px rgba(122,204,255,.05);
}
.prize.prize-style-jackpot::before{
  width:6px;
  background:linear-gradient(180deg,rgba(245,248,255,.95),rgba(130,205,255,.25));
}
.num{
  display:flex;
  align-items:center;
  justify-content:center;
  min-height:138px;
  border-radius:0;
  border:1px solid var(--line);
  background:linear-gradient(180deg,rgba(15,28,51,.96),rgba(8,16,29,.98));
  font-size:2.15rem;
  font-weight:900;
}
.pmid{
  display:grid;
  grid-template-rows:auto auto auto;
  gap:10px;
  min-width:0;
}
.pbadge{
  display:none;
  align-items:center;
  min-height:24px;
  width:max-content;
  max-width:100%;
  padding:0 10px;
  border:1px solid rgba(141,167,215,.18);
  background:rgba(255,255,255,.04);
  color:#b8c8e7;
  font-size:.68rem;
  font-weight:900;
  letter-spacing:.12em;
  text-transform:uppercase;
  white-space:nowrap;
}
.prize.prize-style-featured .pbadge,
.prize.prize-style-grand .pbadge,
.prize.prize-style-jackpot .pbadge{
  display:inline-flex;
}
.prize.prize-style-featured .pbadge{
  border-color:rgba(130,205,255,.24);
  background:rgba(39,102,174,.09);
  color:#cae6ff;
}
.prize.prize-style-grand .pbadge{
  border-color:rgba(223,186,97,.3);
  background:rgba(188,142,47,.1);
  color:#f1deb0;
}
.prize.prize-style-jackpot .pbadge{
  border-color:rgba(216,236,255,.44);
  background:rgba(86,145,208,.14);
  color:#f1f7ff;
  box-shadow:0 0 16px rgba(122,204,255,.12);
}
.ptitle{
  width:100%;
  min-height:50px;
  padding:10px 14px;
  border-radius:0;
  border:1px solid var(--line);
  background:rgba(10,20,38,.88);
  display:flex;
  align-items:center;
  font-size:1.2rem;
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
    display:grid;
    grid-template-columns:minmax(96px,.78fr) minmax(0,1.3fr) minmax(118px,.9fr);
    gap:10px;
    align-items:start;
  }
  .winner-cell{
    min-width:0;
    display:grid;
    gap:6px;
    padding:10px 14px;
    border-radius:0;
    background:rgba(255,255,255,.03);
    border:1px solid rgba(255,255,255,.05);
  }
  .pwinner .label{
    font-size:.8rem;
    color:var(--muted);
    text-transform:uppercase;
    letter-spacing:.08em;
    font-weight:800;
    white-space:nowrap;
  }
  .pwinner .value{
    font-size:.95rem;
    font-weight:700;
    min-width:0;
    white-space:nowrap;
    overflow:hidden;
    text-overflow:ellipsis;
  }

/* Entrants panel */
.table-headline{
  padding:18px 20px 8px 20px;
  font-size:1.08rem;
  font-weight:800;
}
.table-sub{
  padding:0 20px 12px 20px;
  color:var(--muted);
  font-size:.92rem;
}
.entrants-controls{
  padding:0 20px 12px 20px;
  display:grid;
  gap:10px;
}
.lookup-input{
  width:100%;
  padding:10px 12px;
  border-radius:10px;
  border:1px solid rgba(140,170,230,.12);
  outline:none;
  background:#0f1622;
  color:#d6deeb;
  font:inherit;
}
.lookup-input::placeholder{
  color:#8ea0bf;
}
.thead,.row{
  display:grid;
  grid-template-columns:minmax(28px,.28fr) minmax(0,2.15fr) minmax(64px,.58fr);
  gap:8px;
  align-items:center;
}
.thead.mode-range,
.row.mode-range{
  grid-template-columns:minmax(28px,.24fr) minmax(0,2.2fr) minmax(62px,.5fr) minmax(104px,.72fr);
}
.thead.mode-barter,
.row.mode-barter{
  grid-template-columns:minmax(28px,.22fr) minmax(0,1.72fr) minmax(58px,.42fr) minmax(58px,.42fr) minmax(52px,.34fr);
}
.thead.mode-barter-range,
.row.mode-barter-range{
  grid-template-columns:minmax(28px,.2fr) minmax(0,1.72fr) minmax(54px,.36fr) minmax(54px,.36fr) minmax(46px,.28fr) minmax(96px,.58fr);
}
.thead{
  padding:12px 8px 10px 8px;
  border-top:1px solid var(--line);
  color:#eef5ff;
  font-size:.94rem;
  font-weight:900;
  margin:0 42px 0 8px;
}
.row{
  padding:10px 8px;
  margin:0 8px;
  border-top:1px solid rgba(255,255,255,.05);
  font-size:.95rem;
}
.thead.mode-barter,
.thead.mode-barter-range{
  font-size:.84rem;
}
.sort-header{
  display:inline-flex;
  align-items:center;
  gap:6px;
  cursor:pointer;
  user-select:none;
}
.sort-header .sort-label{
  min-width:0;
}
.sort-header .sort-indicator{
  font-size:.8em;
  line-height:1;
  opacity:.92;
}
.sort-header.is-active{
  color:#f6fbff;
}
.row.mode-barter,
.row.mode-barter-range{
  font-size:.88rem;
}
.row.hoverable:hover{background:var(--hover)}
.idx,.total,.paid,.bar,.range{
  text-align:right;
  font-variant-numeric:tabular-nums;
  justify-self:end;
}
.thead .idx,
.thead .total,
.thead .paid,
.thead .bar,
.thead .range{
  text-align:center;
  justify-self:center;
}
.row .total{
  color:#e6d77a;
}
.row .emphasis-cell{
  font-weight:750;
}
.range{
  white-space:nowrap;
}
.name{
  min-width:0;
  white-space:nowrap;
  overflow:hidden;
  text-overflow:ellipsis;
}
.row.mode-standard .name,
.row.mode-range .name,
.thead.mode-standard .name,
.thead.mode-range .name{
  text-overflow:clip;
}
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
    display:none !important;
  }
}

@media (max-width:1100px){
  .mid-row,.bottom-row{grid-template-columns:1fr}
  .entrants-scroll{overflow:visible;max-height:none}
  .thead{margin:0 56px 0 8px}
  .title-block{
    min-width:260px;
  }
}

@media (max-width:980px){
  .header-left{
    width:100%;
    flex-wrap:wrap;
  }
}

@media (max-width:700px){
  .page{
    padding:12px;
    gap:12px;
  }

  .header{
    position:relative;
    padding:14px;
  }

  .header-left{
    display:grid;
    grid-template-columns:56px minmax(0,1fr);
    align-items:start;
    gap:12px;
    width:100%;
  }

  .header img#mainLogo{
    width:56px;
    height:56px;
  }

  .title-block{
    min-width:0;
    padding-right:0;
  }

  .title-block h1{
    font-size:1.5rem;
    line-height:1.06;
    margin:0;
    white-space:normal;
    overflow:visible;
    text-overflow:unset;
  }

  .title-block .sub{
    font-size:.92rem;
  }

  #raffle_subheader{
    display:block;
    line-height:1.2;
    white-space:normal;
    overflow:visible;
    text-overflow:unset;
  }

  .title-block .updated{
    font-size:.82rem;
    white-space:normal;
    overflow:visible;
    text-overflow:unset;
  }

  .mobile-subline{
    display:block;
    min-width:0;
  }

  .stats-inline{
    display:none !important;
  }

  .mobile-stats-row{
    display:grid;
    grid-template-columns:minmax(0,1fr) minmax(0,1fr);
    gap:10px;
  }

  .mobile-stats-row .stat{
    min-width:0;
    width:100%;
    padding:10px 10px;
  }

  .mobile-stats-row .stat .v{
    font-size:1.25rem;
  }

  .header-right{
    display:none !important;
  }

  .raffle-nav{
    justify-content:flex-end;
    gap:6px;
  }

  .archive-nav-link,
  .archive-nav-disabled{
    min-height:22px;
    min-width:22px;
    font-size:.92rem;
  }

  .archive-nav-label{
    min-height:22px;
    padding:0 7px;
    font-size:.68rem;
  }

  .info-bar{height:36px;font-size:.92rem}
  .raffle-live-header{gap:8px}
  .raffle-name-label{font-size:.88rem}
  .info-body{padding:14px 15px;font-size:.95rem;line-height:1.5}
  .prize{grid-template-columns:62px 1fr;gap:12px;padding:10px;border-radius:0}
  .num{min-height:98px;border-radius:0;font-size:1.7rem}
  .ptitle{min-height:42px;padding:10px 12px;border-radius:0;font-size:1.06rem}
  .pmeta{font-size:.88rem}
  .pwinner{
    grid-template-columns:minmax(92px,.9fr) minmax(0,1.3fr) minmax(116px,1fr);
    gap:10px;
  }
  .winner-cell{padding:10px 12px;border-radius:0}
  .pwinner .value{font-size:.95rem}
}
</style>

<script>
const guildSlug = "${request.matchdict['guild']}";
const initialRequestedRaffleNum = "${initial_lookup_raffle}";
const liveRaffleEndpoint = "/" + guildSlug + "/json/get/raffle";
const publicExtendedTicketsEnabled = true;

let allEntrantsData = [];
let currentDisplayedRaffleNum = initialRequestedRaffleNum || null;
let liveCurrentRaffleNum = null;
let currentRaffleStatus = "LIVE";
let currentEntrantsMode = "standard";
let currentEntrantsSort = null;

$(document).ready(function() {
  $.ajaxSetup({cache:false});

  $(document).on('input', '.lookup-input', function() {
    applyEntrantFilter();
  });

  $(document).on('click', '#entrantsHead .sort-header', function() {
    var key = $(this).data('key');
    toggleEntrantsSort(key);
  });

});

function escapeHtml(str) {
  return String(str == null ? "" : str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function shouldShowPublicTicketRanges(status) {
  var normalizedStatus = normalizeRaffleStatus(status);
  return normalizedStatus === "ROLLING" || normalizedStatus === "COMPLETE" || isArchiveDisplay();
}

function shouldUseBarterMode(rows) {
  if (!Array.isArray(rows)) {
    return false;
  }

  return rows.some(function(row) {
    return row && Number(row[4]) > 0;
  });
}

function addTicketRanges(rows) {
  var runningStart = 1;
  return rows.map(function(row) {
    if (!row) return row;

    var rangeText = row.length > 5 ? (row[5] || "") : "";
    if (!rangeText) {
      var total = Number(row[2]) || 0;
      if (total > 0) {
        var runningEnd = runningStart + total - 1;
        rangeText = String(runningStart) + "-" + String(runningEnd);
        runningStart = runningEnd + 1;
      }
    }

    var nextRow = row.slice();
    nextRow.push(rangeText);
    return nextRow;
  });
}

function getEntrantsColumns() {
  var columns = [
    { key: "idx", label: "#", className: "idx", value: function(row) { return row[0]; } },
    { key: "name", label: "Name", className: "name", value: function(row) { return row[1]; } },
    { key: "total", label: "Total", className: "total", value: function(row) { return row[2]; } }
  ];

  if (currentEntrantsMode === "barter" || currentEntrantsMode === "barter-range") {
    columns.push(
      { key: "paid", label: "Paid", className: "paid", value: function(row) { return row[3] || 0; } },
      { key: "bar", label: "Bar", className: "bar", value: function(row) { return row[4] || 0; } }
    );
  }

  if (currentEntrantsMode === "range" || currentEntrantsMode === "barter-range") {
    columns.push({
      key: "range",
      label: "Range",
      className: "range",
      value: function(row) {
        if (!Array.isArray(row) || row.length === 0) {
          return "";
        }
        return row[row.length - 1] || "";
      }
    });
  }

  return columns;
}

function determineEntrantsMode(rows) {
  var barterMode = shouldUseBarterMode(rows);
  var showRanges = shouldShowPublicTicketRanges(currentRaffleStatus);

  if (barterMode && showRanges) return "barter-range";
  if (barterMode) return "barter";
  if (showRanges) return "range";
  return "standard";
}

function renderEntrantsHeader() {
  var $head = $("#entrantsHead");
  if (!$head.length) return;

  var columns = getEntrantsColumns();
  var headClass = "thead mode-" + currentEntrantsMode;

  var html = '';
  columns.forEach(function(column) {
    var indicator = '';
    var activeClass = '';
    if (currentEntrantsSort && currentEntrantsSort.key === column.key) {
      activeClass = ' is-active';
      indicator = currentEntrantsSort.direction === 'asc'
        ? '<span class="sort-indicator" aria-hidden="true">↑</span>'
        : '<span class="sort-indicator" aria-hidden="true">↓</span>';
    }

    html += '<div class="' + column.className + ' sort-header' + activeClass + '" data-key="' + escapeHtml(column.key) + '" role="button" tabindex="0">'
      + '<span class="sort-label">' + escapeHtml(column.label) + '</span>'
      + indicator
      + '</div>';
  });

  $head.attr("class", headClass).html(html);
}

function getRangeSortValue(row) {
  if (!Array.isArray(row) || row.length < 6) {
    return Number.MAX_SAFE_INTEGER;
  }

  var rangeText = String(row[5] || "").trim();
  var firstPart = rangeText.split(",")[0].trim();
  var match = firstPart.match(/^(\d+)/);
  return match ? parseInt(match[1], 10) : Number.MAX_SAFE_INTEGER;
}

function getEntrantSortValue(row, key) {
  if (!Array.isArray(row)) {
    return null;
  }

  if (key === "idx") return Number(row[0]) || 0;
  if (key === "name") return String(row[1] || "").toLowerCase();
  if (key === "total") return Number(row[2]) || 0;
  if (key === "paid") return Number(row[3]) || 0;
  if (key === "bar") return Number(row[4]) || 0;
  if (key === "range") return getRangeSortValue(row);
  return null;
}

function sortEntrantRows(rows) {
  var list = Array.isArray(rows) ? rows.slice() : [];
  if (!currentEntrantsSort || !currentEntrantsSort.key || !currentEntrantsSort.direction) {
    return list;
  }

  var direction = currentEntrantsSort.direction === "desc" ? -1 : 1;
  var sortKey = currentEntrantsSort.key;

  return list.sort(function(a, b) {
    var aValue = getEntrantSortValue(a, sortKey);
    var bValue = getEntrantSortValue(b, sortKey);
    var primary = 0;

    if (typeof aValue === "string" || typeof bValue === "string") {
      primary = String(aValue || "").localeCompare(String(bValue || ""), undefined, { sensitivity: "base" });
    } else {
      primary = (Number(aValue) || 0) - (Number(bValue) || 0);
    }

    if (primary !== 0) {
      return primary * direction;
    }

    return (Number(a[0]) || 0) - (Number(b[0]) || 0);
  });
}

function toggleEntrantsSort(key) {
  if (!key) {
    return;
  }

  var firstDirection = (key === "total" || key === "paid" || key === "bar") ? "desc" : "asc";
  var secondDirection = firstDirection === "desc" ? "asc" : "desc";

  if (!currentEntrantsSort || currentEntrantsSort.key !== key) {
    currentEntrantsSort = { key: key, direction: firstDirection };
  } else if (currentEntrantsSort.direction === firstDirection) {
    currentEntrantsSort = { key: key, direction: secondDirection };
  } else {
    currentEntrantsSort = { key: "idx", direction: "asc" };
  }

  renderEntrantsHeader();
  applyEntrantFilter();
}

function getEntrantsEmphasisKey() {
  if (!currentEntrantsSort || !currentEntrantsSort.key) {
    return "name";
  }

  return (currentEntrantsSort.key === "idx" || currentEntrantsSort.key === "name")
    ? "name"
    : currentEntrantsSort.key;
}

function normalizeEntrantSearch(value) {
  return String(value == null ? "" : value)
    .toLowerCase()
    .trim()
    .replace(/^@+/, "");
}

function entrantRowContainsTicketNumber(row, ticketNumber) {
  if (!Array.isArray(row) || row.length < 6) {
    return false;
  }

  var rangeText = String(row[5] || "").trim();
  if (!rangeText) {
    return false;
  }

  return rangeText.split(",").some(function(part) {
    var piece = String(part || "").trim();
    if (!piece) {
      return false;
    }

    var match = piece.match(/^(\d+)(?:-(\d+))?$/);
    if (!match) {
      return false;
    }

    var start = parseInt(match[1], 10);
    var end = match[2] ? parseInt(match[2], 10) : start;
    return start <= ticketNumber && ticketNumber <= end;
  });
}

function parseRaffleNum(raffleNum) {
  var cleaned = String(raffleNum == null ? "" : raffleNum).replace(/\D/g, "");
  if (!/^\d{4}$/.test(cleaned)) return null;

  return {
    raw: cleaned,
    year: parseInt(cleaned.slice(0, 2), 10),
    week: parseInt(cleaned.slice(2), 10)
  };
}

function formatRaffleNum(year, week) {
  return String(year).padStart(2, '0') + String(week).padStart(2, '0');
}

function getPrevRaffleNum(raffleNum) {
  var parsed = parseRaffleNum(raffleNum);
  if (!parsed) return null;

  var year = parsed.year;
  var week = parsed.week - 1;

  if (week < 1) {
    year = year - 1;
    if (year < 0) year = 99;
    week = 52;
  }

  return formatRaffleNum(year, week);
}

function getNextRaffleNum(raffleNum) {
  var parsed = parseRaffleNum(raffleNum);
  if (!parsed) return null;

  var year = parsed.year;
  var week = parsed.week + 1;

  if (week > 52) {
    year = year + 1;
    if (year > 99) year = 0;
    week = 1;
  }

  return formatRaffleNum(year, week);
}

function raffleLookupHref(raffleNum) {
  return "/" + guildSlug + "/lookup?raffle_lookup=" + encodeURIComponent(raffleNum);
}

function isArchiveDisplay() {
  return !!(liveCurrentRaffleNum && currentDisplayedRaffleNum && liveCurrentRaffleNum !== currentDisplayedRaffleNum);
}

function normalizeRaffleStatus(status) {
  var value = (status || "LIVE").toString().trim().toUpperCase();
  if (value === "CLOSED") {
    return "COMPLETE";
  }
  if (value !== "LIVE" && value !== "ROLLING" && value !== "COMPLETE") {
    return "LIVE";
  }
  return value;
}

function escapeHtml(value) {
  return $("<div>").text(value == null ? "" : String(value)).html();
}

function applyPublicStatus(status, title) {
  var normalizedStatus = normalizeRaffleStatus(status);
  currentRaffleStatus = normalizedStatus;
  var $header = $(".raffle-live-header");

  $header.removeClass("status-live status-rolling status-complete");
  $header.addClass("status-" + normalizedStatus.toLowerCase());
  $("#raffle_titlebar").html(
    '<span class="raffle-status-text">' + escapeHtml(normalizedStatus) + '</span>' +
    '<span class="raffle-title-sep">-</span>' +
    '<span class="raffle-name-text">' + escapeHtml(title || "Raffle") + '</span>'
  );
}

function updateRaffleNav() {
  var $nav = $("#raffle_nav_primary");
  if (!$nav.length) return;

  $nav.empty();

  if (!currentDisplayedRaffleNum) {
    return;
  }

  var prevNum = getPrevRaffleNum(currentDisplayedRaffleNum);
  var nextNum = getNextRaffleNum(currentDisplayedRaffleNum);

  if (prevNum) {
    $nav.append(
      '<a class="archive-nav-link" href="' +
      raffleLookupHref(prevNum) +
      '" aria-label="Previous archive">⏪</a>'
    );
  } else {
    $nav.append('<span class="archive-nav-disabled" aria-hidden="true">⏪</span>');
  }

  $nav.append('<span class="archive-nav-label">Archives</span>');

  if (nextNum && isArchiveDisplay()) {
    $nav.append(
      '<a class="archive-nav-link" href="' +
      raffleLookupHref(nextNum) +
      '" aria-label="Next archive">⏩</a>'
    );
  } else {
    $nav.append('<span class="archive-nav-disabled" aria-hidden="true">⏩</span>');
  }
}

function normalizeEasternTimeLabel(value) {
  var text = (value || "").toString().trim();
  if (!text) return "";

  var easternShort = new Intl.DateTimeFormat("en-US", {
    timeZone: "America/New_York",
    timeZoneName: "short"
  }).formatToParts(new Date()).find(function(part) {
    return part.type === "timeZoneName";
  });

  var currentEastern = easternShort ? easternShort.value : "ET";
  return text.replace(/\bEDT\b|\bEST\b/g, currentEastern);
}

function buildRaffleHeaderParts(raffleNumber, raffleTitle, raffleTime) {
  var numberText = String(raffleNumber || "").trim();
  var titleText = String(raffleTitle || "").trim();
  var timeText = normalizeEasternTimeLabel(raffleTime);
  var headingText = "";
  var trailingText = "";

  if (titleText) {
    headingText = "#" + numberText;
    trailingText = titleText + (timeText ? " • " + timeText : "");
  } else {
    headingText = "#" + numberText + " Raffle";
    trailingText = timeText ? "Drawing: " + timeText : "";
  }

  return {
    heading: headingText,
    trailing: trailingText,
    separator: (headingText && trailingText) ? " • " : ""
  };
}

function applyGuildBranding(result) {
  var logoUrl = (result && result["guild_logo_url"]) ? String(result["guild_logo_url"]).trim() : "";
  var faviconUrl = (result && result["guild_favicon_url"]) ? String(result["guild_favicon_url"]).trim() : "/static/favicon-256.png";
  var primaryColor = normalizeBrandColor(result && result["guild_primary_color"], "#284CA6");
  var accentColor = normalizeBrandColor(result && result["guild_accent_color"], "#5078D2");
  if (logoUrl) {
    $("#mainLogo").attr("src", logoUrl);
  }
  updateAppFavicons(faviconUrl);
  applyBrandColors(primaryColor, accentColor);
}

function normalizeBrandColor(value, fallback) {
  var raw = (value || "").toString().trim();
  if (!raw) return fallback;
  if (raw.charAt(0) !== "#") raw = "#" + raw;
  if (!/^#[0-9a-fA-F]{6}$/.test(raw)) return fallback;
  return raw.toUpperCase();
}

function hexToRgbList(hexValue) {
  var hex = normalizeBrandColor(hexValue, "#000000").slice(1);
  return [
    parseInt(hex.slice(0, 2), 16),
    parseInt(hex.slice(2, 4), 16),
    parseInt(hex.slice(4, 6), 16)
  ].join(",");
}

function applyBrandColors(primaryColor, accentColor) {
  var root = document.documentElement;
  var normalizedPrimary = normalizeBrandColor(primaryColor, "#284CA6");
  var normalizedAccent = normalizeBrandColor(accentColor, "#5078D2");
  root.style.setProperty("--brand-primary", normalizedPrimary);
  root.style.setProperty("--brand-accent", normalizedAccent);
  root.style.setProperty("--brand-primary-rgb", hexToRgbList(normalizedPrimary));
  root.style.setProperty("--brand-accent-rgb", hexToRgbList(normalizedAccent));
}

function updateAppFavicons(faviconUrl) {
  $("#appFaviconIco").attr("href", faviconUrl);
  $("#appFavicon32").attr("href", faviconUrl);
  $("#appFavicon16").attr("href", faviconUrl);
}

function updateRaffleStatusLine(updateInfo) {
  var $updated = $("#raffle_updated");

  if (isArchiveDisplay()) {
    $updated.text("Raffle Closed").addClass("closed");
    return;
  }

  $updated.removeClass("closed");

  if (!updateInfo || !updateInfo.timestamp) {
    $updated.text("");
    return;
  }

  var timestamp = parseInt(updateInfo.timestamp, 10);
  if (isNaN(timestamp)) {
    $updated.text("");
    return;
  }

  var updated = new Date(timestamp * 1000);
  var parts = new Intl.DateTimeFormat("en-US", {
    timeZone: "America/New_York",
    month: "2-digit",
    day: "2-digit",
    year: "2-digit",
    hour: "numeric",
    minute: "2-digit",
    second: "2-digit",
    hour12: true,
    timeZoneName: "short"
  }).formatToParts(updated);

  var formatted = {
    month: "",
    day: "",
    year: "",
    hour: "",
    minute: "",
    second: "",
    dayPeriod: "",
    timeZoneName: ""
  };

  parts.forEach(function(part) {
    if (formatted.hasOwnProperty(part.type)) {
      formatted[part.type] = part.value;
    }
  });

  var rendered = formatted.month + "-" + formatted.day + "-" + formatted.year
    + " " + formatted.hour + ":" + formatted.minute + ":" + formatted.second
    + " " + formatted.dayPeriod + " " + formatted.timeZoneName;

  var updatedBy = $.trim(String(updateInfo.updated_by || ""));
  $updated.text(updatedBy ? ("Last Updated " + rendered + " by " + updatedBy) : ("Last Updated " + rendered));
}

function updateRaffleNav() {
  var $nav = $("#raffle_nav_primary");
  if (!$nav.length) return;

  $nav.empty();

  if (!currentDisplayedRaffleNum) {
    return;
  }

  var prevNum = getPrevRaffleNum(currentDisplayedRaffleNum);
  var nextNum = getNextRaffleNum(currentDisplayedRaffleNum);
  var showHome = !!(liveCurrentRaffleNum && currentDisplayedRaffleNum && liveCurrentRaffleNum !== currentDisplayedRaffleNum);

  if (prevNum) {
    $nav.append(
      '<a class="archive-nav-link" href="' +
      raffleLookupHref(prevNum) +
      '" aria-label="Previous archive">&#9194;</a>'
    );
  } else {
    $nav.append('<span class="archive-nav-disabled" aria-hidden="true">&#9194;</span>');
  }

  if (showHome) {
    $nav.append(
      '<a class="archive-nav-link archive-nav-home" href="' +
      raffleLookupHref(liveCurrentRaffleNum) +
      '" aria-label="Return to current raffle">' +
      '<svg class="archive-nav-home-icon" viewBox="0 0 24 24" aria-hidden="true">' +
      '<path d="M4.5 10.5 12 4l7.5 6.5"></path>' +
      '<path d="M6.5 9.75V19h11V9.75"></path>' +
      '<path d="M14.75 5.9V3.8h2.1v3.9"></path>' +
      '<path d="M10 19v-4.6h4V19"></path>' +
      '</svg></a>'
    );
  }

  $nav.append('<span class="archive-nav-label">Archives</span>');

  if (nextNum && showHome) {
    $nav.append(
      '<a class="archive-nav-link" href="' +
      raffleLookupHref(nextNum) +
      '" aria-label="Next archive">&#9193;</a>'
    );
  } else {
    $nav.append('<span class="archive-nav-disabled" aria-hidden="true">&#9193;</span>');
  }
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
    var prizeText = value["prize_text_display"] || value["prize_text"] || "Prize Details Soon";
    var ticketText = "TBD";
    var prizeStyle = (value["prize_style"] || "standard").toLowerCase();
    if (prizeStyle === "flagship" || prizeStyle === "premier") {
      prizeStyle = "jackpot";
    } else if (prizeStyle === "signature") {
      prizeStyle = "grand";
    }
    if (["standard", "featured", "grand", "jackpot"].indexOf(prizeStyle) === -1) {
      prizeStyle = "standard";
    }
    var badgeText = "";
    if (prizeStyle === "jackpot") {
      badgeText = "Jackpot";
    } else if (prizeStyle === "grand") {
      badgeText = "Grand Prize";
    } else if (prizeStyle === "featured") {
      badgeText = "Featured";
    }
    if (value["prize_finalised"] != 0) {
      ticketText = value["prize_winner"] || "TBD";
    }
    if (String(ticketText) === "0") {
      ticketText = "TBD";
    }
    var prizeValueText = value["prize_value_display"] || "";

    var card = ''
      + '<div class="prize prize-style-' + prizeStyle + '">'
      + '  <div class="num">' + escapeHtml(metaText) + '</div>'
      + '  <div class="pmid">'
      + '    <div class="pbadge">' + escapeHtml(badgeText) + '</div>'
      + '    <div class="ptitle">' + escapeHtml(prizeText) + '</div>'
      + '    <div class="pmeta"></div>'
      + '    <div class="pwinner">'
      + '      <div class="winner-cell">'
      + '        <div class="label">Ticket #</div>'
      + '        <div class="value">' + escapeHtml(ticketText) + '</div>'
      + '      </div>'
      + '      <div class="winner-cell">'
      + '        <div class="label">Winner</div>'
      + '        <div class="value">' + escapeHtml(winnerName) + '</div>'
      + '      </div>'
      + '      <div class="winner-cell">'
      + '        <div class="label">Value</div>'
      + '        <div class="value">' + escapeHtml(prizeValueText) + '</div>'
      + '      </div>'
      + '    </div>'
      + '  </div>'
      + '</div>';

    $("#prize_info").append(card);
  });
}

function renderEntrantsRows(rows) {
  var $all = $("#allEntrants");
  $all.empty();

  if (!rows || !rows.length) {
    $all.append('<div class="empty-state">No matching entrants found.</div>');
    return;
  }

  var columns = getEntrantsColumns();
  var sortedRows = sortEntrantRows(rows);
  var rowClass = "row hoverable mode-" + currentEntrantsMode;
  var emphasisKey = getEntrantsEmphasisKey();

  var htmlRows = [];
  for (var i = 0; i < sortedRows.length; i++) {
    var r = sortedRows[i];
    var rowHtml = '<div class="' + rowClass + '">';
    columns.forEach(function(column) {
      var cellClass = column.className + (column.key === emphasisKey ? ' emphasis-cell' : '');
      rowHtml += '<div class="' + cellClass + '">' + escapeHtml(column.value(r)) + '</div>';
    });
    rowHtml += '</div>';
    htmlRows.push(rowHtml);
  }

  $all.append(htmlRows.join(''));
}

function applyEntrantFilter() {
  var rawQuery = $('.lookup-input').val() || "";
  var query = normalizeEntrantSearch(rawQuery);

  if (!allEntrantsData || !allEntrantsData.length) {
    renderEntrantsRows([]);
    return;
  }

  if (!query) {
    renderEntrantsRows(allEntrantsData);
    return;
  }

  var numericTicket = /^\d+$/.test(query) ? parseInt(query, 10) : null;

  var filtered = allEntrantsData.filter(function(row) {
    if (numericTicket !== null && entrantRowContainsTicketNumber(row, numericTicket)) {
      return true;
    }
    var name = normalizeEntrantSearch(row[1]);
    return name.indexOf(query) !== -1;
  });

  renderEntrantsRows(filtered);
}

function buildEntrantsTable(result) {
  var rows = Array.isArray(result) ? result.slice() : [];
  currentEntrantsMode = determineEntrantsMode(rows);
  if (currentEntrantsMode === "range" || currentEntrantsMode === "barter-range") {
    rows = addTicketRanges(rows);
  }

  allEntrantsData = rows;
  renderEntrantsHeader();

  if (!allEntrantsData.length) {
    $("#allEntrants").html('<div class="empty-state">No entrants yet.</div>');
    return;
  }

  applyEntrantFilter();
}

function formatPublicBarterValue(value) {
  var amount = parseInt(value, 10)
  if (!isFinite(amount)) amount = 0
  return amount.toLocaleString()
}

function updatePublicBarterButton(raffleResult) {
  var enabled = !!(raffleResult && parseInt(raffleResult["raffle_barter_enabled"], 10))
  $("#public_barter_list_button").toggleClass("is-visible", enabled)
}

function renderPublicBarterList(items, raffleResult) {
  var $body = $("#public_barter_list_body")
  var title = "Barter Bounty List"
  var raffleNum = raffleResult && raffleResult["raffle_guild_num"] ? String(raffleResult["raffle_guild_num"]) : ""
  var raffleTitle = raffleResult && raffleResult["raffle_title"] ? String(raffleResult["raffle_title"]).trim() : ""

  if (raffleNum && raffleTitle) {
    title = "#" + raffleNum + " • " + raffleTitle
  } else if (raffleNum) {
    title = "#" + raffleNum + " Raffle"
  }

  $("#public_barter_list_title").text(title)
  $("#public_barter_list_subtitle").text("Eligible barter items for this raffle week")

  if (!items || !items.length) {
    $body.html('<div class="barter-list-empty">No barter bounty items are active for this raffle.</div>')
    return
  }

  var rows = items.map(function (item) {
    var ticketWord = parseInt(item.barter_rate, 10) === 1 ? "TICKET" : "TICKETS"
    var rateText = formatPublicBarterValue(item.barter_rate) + " " + ticketWord
    return "<tr>" +
      "<td>" + formatPublicBarterValue(item.quantity) + "</td>" +
      "<td>" + escapeHtml(item.item_name || "") + "</td>" +
      "<td>=</td>" +
      "<td>" + escapeHtml(rateText) + "</td>" +
      "</tr>"
  }).join("")

  $body.html(
    '<table class="barter-list-table">' +
      '<thead><tr><th>Qty</th><th>Item Name</th><th>=</th><th>Barter Rate</th></tr></thead>' +
      '<tbody>' + rows + '</tbody>' +
    '</table>'
  )
}

function openPublicBarterList() {
  $.getJSON("json/get/raffle", function (raffleResult) {
    if (!raffleResult || !parseInt(raffleResult["raffle_barter_enabled"], 10)) {
      return
    }
    $.getJSON("json/get/raffle_bounty_list", function (result) {
      renderPublicBarterList((result && result.items) || [], raffleResult || {})
      $("#public_barter_list_modal").addClass("is-open")
    }).fail(function () {
      alert("Unable to load the barter list right now.")
    })
  })
}

function closePublicBarterList() {
  $("#public_barter_list_modal").removeClass("is-open")
}

function refresher() {
  $.getJSON(liveRaffleEndpoint, function(result) {
    liveCurrentRaffleNum = String(result["raffle_guild_num"] || "");

    if (!currentDisplayedRaffleNum) {
      currentDisplayedRaffleNum = liveCurrentRaffleNum;
    }

    updateRaffleNav();
  });

  $.getJSON("json/get/guild", function(result) {
    $("#guild_header").text(result["guild_name"]);
    applyGuildBranding(result);
  });

  $.getJSON("json/get/raffle", function(result) {
    var raffleNum = String(result["raffle_guild_num"] || "");
    currentDisplayedRaffleNum = raffleNum;
    var raffleHeader = buildRaffleHeaderParts(raffleNum, result["raffle_title"], result["raffle_time"]);

    if (window.innerWidth <= 700) {
  $("#raffle_subheader").html(escapeHtml(raffleHeader.heading) + "<br>" + escapeHtml(raffleHeader.trailing));
  } else {
  $("#raffle_subheader").text("#" + raffleNum + " Raffle • Drawing: " + normalizeEasternTimeLabel(result["raffle_time"]));
  }
    if (window.innerWidth <= 700) {
  $("#raffle_subheader").html(escapeHtml(raffleHeader.heading) + "<br>" + escapeHtml(raffleHeader.trailing));
  } else {
  $("#raffle_subheader").text(raffleHeader.heading + raffleHeader.separator + raffleHeader.trailing);
  }
    applyPublicStatus(result["raffle_status"], result["raffle_title"]);
    updatePublicBarterButton(result);
    $("#raffle_notes_public_1").html(result["raffle_notes"] || "").removeClass("pending-note");
    $(".mid-row .info-panel:last .info-body").attr("id", "raffle_notes_public_2").addClass("rich-notes").html(result["raffle_notes_public_2"] || "").removeClass("pending-note");
    $("#entrants_headline").text("#" + raffleNum + " Raffle Entrants");

    updateRaffleNav();
  });

  $.getJSON("json/get/tickets_extended", function(result) {
    $("#raffle_participants").text(result.length);
    $("#raffle_participants_mobile").text(result.length);

    var total = 0;
    for (var i = 0; i < result.length; i++) {
      total += result[i][2] << 0;
    }
    var totalText = total.toLocaleString();
    $("#raffle_sold").text(totalText);
    $("#raffle_sold_mobile").text(totalText);

    buildEntrantsTable(result);
  });

  $.getJSON("json/get/prizes", function(result) {
    buildPrizeCards(result);
  });

  $.getJSON("json/get/timestamp", function(result) {
    updateRaffleStatusLine(result);
  });
}

$(document).ready(refresher);
$(document).ready(function () {
  window.setInterval(refresher, 30000);
  $("#public_barter_list_button").on("click", openPublicBarterList);
  $("#public_barter_list_close").on("click", closePublicBarterList);
  $("#public_barter_list_modal").on("click", function (event) {
    if (event.target === this) {
      closePublicBarterList();
    }
  });
});
</script>
</head>
<body class="${'is-staging' if is_staging else ''}">
% if is_staging:
<div class="stage-banner">${stage_label} ENVIRONMENT</div>
% endif
<div class="page">

  <section class="card header">
    <div class="header-left">
    <img id="mainLogo" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="BBC logo">

    <div class="title-block">
      <h1 id="guild_header"></h1>
      <div class="sub mobile-subline">
        <span id="raffle_subheader">#${initial_display_raffle} Raffle</span>
        <button
          type="button"
          class="mobile-search-toggle-inline"
          id="mobile_search_toggle_inline"
          aria-expanded="false"
          aria-controls="header_right"
          aria-label="Show raffle search"
        >🔍</button>
      </div>
      <div class="updated${' closed' if initial_lookup_raffle else ''}" id="raffle_updated">${'Raffle Closed' if initial_lookup_raffle else ''}</div>
    </div>

    <div class="stats-inline">
      <div class="stat"><div class="k">Total Tickets</div><div class="v" id="raffle_sold">0</div></div>
      <div class="stat"><div class="k">Participants</div><div class="v" id="raffle_participants">0</div></div>
    </div>
    </div>

    <div class="header-right" id="header_right">
      <form id="raffle_lookup_form" action="/${request.matchdict['guild']}/lookup" method="get" class="search-wrap" style="margin:0;" autocomplete="off">
        <span>🔍</span>
        <input type="text" id="raffle_lookup" name="raffle_lookup" placeholder="Enter Raffle #" />
      </form>
      <div class="raffle-nav" id="raffle_nav"></div>
    </div>
  </section>

  <section class="mobile-stats-row">
    <div class="stat"><div class="k">Total Tickets</div><div class="v" id="raffle_sold_mobile">0</div></div>
    <div class="stat"><div class="k">Participants</div><div class="v" id="raffle_participants_mobile">0</div></div>
  </section>

  <section class="mid-row">
    <div class="card info-panel">
      <div class="info-bar raffle-live-header">
  <div class="raffle-live-title">
    <span class="live-dot"></span>
    <span class="status-dice" aria-hidden="true">🎲</span>
    <strong id="raffle_titlebar"><span class="raffle-status-text">LIVE</span><span class="raffle-title-sep">-</span><span class="raffle-name-text">Raffle</span></strong>
  </div>
  <button type="button" class="barter-list-button" id="public_barter_list_button">View Barter List</button>
</div>
      <div class="info-body rich-notes pending-note" id="raffle_notes_public_1"></div>
    </div>

    <div class="card info-panel">
      <div class="info-bar with-archives"><span class="info-bar-title">More Info</span><div class="raffle-nav" id="raffle_nav_primary"></div></div>
      <div class="info-body rich-notes pending-note"></div>
    </div>
  </section>

  <section class="bottom-row">
    <div class="card prizes-panel">
      <div class="prizes" id="prize_info">
        <div class="empty-state">No prize cards yet.</div>
      </div>
    </div>

    <div class="card entrants-panel">
      <div class="table-headline" id="entrants_headline">#${initial_display_raffle} Raffle Entrants</div>
      <div class="table-sub">Tickets Lookup</div>

      <div class="entrants-controls">
        <input type="text" class="lookup-input" placeholder="Enter @name or ticket number">
      </div>

      <div class="entrants-body">
      <div class="thead mode-standard" id="entrantsHead">
        <div class="idx">#</div>
        <div class="name">Name</div>
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
<div class="barter-list-modal" id="public_barter_list_modal">
  <div class="barter-list-dialog">
    <div class="barter-list-dialog-header">
      <div>
        <p class="barter-list-dialog-title" id="public_barter_list_title">Barter Bounty List</p>
        <p class="barter-list-dialog-subtitle" id="public_barter_list_subtitle"></p>
      </div>
      <button type="button" class="barter-list-close" id="public_barter_list_close">Close</button>
    </div>
    <div id="public_barter_list_body"></div>
  </div>
</div>
</body>
</html>
