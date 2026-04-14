<!DOCTYPE html>
<html>
<head>   
<%
ga4_site_area = 'admin'
ga4_raffle_view = 'current'
ga4_raffle_number = ''
ga4_guild_slug = request.matchdict.get('guild', '')
is_staging = (request.registry.settings.get("app_env") == "staging")
stage_label = (request.registry.settings.get("app_stage_label") or "STAGING").strip()
%>
<%include file="analytics_snippet.mako"/>
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
<title>${('[%s] ' % stage_label) if is_staging else ''}Raffle Admin</title>
<link rel="icon" id="appFaviconIco" type="image/x-icon" href="/static/favicon.ico">
<link rel="icon" id="appFavicon32" type="image/png" sizes="32x32" href="/static/favicon-256.png">
<link rel="icon" id="appFavicon16" type="image/png" sizes="16x16" href="/static/favicon-256.png">

<style>
:root{
  --bg:#060a12;
  --panel:#091224;
  --panel2:#07101f;
  --brand-primary:#284CA6;
  --brand-accent:#5078D2;
  --brand-primary-rgb:40,76,166;
  --brand-accent-rgb:80,120,210;
  --line:rgba(var(--brand-accent-rgb),.18);
  --line2:rgba(var(--brand-accent-rgb),.34);
  --text:#f4f7ff;
  --muted:#9fb0cf;
  --blue:var(--brand-accent);
  --blue2:var(--brand-primary);
  --shadow:0 18px 48px rgba(0,0,0,.38);
  --page-gutter:18px;
  --admin-header-art:url("/static/cakes2026.png");
  --admin-header-art-position:center 48%;
  --admin-header-art-size:95% auto;
}

*,
*::before,
*::after{
  box-sizing:border-box;
}

html,body{
  margin:0;
  padding:0;
  background:radial-gradient(circle at top left, rgba(40,76,166,.18), transparent 24%),linear-gradient(180deg,#05070d 0%,#060a12 100%);
  background-color:#060a12;
  color:var(--text);
  font-family:Inter,system-ui,Arial,sans-serif;
  height:auto !important;
  min-height:100%;
}

html{
  overflow-y:scroll;
}

body{
  position:static !important;
  min-height:100vh;
  overflow-x:hidden;
  padding:0 var(--page-gutter);
}

body.is-staging{
  box-shadow:inset 0 6px 0 #d94a4a;
}

.stage-banner{
  display:flex;
  align-items:center;
  justify-content:center;
  margin:12px auto 0;
  padding:10px 14px;
  width:min(100%, 1480px);
  border:1px solid rgba(217,74,74,.55);
  background:linear-gradient(180deg, rgba(123,21,21,.96), rgba(95,16,16,.96));
  color:#fff3f3;
  font-size:13px;
  font-weight:900;
  letter-spacing:.16em;
  text-transform:uppercase;
  box-shadow:0 12px 28px rgba(0,0,0,.28);
}

.stage-pill{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  padding:5px 10px;
  border:1px solid rgba(255,122,122,.55);
  background:rgba(122,22,22,.9);
  color:#fff2f2;
  font-size:11px;
  font-weight:900;
  letter-spacing:.14em;
  text-transform:uppercase;
}
body.legacy-modal-open{
  overflow:hidden;
}

.page-shell{
  width:100%;
  max-width:1880px;
  margin:0 auto;
  padding:18px 0;
  box-sizing:border-box;
}

.card{
  background:linear-gradient(180deg,var(--panel),var(--panel2));
  border:1px solid var(--line);
  border-radius:22px;
  box-shadow:var(--shadow);
  width:100%;
}

.admin-topbar{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:10px;
  margin-bottom:6px;
  min-height:40px;
}
.admin-topbar-updated{
  color:#e6d77a;
  font-size:clamp(.84rem,.9vw,.96rem);
  font-weight:700;
  letter-spacing:.01em;
  min-width:0;
  line-height:1.2;
}
.admin-topbar-controls{
  display:flex;
  align-items:center;
  justify-content:flex-end;
  gap:8px;
  margin-left:auto;
}

/* NEW HEADER */
.admin-header{
  display:grid;
  grid-template-columns:minmax(0,1fr) auto;
  align-items:center;
  gap:12px 18px;
  padding:12px 20px;
  margin-bottom:12px;
  min-width:0;
  min-height:104px;
  position:relative;
  overflow:hidden;
  isolation:isolate;
  background:
    linear-gradient(90deg, rgba(8,12,20,.84) 0%, rgba(8,12,20,.72) 24%, rgba(8,12,20,.34) 58%, rgba(8,12,20,.12) 100%),
    linear-gradient(180deg, rgba(18,27,44,.38), rgba(10,18,32,.48)),
    var(--admin-header-art) var(--admin-header-art-position) / var(--admin-header-art-size) no-repeat,
    linear-gradient(180deg,var(--panel),var(--panel2));
}
.admin-header::before{
  content:"";
  position:absolute;
  inset:0;
  background:linear-gradient(180deg, rgba(255,255,255,.02), rgba(255,255,255,0));
  opacity:1;
  filter:none;
  pointer-events:none;
  z-index:0;
}
.header-left{
  display:grid;
  grid-template-columns:72px minmax(0,1fr);
  align-items:center;
  gap:14px;
  min-width:0;
}
.admin-header img#mainLogo{
  width:64px;
  height:64px;
  object-fit:contain;
  flex:0 0 auto;
}
.title-block{
  display:flex;
  flex-direction:column;
  gap:4px;
  min-width:0;
}
.title-block h1{
  margin:0;
  font-size:clamp(1.5rem,1.8vw,2.05rem);
  line-height:1.02;
  font-weight:700;
  letter-spacing:-.03em;
}
.title-block .sub{
  color:#b8c7e4;
  font-size:clamp(.9rem,.96vw,.98rem);
  font-weight:600;
}
.title-block .updated{
  display:none;
}
.stats-inline{
  display:flex;
  gap:8px;
  flex-wrap:wrap;
  justify-content:flex-end;
}
.stat{
  border-radius:16px;
  padding:8px 12px;
  background:rgba(8,17,31,.86);
  border:1px solid var(--line);
  text-align:center;
  min-width:108px;
}
.stat .k{
  color:var(--muted);
  font-size:.64rem;
  font-weight:700;
  letter-spacing:.04em;
  text-transform:uppercase;
  margin-bottom:5px;
}
.stat .v{
  font-size:1.4rem;
  font-weight:800;
  line-height:1;
}
.header-right{
  display:flex;
  align-items:center;
  justify-content:flex-start;
  position:relative;
  min-width:0;
}
.header-left,
.header-right{
  position:relative;
  z-index:1;
}
.header-right .stats-inline{
  justify-content:flex-start;
}
.admin-flags{
  display:flex;
  flex-direction:column;
  gap:4px;
  align-items:center;
  margin-right:4px;
  min-width:70px;
}
.admin-flags.admin-only{
  justify-content:center;
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
  border-radius:14px;
  background:#0f1622;
  padding:8px 10px;
  min-height:42px;
  min-width:170px;
  max-width:none;
  flex:1 1 170px;
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
  z-index:2200;
}
.profile-menu.open{
  z-index:2210;
}
.profile-menu-trigger{
  display:flex;
  align-items:center;
  gap:6px;
  min-height:34px;
  padding:0;
  border:none;
  background:transparent;
  color:var(--text);
  box-shadow:none;
  cursor:pointer;
  overflow:visible;
}
.profile-menu-trigger:focus{
  outline:none;
}
.profile-trigger-logo-shell{
  min-width:36px;
  min-height:36px;
  display:flex;
  align-items:center;
  justify-content:center;
  padding:0;
  background:transparent;
  border:none;
  border-radius:0;
  box-shadow:none;
}
.profile-menu-logo{
  width:34px;
  height:34px;
  border-radius:8px;
  object-fit:cover;
  border:1px solid rgba(255,255,255,.14);
  flex:0 0 auto;
  box-shadow:var(--shadow);
}
.profile-menu-caret{
  width:22px;
  height:22px;
  display:flex;
  align-items:center;
  justify-content:center;
  border:1px solid rgba(140,170,230,.18);
  border-radius:50%;
  background:rgba(6,10,18,.88);
  font-size:.62rem;
  line-height:1;
  color:#f4f7ff;
  box-shadow:0 8px 18px rgba(0,0,0,.2);
  backdrop-filter:blur(2px);
  -webkit-backdrop-filter:blur(2px);
}
.profile-menu-panel{
  position:absolute;
  top:calc(100% + 8px);
  right:0;
  width:336px;
  padding:0;
  border-radius:0;
  border:1px solid rgba(95,132,212,.34);
  background:linear-gradient(180deg,rgba(22,34,58,.99),rgba(9,17,31,.99));
  box-shadow:var(--shadow);
  display:none;
  z-index:2215;
  overflow:visible;
  max-height:none;
}
.profile-menu.open .profile-menu-panel{
  display:block;
}
.profile-menu-panel::before{
  content:"";
  position:absolute;
  top:-8px;
  right:20px;
  width:14px;
  height:14px;
  background:linear-gradient(180deg,rgba(22,34,58,.99),rgba(17,28,48,.99));
  border-top:1px solid rgba(95,132,212,.34);
  border-left:1px solid rgba(95,132,212,.34);
  transform:rotate(45deg);
}
.profile-menu-lookup{
  padding:10px;
  background:linear-gradient(180deg,rgba(29,44,73,.95),rgba(18,28,47,.95));
  border-bottom:1px solid rgba(95,132,212,.2);
}
.profile-menu-section{
  border-top:1px solid rgba(95,132,212,.12);
}
.profile-menu-list,
.profile-submenu-list{
  display:grid;
  gap:0;
}
.profile-menu-list{
  max-height:none;
  overflow:visible;
}
.profile-menu-item,
.profile-submenu-trigger{
  width:100%;
  min-height:48px;
  padding:0 14px;
  display:flex;
  align-items:center;
  justify-content:space-between;
  border:none;
  border-radius:0;
  background:transparent;
  color:var(--text);
  font-size:.95rem;
  font-weight:700;
  text-align:left;
  text-decoration:none;
  cursor:pointer;
  border-top:1px solid rgba(95,132,212,.12);
}
.profile-menu-item:hover,
.profile-submenu-trigger:hover,
.profile-menu-item:focus,
.profile-submenu-trigger:focus{
  background:rgba(80,120,210,.11);
  outline:none;
}
.profile-menu-icon{
  width:18px;
  text-align:center;
  color:#b8c7e4;
  flex:0 0 18px;
  display:inline-flex;
  align-items:center;
  justify-content:center;
}
.profile-menu-text{
  flex:1 1 auto;
  padding-left:10px;
}
.profile-menu-icon svg{
  width:17px;
  height:17px;
  stroke:currentColor;
  fill:none;
  stroke-width:1.8;
  stroke-linecap:round;
  stroke-linejoin:round;
}
.profile-submenu{
  position:relative;
}
.profile-submenu::after{
  content:"";
  position:absolute;
  top:0;
  right:100%;
  width:18px;
  height:100%;
}
.profile-submenu-trigger{
  gap:12px;
}
.profile-submenu-arrow{
  font-size:.94rem;
  line-height:1;
  color:#c9d7f4;
}
.profile-submenu-panel{
  position:absolute;
  top:-1px;
  right:calc(100% - 2px);
  width:248px;
  padding:0;
  border-radius:0;
  border:1px solid rgba(95,132,212,.34);
  background:linear-gradient(180deg,rgba(18,29,50,.99),rgba(9,17,31,.99));
  box-shadow:var(--shadow);
  display:none;
  overflow:hidden;
  z-index:2220;
  max-height:calc(100vh - 120px);
}
.profile-submenu-panel::before{
  content:"";
  position:absolute;
  top:18px;
  right:-6px;
  width:12px;
  height:12px;
  background:linear-gradient(180deg,rgba(18,29,50,.99),rgba(12,21,37,.99));
  border-top:1px solid rgba(95,132,212,.34);
  border-right:1px solid rgba(95,132,212,.34);
  transform:rotate(45deg);
}
.profile-submenu.open .profile-submenu-panel{
  display:block;
}
.profile-submenu:hover .profile-submenu-panel{
  display:block;
}
.profile-submenu-item{
  width:100%;
  min-height:48px;
  padding:0 16px;
  display:flex;
  align-items:center;
  justify-content:flex-start;
  gap:0;
  border:none;
  border-radius:0;
  background:transparent;
  color:var(--text);
  font-size:.96rem;
  font-weight:800;
  text-align:left;
  cursor:pointer;
  border-top:1px solid rgba(95,132,212,.12);
  text-decoration:none;
}
.profile-submenu-item:hover,
.profile-submenu-item:focus{
  background:rgba(80,120,210,.11);
  outline:none;
}
.profile-menu-item.is-placeholder{
  opacity:.7;
}

.profile-menu-divider{
  height:1px;
  margin:8px 14px;
  background:rgba(95,132,212,.22);
}

.profile-menu-user{
  padding:10px 14px 6px;
}

.profile-menu-user-name{
  margin:0;
  font-size:.92rem;
  font-weight:800;
  color:#dbe7ff;
  letter-spacing:.01em;
}

/* NEW BUTTON BAR */
.button-bar{
  display:flex;
  flex-wrap:wrap;
  gap:14px;
  margin-bottom:14px;
  width:100%;
  padding:10px 14px;
  align-items:center;
  background:
    linear-gradient(180deg,rgba(15,27,48,.98),rgba(8,17,31,.98));
  border:1px solid var(--line);
  border-radius:18px;
  box-shadow:var(--shadow);
}
.button-bar-label{
  color:#c2d2ee;
  font-size:.76rem;
  font-weight:800;
  letter-spacing:.12em;
  text-transform:uppercase;
  white-space:nowrap;
  margin-right:4px;
  padding-right:12px;
  border-right:1px solid rgba(95,132,212,.14);
  line-height:1;
}
.button-bar-left,
.button-bar-right{
  display:flex;
  align-items:center;
  gap:10px;
  min-width:0;
  flex-wrap:wrap;
}
.button-bar-right{
  margin-left:auto;
  justify-content:flex-end;
}
.tool-cluster{
  display:flex;
  align-items:center;
  gap:4px;
  min-width:0;
  padding:4px;
  border-radius:14px;
  border:1px solid rgba(95,132,212,.12);
  background:rgba(10,18,31,.58);
}
.action-btn{
  min-height:38px;
  min-width:0;
  padding:0 14px;
  border-radius:8px;
  border:1px solid transparent;
  background:transparent;
  color:#dfe8fb;
  font-size:.88rem;
  font-weight:700;
  white-space:nowrap;
  overflow:hidden;
  text-overflow:ellipsis;
  box-shadow:none;
  cursor:pointer;
  flex:0 0 auto;
  transition:background .16s ease,border-color .16s ease,transform .16s ease;
}
.action-btn:hover,
.action-btn:focus{
  background:rgba(22,38,66,.92);
  border-color:rgba(109,145,218,.18);
  outline:none;
}
.tool-menu{
  position:relative;
  flex:0 0 auto;
}
.tool-menu > summary{
  list-style:none;
}
.tool-menu > summary::-webkit-details-marker{
  display:none;
}
.tool-menu-trigger{
  display:flex;
  align-items:center;
  gap:8px;
}
.tool-menu-caret{
  font-size:.72rem;
  color:#9fb3d9;
  opacity:.9;
}
.tool-menu[open] > .tool-menu-trigger{
  background:rgba(22,38,66,.98);
  border-color:rgba(109,145,218,.18);
}
.tool-menu-panel{
  position:absolute;
  top:calc(100% + 10px);
  left:0;
  min-width:230px;
  padding:10px;
  border-radius:18px;
  border:1px solid rgba(95,132,212,.22);
  background:linear-gradient(180deg,rgba(18,29,50,.99),rgba(9,17,31,.99));
  box-shadow:var(--shadow);
  z-index:35;
}
.tool-menu-panel::before{
  content:"";
  position:absolute;
  top:-7px;
  left:26px;
  width:14px;
  height:14px;
  background:linear-gradient(180deg,rgba(18,29,50,.99),rgba(12,21,37,.99));
  border-top:1px solid rgba(95,132,212,.22);
  border-left:1px solid rgba(95,132,212,.22);
  transform:rotate(45deg);
}
.tool-menu-actions{
  display:grid;
  gap:8px;
}
.tool-menu-action{
  width:100%;
  min-height:38px;
  padding:0 12px;
  display:flex;
  align-items:center;
  border-radius:12px;
  border:1px solid rgba(95,132,212,.16);
  background:rgba(11,20,36,.9);
  color:#f4f7ff;
  font-size:.88rem;
  font-weight:700;
  text-align:left;
  cursor:pointer;
  transition:background .16s ease,border-color .16s ease;
}
.tool-menu-action:hover,
.tool-menu-action:focus{
  background:rgba(22,38,66,.98);
  border-color:rgba(109,145,218,.24);
  outline:none;
}
.tool-menu-edit .tool-menu-panel{
  min-width:300px;
  padding:12px;
}
.tool-panel-title{
  color:#f4f7ff;
  font-size:.94rem;
  font-weight:800;
  letter-spacing:.02em;
  margin-bottom:10px;
}
.tool-form-grid{
  display:grid;
  gap:10px;
}
.tool-field{
  display:grid;
  gap:6px;
}
.tool-field.is-wide{
  grid-column:1 / -1;
}
.tool-field label{
  color:#b8c7e4;
  font-size:.76rem;
  font-weight:700;
  letter-spacing:.04em;
  text-transform:uppercase;
}
.tool-input{
  min-height:38px;
  padding:0 12px;
  border-radius:12px;
  border:1px solid rgba(95,132,212,.18);
  background:#0f1622;
  color:#edf3ff;
  font-size:.9rem;
  font-weight:600;
}
.status-tool{
  display:flex;
  align-items:center;
  gap:0;
  padding-left:12px;
  border-left:1px solid rgba(95,132,212,.14);
}
.status-select-shell{
  position:relative;
  display:flex;
  align-items:center;
}
.status-select-shell::after{
  content:"";
  position:absolute;
  right:14px;
  top:50%;
  width:10px;
  height:10px;
  border-right:2px solid currentColor;
  border-bottom:2px solid currentColor;
  transform:translateY(-65%) rotate(45deg);
  pointer-events:none;
  opacity:.92;
}
.status-tool-select{
  min-width:208px;
  max-width:208px;
  padding-left:14px;
  padding-right:40px;
  font-weight:800;
  appearance:none;
  -webkit-appearance:none;
  -moz-appearance:none;
  background-image:none !important;
  border:1px solid rgba(95,132,212,.16) !important;
  box-shadow:none !important;
  background-color:rgba(12,21,37,.82) !important;
}
.status-tool-select.status-live{
  color:#8ff0ba;
}
.status-tool-select.status-rolling{
  color:#f2b36b;
}
.status-tool-select.status-complete{
  color:#ff9d9d;
}
.status-tool-select:focus{
  outline:none !important;
  box-shadow:none !important;
  border-color:rgba(140,170,230,.26) !important;
}
.admin-form-hidden{
  display:none !important;
}

.admin-utility-band{
  display:grid;
  grid-template-columns:minmax(0,1.45fr) minmax(320px,.95fr);
  gap:12px;
  margin-bottom:14px;
  width:100%;
  align-items:stretch;
}

.utility-panel{
  display:flex;
  flex-direction:column;
  min-height:204px;
  background:linear-gradient(180deg,var(--panel),var(--panel2));
  border:1px solid var(--line);
  border-radius:22px;
  box-shadow:var(--shadow);
  overflow:hidden;
}

.utility-panel-title{
  min-height:38px;
  padding:8px 14px;
  display:flex;
  align-items:center;
  color:#f4f7ff;
  font-size:.94rem;
  font-weight:820;
  letter-spacing:.02em;
}

.notes-panel .utility-panel-title{
  background:linear-gradient(90deg,#1a6abb,#19487d);
}

.upload-panel .utility-panel-title{
  background:linear-gradient(90deg,#7f5b25,#5d431d);
}

.utility-panel-body{
  flex:1;
  padding:16px;
  display:flex;
  min-height:0;
}

.notes-panel .utility-panel-title{
  padding:8px 14px;
  display:block;
}

.notes-panel .utility-panel-body{
  flex-direction:column;
  gap:12px;
}

.notes-panel.is-read-mode .utility-panel-body{
  gap:0;
}

.notes-header-shell{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
}

.note-tab-strip{
  display:flex;
  flex-wrap:wrap;
  gap:8px;
}

.note-tab{
  min-height:30px;
  padding:0 12px;
  border:1px solid rgba(255,255,255,.18);
  border-radius:999px;
  background:rgba(7,15,28,.28);
  color:#d8e6ff;
  font-size:.84rem;
  font-weight:850;
  letter-spacing:.04em;
  cursor:pointer;
}

.note-tab.active{
  background:#f4f7ff;
  color:#17376c;
  border-color:rgba(255,255,255,.7);
}

.note-save-group{
  display:flex;
  align-items:center;
  gap:14px;
  margin-left:auto;
  flex-wrap:nowrap;
  justify-content:flex-end;
}

.note-save-status{
  display:inline-flex;
  align-items:center;
  gap:8px;
  color:rgba(244,247,255,.82);
  font-size:.8rem;
  font-weight:700;
  white-space:nowrap;
}

.note-save-status::before{
  content:"";
  width:8px;
  height:8px;
  border-radius:999px;
  background:currentColor;
  box-shadow:0 0 0 2px rgba(255,255,255,.08);
}

.note-action-btn{
  min-height:28px;
  padding:0;
  border:none;
  border-radius:0;
  background:transparent;
  color:#f4f7ff;
  font-size:.84rem;
  font-weight:800;
  cursor:pointer;
  opacity:.92;
  transition:opacity .16s ease,color .16s ease;
}

.note-action-btn:hover,
.note-action-btn:focus{
  opacity:1;
  color:#ffffff;
  outline:none;
}

.note-edit-toggle{
  display:inline-flex;
  align-items:center;
  gap:8px;
}

.note-action-icon{
  position:relative;
  width:14px;
  height:14px;
  flex:0 0 14px;
}

.note-action-icon::before{
  content:"";
  position:absolute;
  inset:1px 3px 1px 1px;
  border:1.5px solid currentColor;
  border-radius:2px;
  opacity:.86;
}

.note-action-icon::after{
  content:"";
  position:absolute;
  right:0;
  top:1px;
  width:8px;
  height:2px;
  background:currentColor;
  border-radius:999px;
  transform:rotate(-42deg);
  transform-origin:right center;
  box-shadow:0 3px 0 -0.5px currentColor;
}

.note-save-btn.is-dirty{
  color:#ffffff;
}

.note-save-btn{
  display:inline-flex;
  align-items:center;
  gap:8px;
}

.note-save-btn::before{
  content:"";
  width:10px;
  height:10px;
  border-radius:999px;
  background:currentColor;
  box-shadow:0 0 0 2px rgba(255,255,255,.08);
}

.notes-editor-toolbar{
  display:flex;
  flex-wrap:wrap;
  gap:8px;
}

.notes-panel.is-read-mode .notes-editor-toolbar{
  display:none;
}

.note-tool{
  min-width:38px;
  min-height:34px;
  padding:0 10px;
  border:1px solid rgba(140,170,230,.18);
  border-radius:12px;
  background:#101927;
  color:#f4f7ff;
  font-size:.92rem;
  font-weight:850;
  cursor:pointer;
}

.note-tool[data-cmd="bold"]{
  font-weight:900;
}

.note-tool[data-cmd="italic"]{
  font-style:italic;
}

.note-tool[data-cmd="underline"]{
  text-decoration:underline;
}

.note-tool.note-link{
  padding:0 12px;
}

.note-color{
  width:42px;
  min-height:34px;
  padding:4px;
  border:1px solid rgba(140,170,230,.18);
  border-radius:12px;
  background:#101927;
  cursor:pointer;
}

.notes-editor-surface{
  flex:1;
  min-height:160px;
  border:1px solid rgba(140,170,230,.18);
  border-radius:16px;
  background:rgba(10,18,32,.62);
  color:#d6deeb;
  padding:16px 18px;
  box-sizing:border-box;
  font-size:1rem;
  line-height:1.55;
  overflow:auto;
  outline:none;
}

.notes-panel.is-read-mode .notes-editor-surface{
  min-height:112px;
  padding:14px 16px;
  background:rgba(8,15,28,.42);
  border-color:rgba(140,170,230,.12);
  cursor:default;
}

.notes-editor-surface.is-empty::before{
  content:attr(data-placeholder);
  color:#8194b4;
}

.notes-panel.is-read-mode .notes-editor-surface.is-empty::before{
  content:"No notes in this tab yet.";
}

.notes-editor-surface a{
  color:#7fb4ff;
}

.notes-editor-surface ul,
.notes-editor-surface ol{
  padding-left:1.4em;
}

.hidden-note-field{
  display:none !important;
}

/* LEGACY LAYOUT CLEANUP */
#main{
  width:100%;
  max-width:none;
  margin:0;
  padding:0;
  height:auto !important;
  min-height:0 !important;
}

#main_table{
  width:100%;
  display:grid;
  grid-template-columns:minmax(0,1fr) minmax(420px, 464px);
  gap:12px;
  align-items:start;
  border-collapse:separate;
  height:auto !important;
}

#main_table > tbody,
#main_table > tbody > tr{
  display:contents;
}

#column_guildinfo{
  display:none;
  vertical-align:top;
  min-width:0;
  width:auto;
  height:auto !important;
}

#column_prizeinfo{
  display:block;
  vertical-align:top;
  min-width:0;
  width:auto !important;
  overflow:hidden;
  height:auto !important;
}

#column_ticketinfo{
  display:block;
  vertical-align:top;
  min-width:0;
  width:100% !important;
  max-width:520px !important;
  height:auto !important;
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
  margin:0;
}

#center{
  background:transparent;
  border:none;
  box-shadow:none;
  padding:0;
  height:auto !important;
}

#right{
  width:100%;
  min-width:0;
  overflow:visible;
  height:auto !important;
}

.prize.prize-shell{
  width:100% !important;
  max-width:none !important;
  margin-left:0 !important;
  margin-right:0 !important;
}

#ticket_info{
  width:100%;
  height:auto !important;
  overflow:visible;
}

#ticket_info .handsontable th,
#ticket_info .handsontable td{
  white-space:nowrap;
  border-color:rgba(80,120,210,.16) !important;
}

#ticket_info .handsontable th,
#ticket_info .handsontable .ht_clone_top th,
#ticket_info .handsontable .ht_clone_left th,
#ticket_info .handsontable .ht_clone_top_left_corner th,
#ticket_info .handsontable td:first-of-type{
  background:#182233 !important;
  color:#aebfe0 !important;
}

#ticket_info .handsontable td{
  background:#0d1524 !important;
  color:#edf3ff !important;
}

#ticket_info .handsontable td.totals-column{
  color:#e6d77a !important;
}

#ticket_info .handsontable td.ticket-neutral-column{
  color:#edf3ff !important;
  font-weight:400 !important;
}

#ticket_info .handsontable .htDimmed,
#ticket_info .handsontable .colHeader{
  color:#aebfe0 !important;
}

#ticket_info .handsontable th.ht__highlight,
#ticket_info .handsontable .ht_clone_top th.ht__highlight,
#ticket_info .handsontable .ht_clone_left th.ht__highlight,
#ticket_info .handsontable .ht_clone_top_left_corner th.ht__highlight,
#ticket_info .handsontable th.columnSorting,
#ticket_info .handsontable .ht_clone_top th.columnSorting,
#ticket_info .handsontable .ht_clone_left th.columnSorting,
#ticket_info .handsontable .ht_clone_top_left_corner th.columnSorting,
#ticket_info .handsontable th[aria-sort]{
  background:#22314b !important;
  color:#edf3ff !important;
}

#ticket_info .handsontable th.ht__active_highlight,
#ticket_info .handsontable .ht_clone_top th.ht__active_highlight,
#ticket_info .handsontable th.afterSelection,
#ticket_info .handsontable .ht_clone_top th.afterSelection,
#ticket_info .handsontable th.beforeSelection,
#ticket_info .handsontable .ht_clone_top th.beforeSelection{
  background:#2a3c5d !important;
  color:#ffffff !important;
}

#ticket_info .handsontable td:first-of-type{
  font-weight:700;
}

#ticket_info .handsontable .currentRow,
#ticket_info .handsontable .currentCol,
#ticket_info .handsontable .area{
  background:inherit !important;
}

#ticket_info .handsontable td.currentCol,
#ticket_info .handsontable td.currentRow,
#ticket_info .handsontable td.area,
#ticket_info .handsontable td.ht__highlight,
#ticket_info .handsontable td.ht__active_highlight{
  background:#0d1524 !important;
  color:#edf3ff !important;
}

#ticket_info .handsontable td.currentCol.totals-column,
#ticket_info .handsontable td.currentRow.totals-column,
#ticket_info .handsontable td.area.totals-column,
#ticket_info .handsontable td.ht__highlight.totals-column,
#ticket_info .handsontable td.ht__active_highlight.totals-column{
  color:#e6d77a !important;
}

#ticket_info .handsontable td.currentCol.ticket-neutral-column,
#ticket_info .handsontable td.currentRow.ticket-neutral-column,
#ticket_info .handsontable td.area.ticket-neutral-column,
#ticket_info .handsontable td.ht__highlight.ticket-neutral-column,
#ticket_info .handsontable td.ht__active_highlight.ticket-neutral-column{
  color:#edf3ff !important;
}

#ticket_info .wtHolder,
#ticket_info .wtHider,
#ticket_info .wtSpreader{
  height:auto !important;
}

#ticket_info .wtHolder{
  overflow:visible !important;
}

#ticket_info .handsontable td.ticket-range-cell,
#ticket_info .handsontable th.ticket-range-cell{
  white-space:nowrap;
  overflow:visible;
  text-overflow:clip;
}

.ticket-summary-box{
  margin-top:12px;
  padding:12px 14px;
  border:1px solid rgba(80,120,210,.2);
  background:rgba(9,18,36,.72);
  color:#edf3ff;
  display:grid;
  gap:6px;
}

.ticket-summary-row{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
  font-size:.95rem;
  line-height:1.2;
}

.ticket-summary-label{
  color:#aebfe0;
  font-weight:700;
}

.ticket-summary-value{
  font-variant-numeric:tabular-nums;
  text-align:right;
  white-space:nowrap;
}

.ticket-summary-value.total{
  color:#e6d77a;
  font-weight:700;
}

.ticket-tools{
  display:flex;
  justify-content:flex-end;
  margin-bottom:10px;
  width:100%;
}

.ticket-copy-btn{
  min-height:38px;
  padding:0 14px;
  border-radius:14px;
  border:1px solid var(--line2);
  background:linear-gradient(180deg,#0b1a34,#09142a);
  color:#f4f7ff;
  font-size:.92rem;
  font-weight:850;
  cursor:pointer;
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

#raffle_status.status-live{
  color:#8ff0ba;
  font-weight:800;
}

#raffle_status.status-rolling{
  color:#f2b36b;
  font-weight:800;
}

#raffle_status.status-complete{
  color:#ff9d9d;
  font-weight:800;
}

#raffle_status option{
  background:#0f1622;
  font-weight:800;
}

#raffle_status option[value="LIVE"]{
  color:#8ff0ba;
}

#raffle_status option[value="ROLLING"]{
  color:#f2b36b;
}

#raffle_status option[value="COMPLETE"]{
  color:#ff9d9d;
}

#dropzone_uploader{
  width:100%;
  max-width:none;
  box-sizing:border-box;
  min-height:150px;
  margin:0;
  border:4px dotted rgba(96,129,184,.42);
  border-radius:20px;
  background:linear-gradient(180deg,rgba(8,15,28,.86),rgba(5,11,22,.96));
  display:flex;
  align-items:center;
  justify-content:center;
  padding:14px;
  box-shadow:inset 0 0 0 1px rgba(30,51,90,.34);
}

#dropzone_uploader .dz-message{
  margin:0;
  color:#d6deeb;
  font-weight:700;
  text-align:center;
  line-height:1.5;
}

#dropzone_uploader .dz-message strong{
  display:block;
  font-size:1rem;
  font-weight:850;
  color:#f4f7ff;
}

#dropzone_uploader .dz-message span{
  display:block;
  margin-top:6px;
  color:#99aac5;
  font-size:.92rem;
}

#legacy_modal_backdrop{
  display:none;
  position:fixed;
  inset:0;
  background:rgba(7,11,18,.58);
  z-index:1900;
}

#new_raffle_modal{
  display:none;
  position:fixed;
  left:50%;
  top:50%;
  transform:translate(-50%, -50%);
  width:min(1180px, calc(100vw - 48px));
  max-height:calc(100vh - 48px);
  overflow:hidden;
  z-index:2050;
  border:1px solid rgba(80,120,210,.2);
  border-radius:24px;
  background:linear-gradient(180deg,#101b30,#091321);
  box-shadow:0 32px 100px rgba(0,0,0,.5);
}

.new-raffle-modal-shell{
  display:flex;
  flex-direction:column;
  min-height:0;
  max-height:calc(100vh - 48px);
}

.new-raffle-modal-header{
  display:flex;
  align-items:flex-start;
  justify-content:space-between;
  gap:18px;
  padding:18px 20px 16px;
  border-bottom:1px solid rgba(80,120,210,.16);
  background:linear-gradient(180deg,rgba(17,31,55,.96),rgba(11,22,39,.96));
}

.new-raffle-modal-title{
  display:grid;
  gap:6px;
}

.new-raffle-modal-title h2{
  margin:0;
  color:#f4f7ff;
  font-size:1.5rem;
  line-height:1.1;
}

.new-raffle-modal-title p{
  margin:0;
  color:#aebfe0;
  font-size:.95rem;
  line-height:1.45;
}

.new-raffle-modal-close{
  min-height:34px;
  padding:0 14px;
  border:1px solid rgba(95,132,212,.18);
  border-radius:12px;
  background:rgba(10,18,31,.72);
  color:#f4f7ff;
  font-size:.9rem;
  font-weight:800;
  cursor:pointer;
}

.new-raffle-modal-body{
  overflow:auto;
  padding:18px 20px 20px;
  display:grid;
  gap:18px;
}

.new-raffle-overview{
  display:grid;
  grid-template-columns:repeat(4, minmax(0,1fr));
  gap:12px;
}

.new-raffle-field{
  display:grid;
  gap:7px;
}

.new-raffle-field.is-wide{
  grid-column:1 / -1;
}

.new-raffle-field label,
.new-raffle-note-header h3{
  color:#c2d2ee;
  font-size:.76rem;
  font-weight:800;
  letter-spacing:.06em;
  text-transform:uppercase;
  margin:0;
}

.new-raffle-field input{
  min-height:40px;
  padding:0 12px;
  border:1px solid rgba(95,132,212,.18);
  border-radius:12px;
  background:#0f1622;
  color:#edf3ff;
  font-size:.94rem;
  font-weight:600;
}

.new-raffle-status-chip{
  min-height:40px;
  display:flex;
  align-items:center;
  padding:0 12px;
  border:1px solid rgba(76,182,126,.18);
  border-radius:12px;
  background:rgba(11,34,20,.56);
  color:#8ff0ba;
  font-size:.94rem;
  font-weight:800;
}

.barter-toggle-field{
  display:grid;
  gap:8px;
}

.barter-toggle-shell{
  display:flex;
  align-items:center;
  gap:12px;
  min-height:40px;
}

.barter-toggle-switch{
  position:relative;
  display:inline-flex;
  align-items:center;
  width:64px;
  height:36px;
  flex:0 0 auto;
}

.barter-toggle-switch input{
  position:absolute;
  inset:0;
  width:100%;
  height:100%;
  margin:0;
  opacity:0;
  cursor:pointer;
  z-index:2;
}

.barter-toggle-slider{
  position:relative;
  width:64px;
  height:36px;
  border-radius:999px;
  background:rgba(84,97,120,.48);
  border:1px solid rgba(95,132,212,.22);
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.04);
  transition:background .18s ease, border-color .18s ease, box-shadow .18s ease;
}

.barter-toggle-slider::after{
  content:"";
  position:absolute;
  top:4px;
  left:4px;
  width:26px;
  height:26px;
  border-radius:50%;
  background:#ffffff;
  box-shadow:0 3px 12px rgba(0,0,0,.28);
  transition:transform .18s ease;
}

.barter-toggle-switch input:checked + .barter-toggle-slider{
  background:linear-gradient(180deg,#6169f4,#515ade);
  border-color:rgba(126,137,255,.55);
  box-shadow:0 0 0 1px rgba(97,105,244,.18), 0 10px 24px rgba(65,79,232,.2);
}

.barter-toggle-switch input:checked + .barter-toggle-slider::after{
  transform:translateX(28px);
}

.barter-toggle-switch input:focus-visible + .barter-toggle-slider{
  outline:2px solid rgba(180,198,255,.95);
  outline-offset:2px;
}

.barter-toggle-copy{
  display:grid;
  gap:2px;
}

.barter-toggle-label{
  color:#eef3ff;
  font-size:.9rem;
  font-weight:800;
}

.barter-toggle-value{
  color:#9eb0d1;
  font-size:.76rem;
  font-weight:700;
  letter-spacing:.06em;
  text-transform:uppercase;
}

.barter-toggle-value.is-on{
  color:#8ff0ba;
}

.new-raffle-status-chip::before{
  content:"";
  width:9px;
  height:9px;
  margin-right:9px;
  border-radius:999px;
  background:currentColor;
  box-shadow:0 0 0 2px rgba(255,255,255,.08);
}

.new-raffle-options{
  display:grid;
  gap:10px;
  padding:14px 16px;
  border:1px solid rgba(95,132,212,.16);
  border-radius:16px;
  background:linear-gradient(180deg,rgba(14,24,41,.92),rgba(9,17,31,.96));
}

.new-raffle-option{
  display:flex;
  align-items:flex-start;
  gap:12px;
}

.new-raffle-option input[type="checkbox"]{
  margin-top:2px;
  width:18px;
  height:18px;
  accent-color:#4fa0ff;
}

.new-raffle-option-copy{
  display:grid;
  gap:4px;
}

.new-raffle-option-title{
  color:#eef3ff;
  font-size:.92rem;
  font-weight:800;
}

.new-raffle-option-help{
  color:#9eb0d1;
  font-size:.82rem;
  line-height:1.45;
}

.new-raffle-notes-grid{
  display:grid;
  gap:14px;
}

.new-raffle-note-card{
  border:1px solid rgba(95,132,212,.16);
  border-radius:18px;
  background:linear-gradient(180deg,rgba(14,24,41,.92),rgba(9,17,31,.96));
  overflow:hidden;
}

.new-raffle-note-header{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
  padding:12px 14px;
  border-bottom:1px solid rgba(95,132,212,.12);
  background:rgba(15,29,50,.84);
}

.new-raffle-note-actions{
  display:flex;
  align-items:center;
  gap:12px;
}

.new-raffle-clear{
  min-height:34px;
  padding:0 12px;
  border:1px solid rgba(140,170,230,.18);
  border-radius:12px;
  background:#101927;
  color:#dfe8fb;
  font-size:.84rem;
  font-weight:800;
  cursor:pointer;
  opacity:.9;
}

.new-raffle-toolbar{
  display:flex;
  flex-wrap:wrap;
  gap:8px;
  padding:12px 14px 0;
}

.new-raffle-editor{
  margin:12px 14px 14px;
  min-height:120px;
  max-height:220px;
  overflow:auto;
  padding:14px 16px;
  border:1px solid rgba(140,170,230,.16);
  border-radius:16px;
  background:rgba(10,18,32,.68);
  color:#d6deeb;
  line-height:1.55;
  outline:none;
}

.new-raffle-editor.is-empty::before{
  content:attr(data-placeholder);
  color:#8194b4;
}

.new-raffle-actions{
  display:flex;
  justify-content:flex-end;
  gap:12px;
  padding:0 20px 20px;
}

.new-raffle-secondary,
.new-raffle-primary{
  min-height:40px;
  padding:0 16px;
  border-radius:14px;
  font-size:.92rem;
  font-weight:850;
  cursor:pointer;
}

.new-raffle-secondary{
  border:1px solid rgba(95,132,212,.18);
  background:rgba(10,18,31,.72);
  color:#f4f7ff;
}

.new-raffle-primary{
  border:1px solid rgba(109,145,218,.24);
  background:linear-gradient(180deg,#1f5fa7,#194a86);
  color:#f4f7ff;
}

.new-raffle-primary:disabled{
  opacity:.65;
  cursor:default;
}

#import_template,
#confirm_template,
#change_password_template,
#account_settings_template,
#manage_access_template,
#guild_settings_template,
#bounty_list_template,
#recent_imports_template,
#barter_summary_template,
#barter_template,
#paid_template{
  display:none;
  position:fixed !important;
  left:50% !important;
  top:50% !important;
  transform:translate(-50%, -50%);
  width:min(1100px, calc(100vw - 48px)) !important;
  max-height:calc(100vh - 48px) !important;
  min-height:320px;
  z-index:2000 !important;
  box-sizing:border-box;
  border:1px solid #6b727c !important;
  border-radius:18px;
  background:linear-gradient(180deg,#d7dade,#cfd4da) !important;
  color:#000000 !important;
  padding:0 !important;
  overflow:hidden;
  box-shadow:0 28px 90px rgba(0,0,0,.48);
}

div#paid_template{
  position:fixed !important;
  left:50% !important;
  top:50% !important;
  transform:translate(-50%, -50%) !important;
  z-index:2000 !important;
  width:min(1100px, calc(100vw - 48px)) !important;
  max-height:calc(100vh - 48px) !important;
  padding:0 !important;
  background:linear-gradient(180deg,#d7dade,#cfd4da) !important;
  border:1px solid #6b727c !important;
}

#import_buttons,
#confirm_buttons,
#change_password_buttons,
#manage_access_buttons,
#barter_buttons,
#paid_buttons{
  display:flex;
  justify-content:flex-end;
  gap:10px;
  align-items:center;
  padding:12px 16px !important;
  background:#c7ccd2 !important;
  border-bottom:1px solid #8b9199 !important;
}

#import_data,
#confirm_data,
#change_password_data,
#manage_access_data,
#barter_data,
#paid_data{
  height:auto !important;
  max-height:calc(100vh - 118px) !important;
  overflow:auto;
  padding:16px !important;
  box-sizing:border-box;
  background:#d8dce1 !important;
}

.import-empty-state{
  padding:18px 12px !important;
  text-align:center;
  color:#445062;
  font-weight:700;
}

#confirm_import_summary{
  display:none;
  margin:0 0 16px;
  padding:14px 16px;
  border:1px solid #9aa5b4;
  border-radius:12px;
  background:#eef1f5;
}

.confirm-import-summary-title{
  margin:0 0 6px;
  font-size:12px;
  font-weight:700;
  letter-spacing:0.08em;
  text-transform:uppercase;
  color:#41556f;
}

.confirm-import-summary-text{
  margin:0;
  font-size:15px;
  line-height:1.45;
  color:#202937;
}

.import-guardrail-line + .import-guardrail-line{
  margin-top:8px;
}

.import-file-summary{
  margin:0 0 12px;
  padding:8px 14px;
  border:1px solid #9aa5b4;
  border-radius:12px;
  background:#eef1f5;
}

.import-file-summary-row{
  display:flex;
  align-items:flex-start;
  justify-content:flex-start;
  gap:10px;
  flex-wrap:nowrap;
}

.import-file-summary-text{
  flex:1 1 auto;
  min-width:0;
  font-size:12px;
  line-height:1.45;
  color:#1f2a38;
  font-weight:500;
}

.import-file-summary-segment{
  white-space:nowrap;
}

.import-file-summary-off{
  display:inline-block;
  margin-left:4px;
  padding:1px 6px;
  border-radius:999px;
  background:#cf5b5b;
  color:#ffffff;
  font-weight:800;
  letter-spacing:.03em;
  text-shadow:0 1px 0 rgba(0,0,0,.12);
}

.import-file-summary-segment + .import-file-summary-segment::before{
  content:" | ";
  color:#7b8794;
  font-weight:600;
}

.import-file-summary-actions{
  display:flex;
  align-items:center;
  gap:10px;
}

.import-summary-warning{
  margin:0 0 12px;
  color:#f6b2b2;
  font-size:12px;
  line-height:1.45;
  font-weight:500;
}

.import-summary-warning p{
  margin:0;
}

.import-debug-copy{
  border:1px solid #8d97a5;
  background:#e9edf4;
  color:#243142;
  border-radius:10px;
  padding:7px 11px;
  font-size:11px;
  font-weight:900;
  letter-spacing:.04em;
  cursor:pointer;
  white-space:nowrap;
}

.import-debug-copy:hover{
  background:#dfe6ef;
}

.import-guardrail-label{
  display:inline-block;
  margin-right:4px;
  padding:1px 6px;
  border-radius:999px;
  background:#cf5b5b;
  color:#ffffff;
  font-weight:800;
  letter-spacing:.03em;
  text-shadow:0 1px 0 rgba(0,0,0,.12);
}

.import-guardrail-ignored{
  display:inline-block;
  margin-right:4px;
  padding:1px 6px;
  border-radius:999px;
  background:#d98a3d;
  color:#ffffff;
  font-weight:800;
  letter-spacing:.03em;
  text-shadow:0 1px 0 rgba(0,0,0,.12);
}

.import-guardrail-strong{
  display:block;
  margin-top:4px;
  font-style:italic;
  text-decoration:underline;
}

#confirm_data{
  display:flex;
  flex-direction:column;
  gap:12px;
}

.confirm-copy-block{
  display:flex;
  flex-direction:column;
  gap:6px;
}

.confirm-copy-header{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
}

.confirm-copy-label{
  margin:0;
  font-weight:700;
  color:#334155;
}

.confirm-copy-btn{
  border:1px solid #8d97a5;
  background:#eef1f5;
  color:#243142;
  border-radius:10px;
  padding:6px 10px;
  font-size:12px;
  font-weight:700;
  cursor:pointer;
}

.confirm-copy-btn:hover{
  background:#e5e9ef;
}

#recent_imports_template{
  display:none;
}

#recent_imports_data{
  display:grid;
  gap:12px;
}

.recent-import-empty{
  padding:18px 16px;
  border:1px dashed #9aa5b4;
  border-radius:12px;
  color:#405166;
  background:#eef1f5;
}

.recent-import-item{
  display:grid;
  gap:8px;
  padding:14px 16px;
  border:1px solid #a2acb9;
  border-radius:12px;
  background:#f1f4f8;
}

.recent-import-top{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:10px;
}

.recent-import-kind{
  font-size:12px;
  font-weight:800;
  letter-spacing:.08em;
  text-transform:uppercase;
  color:#41556f;
}

.recent-import-time{
  font-size:12px;
  color:#58697d;
}

.recent-import-summary{
  font-size:14px;
  line-height:1.45;
  color:#202937;
}

.recent-import-actions{
  display:flex;
  justify-content:flex-end;
}

.recent-import-open{
  border:1px solid #8d97a5;
  background:#e9edf4;
  color:#243142;
  border-radius:10px;
  padding:7px 11px;
  font-size:12px;
  font-weight:700;
  cursor:pointer;
}

.recent-import-open:hover{
  background:#dfe6ef;
}

.barter-summary-shell{
  display:grid;
  gap:12px;
}

.barter-summary-toolbar{
  display:flex;
  justify-content:flex-end;
}

.barter-summary-table{
  width:100%;
  border-collapse:collapse;
  background:#eef2f6;
  border:1px solid #c8d0da;
}

.barter-summary-table th,
.barter-summary-table td{
  padding:10px 12px;
  border-bottom:1px solid #d5dde6;
  text-align:left;
  color:#233142;
}

.barter-summary-table th{
  font-size:12px;
  font-weight:800;
  letter-spacing:.08em;
  text-transform:uppercase;
  color:#4a5c74;
}

.barter-summary-total-row td{
  font-weight:900;
  background:#e3e8ef;
}

#manage_access_template{
  display:none;
}

#change_password_template{
  display:none;
}

#account_settings_template{
  display:none;
}

.manage-access-section{
  display:grid;
  gap:12px;
}

.manage-access-card{
  border:1px solid #a2acb9;
  border-radius:12px;
  background:#eef2f6;
  padding:14px 16px;
}

.manage-access-title{
  margin:0 0 10px;
  font-size:13px;
  font-weight:800;
  letter-spacing:.08em;
  text-transform:uppercase;
  color:#41556f;
}

.manage-access-create{
  display:grid;
  grid-template-columns:repeat(2, minmax(0, 1fr));
  gap:10px;
}

.manage-access-create input{
  width:100%;
}

.manage-access-checkbox input,
.manage-access-guilds input{
  width:auto;
  margin:0;
}

.manage-access-create .manage-access-full{
  grid-column:1 / -1;
}

.guild-settings-grid{
  display:grid;
  gap:12px;
}

.guild-settings-section{
  border:1px solid #d0d7e2;
  border-radius:12px;
  background:#f7f9fc;
  padding:14px 16px;
}

.guild-settings-fields{
  display:grid;
  gap:0;
  align-items:start;
}

.guild-settings-row{
  display:grid;
  grid-template-columns:repeat(2, minmax(0, 1fr));
  gap:10px 18px;
  align-items:start;
  padding:12px 0;
  border-top:1px solid #d7dde6;
}

.guild-settings-row:first-child{
  padding-top:0;
  border-top:none;
}

.guild-settings-row.is-single{
  grid-template-columns:minmax(0, 1fr);
}

.guild-settings-row.is-full{
  grid-template-columns:minmax(0, 1fr);
}

.guild-settings-field{
  display:grid;
  gap:6px;
  align-content:start;
}

.guild-settings-field.is-full{
  grid-column:1 / -1;
}

.guild-settings-label{
  font-size:12px;
  font-weight:800;
  letter-spacing:.03em;
  color:#445062;
}

.guild-settings-input,
.guild-settings-select{
  width:100%;
  min-height:40px;
  padding:0 12px;
  border-radius:10px;
  border:1px solid #bcc7d6;
  background:#ffffff;
  color:#1d2735;
  font-size:14px;
  font-weight:600;
  box-sizing:border-box;
}

.guild-settings-select{
  appearance:none;
  -webkit-appearance:none;
  -moz-appearance:none;
  padding-right:38px;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 14 14'%3E%3Cpath d='M3.25 5.25L7 9l3.75-3.75' fill='none' stroke='%23505f73' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat:no-repeat;
  background-position:right 12px center;
  background-size:14px 14px;
  color-scheme:light;
}

.guild-settings-select option{
  background:#ffffff;
  color:#1d2735;
  color-scheme:light;
}

.guild-settings-section-title{
  margin:0 0 10px;
  font-size:12px;
  font-weight:900;
  letter-spacing:.08em;
  text-transform:uppercase;
  color:#4a5665;
}

.guild-settings-rule-title{
  margin:12px 0 6px;
  font-size:11px;
  font-weight:900;
  letter-spacing:.08em;
  text-transform:uppercase;
  color:#445062;
}

.guild-settings-rule-block + .guild-settings-rule-block{
  margin-top:14px;
  padding-top:14px;
  border-top:1px solid #d7dde6;
}

.guild-settings-toolbar{
  display:flex;
  align-items:center;
  gap:12px;
  margin-right:auto;
}

.guild-settings-barter-strip{
  display:flex;
  align-items:center;
  gap:12px;
  margin-left:auto;
}

.guild-settings-barter-strip .barter-toggle-label{
  color:#243142;
}

.guild-settings-barter-strip .barter-toggle-value{
  color:#5e6d80;
}

.guild-settings-barter-strip .barter-toggle-value.is-on{
  color:#2f8f57;
}

.guild-settings-toolbar-status{
  margin:0;
  font-size:13px;
  font-weight:800;
}

.guild-settings-toolbar-status.is-pending{
  color:#c84646;
}

.guild-settings-toolbar-status.is-success{
  color:#2f8f57;
}

.guild-settings-help{
  margin:6px 0 0;
  font-size:12px;
  line-height:1.45;
  color:#5b6776;
}

.guild-settings-help.is-inline{
  margin-top:0;
}

.guild-sister-list{
  display:grid;
  gap:8px;
}

.guild-logo-preview{
  width:52px;
  height:52px;
  object-fit:cover;
  border-radius:12px;
  border:1px solid #c6d0dc;
  background:#ffffff;
  box-shadow:0 6px 18px rgba(24,34,48,.08);
}

.guild-branding-row{
  display:grid;
  grid-template-columns:repeat(2, minmax(0, 1fr));
  gap:12px;
  align-items:start;
}

.guild-color-input{
  width:100%;
  min-height:44px;
  padding:4px;
  border:1px solid #cfd8e3;
  border-radius:12px;
  background:#ffffff;
  cursor:pointer;
}

.guild-color-field{
  display:grid;
  gap:6px;
  align-content:start;
}

.guild-color-swatch-label{
  font-size:12px;
  font-weight:800;
  color:#445062;
}

.guild-mail-account-list{
  display:grid;
  gap:8px;
}

.guild-mail-account-row{
  display:grid;
  grid-template-columns:minmax(0, 1fr) auto;
  gap:8px;
  align-items:center;
}

.bounty-list-shell{
  display:grid;
  gap:14px;
  text-align:left;
}

.bounty-list-toolbar{
  display:flex;
  justify-content:space-between;
  align-items:center;
  gap:10px;
  flex-wrap:wrap;
}

.bounty-list-grid{
  display:grid;
  gap:8px;
}

.bounty-list-table{
  width:100%;
  table-layout:fixed;
  border-collapse:separate;
  border-spacing:0 8px;
}

.bounty-list-table col.col-name{
  width:29%;
}

.bounty-list-table col.col-code{
  width:26%;
}

.bounty-list-table col.col-qty{
  width:12%;
}

.bounty-list-table col.col-value{
  width:14%;
}

.bounty-list-table col.col-rate{
  width:14%;
}

.bounty-list-table col.col-actions{
  width:120px;
}

.bounty-list-table th{
  padding:0 12px 6px 0;
  box-sizing:border-box;
  font-size:12px;
  font-weight:800;
  letter-spacing:.03em;
  color:#445062;
  text-align:left;
  vertical-align:bottom;
}

.bounty-list-table th:last-child{
  padding-right:0;
}

.bounty-list-table td{
  padding:0 12px 0 0;
  vertical-align:middle;
}

.bounty-list-table td:last-child{
  padding-right:0;
}

.bounty-list-table .manage-access-btn.subtle{
  width:100%;
  white-space:nowrap;
}

.bounty-list-table tbody:empty::before{
  content:"";
  display:block;
}

.bounty-list-paste{
  display:grid;
  gap:8px;
}

.bounty-list-paste textarea{
  width:100%;
  min-height:120px;
  padding:10px 12px;
  border:1px solid #bcc7d6;
  background:#fff;
  color:#1d2735;
  font-size:13px;
  font-weight:600;
  resize:vertical;
  box-sizing:border-box;
}

.manage-access-btn.subtle{
  background:#e2e8f0;
  color:#243041;
}

.manage-access-grid{
  display:grid;
  gap:10px;
}

.manage-access-user{
  display:grid;
  gap:10px;
  border:1px solid #b2bcc8;
  border-radius:12px;
  background:#f6f8fb;
  padding:12px 14px;
}

.manage-access-user-top{
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:12px;
}

.manage-access-username{
  font-size:18px;
  font-weight:800;
  color:#1f2937;
}

.manage-access-roleline{
  font-size:13px;
  color:#5b6b7d;
}

.manage-access-controls{
  display:grid;
  grid-template-columns:1fr;
  gap:10px;
}

.manage-access-checkbox{
  display:flex;
  align-items:center;
  gap:8px;
  font-weight:700;
  color:#263445;
}

.manage-access-guilds{
  display:flex;
  flex-wrap:wrap;
  gap:10px 14px;
}

.manage-access-actions{
  display:flex;
  justify-content:flex-end;
  gap:10px;
  flex-wrap:wrap;
}

.account-settings-actions{
  width:100%;
  justify-content:space-between;
  align-items:center;
}

.manage-access-btn{
  border:1px solid #8d97a5;
  background:#e9edf4;
  color:#243142;
  border-radius:10px;
  padding:8px 12px;
  font-size:12px;
  font-weight:700;
  cursor:pointer;
}

.manage-access-btn:hover{
  background:#dfe6ef;
}

.manage-access-btn.is-danger{
  border-color:#c69191;
  background:#f5e8e8;
  color:#7a2323;
}

.manage-access-status{
  margin:0;
  font-size:13px;
  color:#536476;
}

.manage-access-status.is-error{
  color:#8b1e1e;
}

.manage-access-status.is-pending{
  color:#c84646;
}

.manage-access-status.is-success{
  color:#2f8f57;
}

.manage-access-password-row{
  display:grid;
  grid-template-columns:repeat(2, minmax(0, 1fr));
  gap:10px;
  justify-content:flex-start;
}

.manage-access-password-row .manage-access-full{
  grid-column:1 / -1;
}

.manage-access-password-row.is-separated{
  margin-bottom:12px;
}

.manage-access-password-row.is-pair{
  grid-template-columns:repeat(2, minmax(220px, 260px));
  width:fit-content;
  max-width:100%;
  gap:8px;
}

.manage-access-password-row input{
  width:min(100%, 260px);
}

.manage-access-password-row .manage-access-full{
  width:min(100%, 320px);
}

.manage-access-password-tools{
  display:flex;
  justify-content:flex-start;
  gap:12px;
  flex-wrap:wrap;
}

#import_data_here{
  width:100%;
  border-collapse:separate;
  border-spacing:0;
  table-layout:fixed;
}

#import_data_here th{
  position:sticky;
  top:0;
  background:#cfd4da;
  z-index:2;
}

#import_data_here th,
#import_data_here td{
  padding:8px 10px;
}

#import_data_here th:nth-child(1),
#import_data_here td:nth-child(1){
  width:170px;
}

#import_data_here th:nth-child(2),
#import_data_here td:nth-child(2){
  width:90px;
}

#import_data_here th:nth-child(4),
#import_data_here td:nth-child(4){
  width:220px;
}

#import_data_here th:nth-child(5),
#import_data_here td:nth-child(5){
  width:42px;
}

#import_data_here input[type="text"]{
  width:100%;
  box-sizing:border-box;
}

#import_template input,
#import_template textarea,
#confirm_template input,
#confirm_template textarea,
#barter_template input,
#barter_template textarea,
#paid_template input,
#paid_template textarea{
  color:#000000 !important;
  background:#f5f6f7 !important;
  border:1px solid #777d86 !important;
  box-sizing:border-box;
}

#confirm_string,
#confirm_names,
#barter_import_string,
#barter_confirm_string,
#paid_import_string,
#paid_confirm_string{
  width:100%;
  min-height:180px;
}

#confirm_string,
#confirm_names{
  min-height:126px;
}

#add_prize_block{
  margin-top:12px;
  display:flex;
  gap:10px;
  flex-wrap:wrap;
}

#add_prize_button,
#clone_last_prize_button,
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
  border-collapse:separate;
  border-spacing:0 12px;
}

.prize input[type="text"]{
  background:#0f1622;
  color:#d6deeb;
  border:1px solid rgba(140,170,230,.12);
  border-radius:0;
  font-size:1.25em;
  line-height:1.2;
  padding:10px 14px;
}

.prize input[type="text"]:focus{
  outline:none;
  border-color:rgba(140,170,230,.28);
}

.prize input:-webkit-autofill,
.prize input:-webkit-autofill:hover,
.prize input:-webkit-autofill:focus{
  -webkit-text-fill-color:#eef3ff;
  -webkit-box-shadow:0 0 0 1000px #0f1622 inset;
  box-shadow:0 0 0 1000px #0f1622 inset;
  transition:background-color 9999s ease-out 0s;
  caret-color:#eef3ff;
  border-color:rgba(80,120,210,.22);
}

.prize_number{
  width:100%;
  min-height:82px;
  text-align:center;
  font-size:2.2rem !important;
  font-weight:900;
}

.prize-number-panel{
  display:grid;
  grid-template-rows:auto auto;
  gap:10px;
  align-content:start;
}

.prize-style-control{
  display:grid;
  gap:6px;
}

.prize-style-label{
  display:block;
  font-size:.68rem;
  font-weight:900;
  letter-spacing:.12em;
  text-transform:uppercase;
  color:#8fa6cf;
  text-align:center;
}

.prize_style{
  width:100%;
  min-height:32px;
  padding:7px 10px;
  border:1px solid rgba(80,120,210,.2);
  background:#0f1622;
  color:#eef3ff;
  font:inherit;
  font-size:.88rem;
  font-weight:700;
  text-transform:none;
}

.prize_winner,
.prize_item,
.prize_value{
  min-height:42px;
}

.prize-shell{
  display:grid;
  grid-template-columns:84px minmax(0,1fr) 58px;
  gap:12px;
  align-items:start;
  width:100%;
  box-sizing:border-box;
  padding:10px;
  border:1px solid rgba(80,120,210,.18);
  border-radius:0;
  background:linear-gradient(180deg,rgba(9,18,35,.96),rgba(8,15,28,.98));
  position:relative;
  overflow:visible;
  box-shadow:inset 0 0 0 1px rgba(80,120,210,.16);
}

.prize-shell::before{
  content:"";
  position:absolute;
  inset:0 auto 0 0;
  width:4px;
  background:transparent;
  pointer-events:none;
}

.prize-shell.prize-style-featured{
  border-width:1px;
  border-color:rgba(125,148,192,.26);
  box-shadow:inset 0 0 0 1px rgba(125,148,192,.16), inset 0 3px 0 rgba(130,205,255,.26);
}

.prize-shell.prize-style-featured::before{
  background:linear-gradient(180deg,rgba(130,205,255,.82),rgba(130,205,255,.18));
}

.prize-shell.prize-style-grand{
  border-width:1px;
  border-color:rgba(205,166,92,.34);
  box-shadow:inset 0 0 0 1px rgba(205,166,92,.18), inset 0 4px 0 rgba(223,186,97,.44), 0 6px 18px rgba(0,0,0,.14);
}

.prize-shell.prize-style-grand::before{
  background:linear-gradient(180deg,rgba(223,186,97,.9),rgba(223,186,97,.18));
}

.prize-shell.prize-style-jackpot{
  border-width:1px;
  border-color:rgba(193,227,255,.52);
  background:
    radial-gradient(circle at 88% 24%, rgba(154,211,255,.14), transparent 22%),
    radial-gradient(circle at right center, rgba(154,211,255,.085), transparent 30%),
    linear-gradient(270deg, rgba(154,211,255,.055), rgba(154,211,255,.02) 16%, transparent 40%),
    linear-gradient(180deg,rgba(12,26,45,.98),rgba(7,14,28,.99));
  box-shadow:inset 0 0 0 1px rgba(193,227,255,.16), 0 16px 34px rgba(0,0,0,.28), inset 0 0 22px rgba(122,204,255,.05);
}

.prize-shell.prize-style-jackpot::before{
  width:6px;
  background:linear-gradient(180deg,rgba(245,248,255,.95),rgba(130,205,255,.25));
}

.prize-main{
  display:grid;
  grid-template-rows:auto auto auto;
  gap:12px;
  min-width:0;
  align-content:start;
}

.prize-top-row,
.prize-middle-row,
.prize-bottom-row{
  display:grid;
  gap:10px;
  min-width:0;
}

.prize-top-row,
.prize-middle-row{
  grid-template-columns:minmax(0,1fr);
}

.prize-bottom-row{
  grid-template-columns:96px minmax(0,1fr);
  align-items:center;
}

.prize-field{
  min-width:0;
}

.prize-field input[type="text"]{
  width:100%;
  box-sizing:border-box;
}

.prize-badge-row{
  display:flex;
  justify-content:flex-start;
}

.prize-badge{
  display:none;
  align-items:center;
  min-height:24px;
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

.prize-shell.prize-style-featured .prize-badge,
.prize-shell.prize-style-grand .prize-badge,
.prize-shell.prize-style-jackpot .prize-badge{
  display:inline-flex;
}

.prize-shell.prize-style-featured .prize-badge{
  border-color:rgba(130,205,255,.24);
  background:rgba(39,102,174,.09);
  color:#cae6ff;
}

.prize-shell.prize-style-grand .prize-badge{
  border-color:rgba(223,186,97,.3);
  background:rgba(188,142,47,.1);
  color:#f1deb0;
}

.prize-shell.prize-style-jackpot .prize-badge{
  border-color:rgba(216,236,255,.44);
  background:rgba(86,145,208,.14);
  color:#f1f7ff;
  box-shadow:0 0 16px rgba(122,204,255,.12);
}

.prize-shell.prize-style-grand .prize_item,
.prize-shell.prize-style-grand .prize_value,
.prize-shell.prize-style-jackpot .prize_item,
.prize-shell.prize-style-jackpot .prize_value{
  border-color:rgba(130,205,255,.24);
}

.prize-winner-display{
  min-height:42px;
  box-sizing:border-box;
  padding:10px 14px;
  border:1px solid rgba(140,170,230,.12);
  border-radius:0;
  background:#0f1622;
  color:#f4f7ff;
  font-size:1.25em;
  line-height:1.2;
  display:flex;
  align-items:center;
  overflow:hidden;
  align-self:center;
}

.prize_winner_name{
  display:block;
  width:100%;
  overflow:hidden;
  text-overflow:ellipsis;
  white-space:nowrap;
  font-weight:800;
}

.prize_winner_name:empty::before{
  content:attr(data-placeholder);
  color:#8395b9;
  font-weight:700;
}

.prize_winner_name.finalised{
  color:#cfe8d4;
  background:rgba(88,140,104,.18);
  border-radius:6px;
  padding:2px 8px;
  box-shadow:none;
  text-shadow:none;
}

.prize-actions{
  display:flex;
  flex-direction:column;
  gap:10px;
  border-left:1px solid rgba(80,120,210,.26);
  padding-left:12px;
  align-self:start;
}

.prize-action{
  min-height:48px;
  border:1px solid rgba(80,120,210,.24);
  border-radius:18px;
  background:rgba(11,20,40,.92);
  color:#d8e3ff;
  font-size:0;
  font-weight:900;
  text-decoration:none;
  display:flex;
  align-items:center;
  justify-content:center;
  position:relative;
}

.prize_winner{
  font-size:1.05em !important;
  padding-left:12px !important;
  padding-right:12px !important;
}
.prize-action::before{
  font-size:1.35rem;
  line-height:1;
}
.prize_finalise::before{
  content:"\1F513";
}
.prize_finalise{
  background:rgba(44,108,72,.92);
  border-color:rgba(124,212,153,.42);
  color:#e8fff0;
}
.prize_unlock::before{
  content:"\1F512";
}
.prize_unlock{
  background:rgba(116,40,48,.92);
  border-color:rgba(223,121,128,.4);
  color:#ffe6e8;
}
.prize_roll::before{
  content:"\1F3B2";
}
.prize_clone::before{
  content:"\29C9";
  font-size:1.1rem;
}
.prize_delete::before{
  content:"\1F5D1";
}

.prize-action:hover,
.prize-action:focus{
  color:#ffffff;
  outline:none;
}

.prize input[disabled]{
  opacity:.7;
  cursor:not-allowed;
}

@media (max-width:1200px){
  .admin-utility-band{
    grid-template-columns:1fr;
  }
  .search-wrap{
    min-width:0;
  }
  .button-bar-label{
    border-right:none;
    padding-right:0;
  }
  .tool-cluster{
    width:100%;
  }
  .button-bar-right{
    width:100%;
    margin-left:0;
    justify-content:flex-start;
  }
}

@media (max-width:1450px){
  #main_table{
    grid-template-columns:minmax(0,1fr) minmax(408px, 448px);
  }
}

@media (max-width:1100px){
  #main_table{
    grid-template-columns:1fr;
  }
  #column_ticketinfo{
    max-width:none;
  }
  .profile-submenu-panel{
    right:0;
    top:calc(100% + 12px);
  }
}

@media (max-width:900px){
  .admin-topbar{
    flex-wrap:wrap;
  }
  .admin-header{
    grid-template-columns:1fr;
    min-height:0;
  }
  .header-left{
    grid-template-columns:1fr;
  }
  .admin-header img#mainLogo{
    width:72px;
    height:72px;
  }
  .header-right{
    width:100%;
  }
  .stats-inline{
    justify-content:flex-start;
  }
  .utility-panel{
    min-height:180px;
  }
  .status-tool{
    padding-left:0;
    border-left:none;
  }
  .notes-header-shell{
    align-items:flex-start;
    flex-direction:column;
  }
  .note-save-group{
    width:100%;
    justify-content:flex-start;
    margin-left:0;
    flex-wrap:wrap;
  }
  .new-raffle-overview{
    grid-template-columns:1fr;
  }
  .new-raffle-modal-header{
    flex-direction:column;
    align-items:flex-start;
  }
  .new-raffle-actions{
    flex-wrap:wrap;
  }
}
</style>

<script>
jQuery.fn.center = function() {
    return this.css({
        position: 'fixed',
        left: '50%',
        top: '50%',
        transform: 'translate(-50%, -50%)',
        marginLeft: 0,
        marginTop: 0
    });
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

function closeToolMenus() {
        document.querySelectorAll(".tool-menu[open]").forEach(function (menu) {
                menu.removeAttribute("open")
        })
}

function normalizeRaffleStatus(status) {
        var value = (status || "LIVE").toString().trim().toUpperCase()
        if (value === "CLOSED") {
                return "COMPLETE"
        }
        if (value !== "LIVE" && value !== "ROLLING" && value !== "COMPLETE") {
                return "LIVE"
        }
        return value
}

function applyAdminStatus(status) {
        var normalizedStatus = normalizeRaffleStatus(status)
        var statusSelect = $("#raffle_status")
        statusSelect.removeClass("status-live status-rolling status-complete")
        statusSelect.addClass("status-" + normalizedStatus.toLowerCase())
}

function copyNamesAndTotals() {
        var hot = $("#ticket_info").handsontable("getInstance")
        if (!hot) {
                return
        }

        var rows = hot.getData() || []
        var output = []

        for (var i = 0; i < rows.length; i++) {
                var row = rows[i] || []
                var name = row[1] == null ? "" : $.trim(String(row[1]))
                var total = row[2]

                if (!name) {
                        continue
                }

                if (total == null || total === "") {
                        total = 0
                }

                output.push(name + "\t" + total)
        }

        var text = output.join("\n")
        if (!text) {
                return
        }

        function showCopiedState() {
                var btn = document.getElementById("copyNamesTotalsBtn")
                if (!btn) {
                        return
                }
                var original = btn.textContent
                btn.textContent = "Copied"
                setTimeout(function () {
                        btn.textContent = original
                }, 1200)
        }

        if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(text).then(showCopiedState)
                return
        }

        var helper = document.createElement("textarea")
        helper.value = text
        helper.setAttribute("readonly", "")
        helper.style.position = "absolute"
        helper.style.left = "-9999px"
        document.body.appendChild(helper)
        helper.select()
        document.execCommand("copy")
        document.body.removeChild(helper)
        showCopiedState()
}

function copyPrizeCardsToSheets() {
        var output = []

        $("#prize_info .prize-shell").each(function () {
                var $card = $(this)
                var prizeNumber = $.trim(String($card.find("input[name='prize_text2']").val() || ""))
                var description = $.trim(String($card.find("input[name='prize_text']").val() || ""))
                var value = $.trim(String($card.find("input[name='prize_value']").val() || ""))

                if (!prizeNumber && !description && !value) {
                        return
                }

                output.push([prizeNumber, description, value].join("\t"))
        })

        var text = output.join("\n")
        if (!text) {
                window.alert("No current prize cards to copy yet.")
                return
        }

        function showCopiedState() {
                window.alert("Current Prize Cards copied to clipboard")
        }

        if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(text).then(showCopiedState).catch(function () {
                        fallbackCopyPrizeCards(text, showCopiedState)
                })
                return
        }

        fallbackCopyPrizeCards(text, showCopiedState)
}

function fallbackCopyPrizeCards(text, onSuccess) {
        var helper = document.createElement("textarea")
        helper.value = text
        helper.setAttribute("readonly", "")
        helper.style.position = "absolute"
        helper.style.left = "-9999px"
        document.body.appendChild(helper)
        helper.select()
        document.execCommand("copy")
        document.body.removeChild(helper)
        if (onSuccess) {
                onSuccess()
        }
}

function normalizePrizeValue(rawValue) {
        var digits = String(rawValue == null ? "" : rawValue).replace(/[^\d]/g, "")
        if (!digits) {
                return ""
        }

        return digits.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
}

function formatPrizeValueField(field) {
        if (!field) {
                return
        }

        field.value = normalizePrizeValue(field.value)
}

function serializePrizeForm($form) {
        if (!$form || !$form.length) {
                return ""
        }

        var data = $form.serializeArray()
        for (var i = 0; i < data.length; i++) {
                if (data[i].name === "prize_value") {
                        data[i].value = String(data[i].value == null ? "" : data[i].value).replace(/[^\d]/g, "")
                }
        }

        return $.param(data)
}

function applyPrizeStyleState(template, prizeStyle) {
        var style = (prizeStyle || "standard").toLowerCase()
        if (style === "flagship" || style === "premier") {
                style = "jackpot"
        } else if (style === "signature") {
                style = "grand"
        }
        if ($.inArray(style, ["standard", "featured", "grand", "jackpot"]) === -1) {
                style = "standard"
        }

        var shell = $(".prize-shell", template)
        shell.removeClass("prize-style-standard prize-style-featured prize-style-grand prize-style-jackpot")
        shell.addClass("prize-style-" + style)

        var badge = $(".prize-badge", template)
        if (style === "jackpot") {
                badge.text("Jackpot")
        } else if (style === "grand") {
                badge.text("Grand Prize")
        } else if (style === "featured") {
                badge.text("Featured")
        } else {
                badge.text("")
        }

        var select = $("select.prize_style", template)
        if (select.length) {
                var el = select[0]
                el.value = style
                for (var i = 0; i < el.options.length; i++) {
                        el.options[i].selected = (el.options[i].value === style)
                }
                if (el.value !== style) {
                        el.selectedIndex = 0
                }
        }
}

function savePrizeForm($form, options) {
        options = options || {}
        if (!$form || !$form.length) {
                return $.Deferred().resolve().promise()
        }

        var deferred = $.Deferred()

        $.ajax({
                type: "POST",
                url: "json/set/prize",
                data: serializePrizeForm($form),
                success: function (result) {
                        if (isActionError(result)) {
                                if (!options.silent) {
                                        alert(actionErrorMessage(result))
                                }
                                deferred.reject(result)
                                return
                        }

                        if (options.refreshAfterSave) {
                                get_prize_info(options.refreshOptions || {})
                        }

                        deferred.resolve(result)
                },
                error: function () {
                        var result = { ok: false, error: "Unable to save this prize." }
                        if (!options.silent) {
                                alert(result.error)
                        }
                        deferred.reject(result)
                },
                xhrFields: {
                        withCredentials: true
                }
        })

        return deferred.promise()
}

function saveAllVisiblePrizeForms() {
        var requests = []

        $("#prize_info form").each(function () {
                var $form = $(this)
                if ($form.find(".prize_unlock").length) {
                        return
                }
                requests.push(savePrizeForm($form, { silent: true }))
        })

        if (requests.length === 0) {
                return $.Deferred().resolve().promise()
        }

        return $.when.apply($, requests)
}

function syncLegacyModalState() {
        var anyVisible = $("#import_template:visible, #confirm_template:visible, #change_password_template:visible, #account_settings_template:visible, #manage_access_template:visible, #guild_settings_template:visible, #bounty_list_template:visible, #recent_imports_template:visible, #barter_summary_template:visible, #barter_template:visible, #paid_template:visible, #new_raffle_modal:visible").length > 0
        $("#legacy_modal_backdrop").toggle(anyVisible)
        $("body").toggleClass("legacy-modal-open", anyVisible)
}

function showLegacyModal(selector, modalClass) {
        var modal = $(selector)
        modal.removeClass("import confirm barter paid")
        if (modalClass) {
                modal.addClass(modalClass)
        }
        modal.center().show()
        syncLegacyModalState()
}

function hideLegacyModal(selector) {
        $(selector).hide()
        syncLegacyModalState()
}

function escapeHtml(value) {
        return String(value == null ? "" : value)
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#39;")
}

function normalizeImportResult(result) {
        if ($.isArray(result)) {
                return {
                        confirm_string: result[0] || "",
                        confirm_names: result[1] || "",
                        import_summary: null
                }
        }

        return {
                confirm_string: (result && result.confirm_string) || "",
                confirm_names: (result && result.confirm_names) || "",
                import_summary: (result && result.import_summary) || null
        }
}

function formatImportSummaryText(summary) {
        if (!summary) {
                return ""
        }

        var totalAdded = Number(summary.total_added) || 0
        var newParticipants = Number(summary.new_participants) || 0
        var existingParticipants = Number(summary.existing_participants) || 0
        var parts = [
                totalAdded.toLocaleString() + " tickets added.",
                newParticipants.toLocaleString() + " new participant" + (newParticipants === 1 ? "" : "s") + "."
        ]

        if (existingParticipants > 0) {
                parts.push(existingParticipants.toLocaleString() + " participant" + (existingParticipants === 1 ? "" : "s") + " added more tickets.")
        } else {
                parts.push("No existing participants added more tickets.")
        }

        return parts.join(" ")
}

function updateConfirmImportSummary(summary) {
        var $box = $("#confirm_import_summary")
        var text = formatImportSummaryText(summary)

        if (!text) {
                $("#confirm_import_summary_text").text("")
                $box.hide()
                return
        }

        $("#confirm_import_summary_text").text(text)
        $box.show()
}

function updateImportGuardrailSummary(warnings) {
        var $box = $("#import_guardrail_summary")
        var html = ""

        if ($.isArray(warnings) && warnings.length) {
                var formattedWarnings = $.map(warnings, function (warning) {
                        var text = escapeHtml(String(warning || ""))
                        text = text.replace(/^Ignored\b/i, '<span class="import-guardrail-ignored">Ignored</span>')
                        text = text.replace(/^Warning:/i, '<span class="import-guardrail-label">Warning</span>')
                        text = text.replace(/They will not be processed\./gi, '<span class="import-guardrail-strong">They will not be processed.</span>')
                        text = text.replace(/Review carefully before importing\./gi, '<span class="import-guardrail-strong">Review carefully before importing.</span>')
                        return '<div class="import-guardrail-line">' + text + '</div>'
                })
                html = formattedWarnings.join("")
        }

        if (!html) {
                $("#import_guardrail_summary_text").html("")
                $box.hide()
                return
        }

        $("#import_guardrail_summary_text").html(html)
        $box.show()
}

function collectImportMismatchPrompts(warnings) {
        var prompts = []
        if (!$.isArray(warnings)) {
                return prompts
        }

        $.each(warnings, function (_, warning) {
                var text = String(warning || "")
                if (/Addon settings and settings for this raffle do not match/i.test(text)) {
                        prompts.push(text + " Continue with this import?")
                }
        })

        return prompts
}

function updateImportFileSummary(context) {
        var $box = $("#import_file_summary")
        var $text = $("#import_file_summary_text")

        if (!context || typeof context !== "object") {
                $text.text("")
                window.LAST_IMPORT_DEBUG_REPORT = ""
                $box.hide()
                return
        }

        function toNumber(value) {
                var n = Number(value)
                return isNaN(n) ? 0 : n
        }

        function normalizeRuleEnabled(value, fallbackValue) {
                if (value === null || value === undefined || value === "") {
                        return !!fallbackValue
                }
                return normalizeToggleEnabledValue(value)
        }

        function renderCategorySegment(label, amount, enabled) {
                if (!enabled) {
                        return '<span class="import-file-summary-segment">' + escapeHtml(label + ':') + ' <span class="import-file-summary-off">OFF</span></span>'
                }
                return '<span class="import-file-summary-segment">' + escapeHtml(label + ': ' + String(toNumber(amount).toLocaleString())) + '</span>'
        }

        var rows = $.isArray(context.import_rows) ? context.import_rows : []
        function getPreviewRowValue(item, key, fallbackIndex) {
                if (item && typeof item === "object" && !$.isArray(item)) {
                        return item[key]
                }
                if ($.isArray(item)) {
                        return item[fallbackIndex]
                }
                return ""
        }
        var mailGoldTickets = 0
        var bankGoldTickets = 0
        var mailBarterTickets = 0
        var bankBarterTickets = 0
        var importedUsers = {}
        for (var i = 0; i < rows.length; i++) {
                var item = rows[i] || []
                var paidAmount = toNumber(getPreviewRowValue(item, "paid_tickets", 1))
                var barterAmount = toNumber(getPreviewRowValue(item, "barter_tickets", -1))
                var subject = String(getPreviewRowValue(item, "subject", 2) || "")
                var sourceType = String(getPreviewRowValue(item, "source_type", "") || "").toUpperCase()
                var user = $.trim(String(getPreviewRowValue(item, "name", 0) || "")).toLowerCase()

                var isBank = (sourceType === "BANK") || (subject === "GUILD BANK DEPOSIT")

                if (isBank) {
                        bankGoldTickets += paidAmount
                        bankBarterTickets += barterAmount
                } else {
                        mailGoldTickets += paidAmount
                        mailBarterTickets += barterAmount
                }
                if (user) {
                        importedUsers[user] = true
                }
        }

        var existingTicketTotal = 0
        var existingEntrants = {}
        try {
                var hot = $("#ticket_info").handsontable("getInstance")
                var hotData = hot ? hot.getData() : []
                for (var j = 0; j < hotData.length; j++) {
                        var row = hotData[j] || []
                        var userName = $.trim(String(row[1] || "")).toLowerCase()
                        var totalTickets = toNumber(row[2])
                        if (totalTickets > 0) {
                                existingTicketTotal += totalTickets
                                if (userName) {
                                        existingEntrants[userName] = true
                                }
                        }
                }
        } catch (error) {
                console.warn("Unable to read current ticket table for import summary", error)
        }

        var addedEntrants = 0
        $.each(importedUsers, function (userName) {
                if (!existingEntrants[userName]) {
                        addedEntrants += 1
                }
        })

        var oldEntrantsCount = Object.keys(existingEntrants).length
        var totalImportedTickets = mailGoldTickets + bankGoldTickets + mailBarterTickets + bankBarterTickets
        var newTicketTotal = existingTicketTotal + totalImportedTickets
        var newEntrantsCount = oldEntrantsCount + addedEntrants
        var raffleRules = context.raffle_import_rules || {}
        var goldMailEnabled = normalizeRuleEnabled(raffleRules.raffle_gold_mail_enabled, true)
        var goldBankEnabled = normalizeRuleEnabled(raffleRules.raffle_gold_bank_enabled, true)
        var barterMailEnabled = normalizeRuleEnabled(raffleRules.raffle_barter_mail_enabled, false)
        var barterBankEnabled = normalizeRuleEnabled(raffleRules.raffle_barter_bank_enabled, false)

        var segments = []
        segments.push(renderCategorySegment("Mail-Gold", mailGoldTickets, goldMailEnabled))
        segments.push(renderCategorySegment("Bank-Gold", bankGoldTickets, goldBankEnabled))
        segments.push(renderCategorySegment("Mail-Barter", mailBarterTickets, barterMailEnabled))
        segments.push(renderCategorySegment("Bank-Barter", bankBarterTickets, barterBankEnabled))
        if (context.bank_source_guild_name) {
                segments.push('<span class="import-file-summary-segment">Bank Source: ' + escapeHtml(String(context.bank_source_guild_name)) + '</span>')
        }
        segments.push('<span class="import-file-summary-segment">Tickets: ' + escapeHtml(String(existingTicketTotal.toLocaleString())) + ' &gt; ' + escapeHtml(String(newTicketTotal.toLocaleString())) + '</span>')
        segments.push('<span class="import-file-summary-segment">Entrants: ' + escapeHtml(String(oldEntrantsCount.toLocaleString())) + ' &gt; ' + escapeHtml(String(newEntrantsCount.toLocaleString())) + '</span>')

        $text.html(segments.join(""))

        var debugPayload = {
                selected_account: context.selected_account || "",
                metadata_detected: !!context.metadata_detected,
                mail_row_count: context.mail_row_count,
                bank_row_count: context.bank_row_count,
                mail_source_account: context.mail_source_account || "",
                bank_source_guild_name: context.bank_source_guild_name || "",
                bank_source_guild_id: context.bank_source_guild_id || "",
                bank_selected_days: context.bank_selected_days || "",
                raffle_import_rules: raffleRules,
                suppressed_counts: context.suppressed_counts || {},
                addon_mail_barter_enabled: normalizeRuleEnabled(context.addon_mail_barter_enabled, false),
                addon_bank_barter_enabled: normalizeRuleEnabled(context.addon_bank_barter_enabled, false),
                rows_shown: rows.length,
                mail_gold_tickets_to_add: mailGoldTickets,
                bank_gold_tickets_to_add: bankGoldTickets,
                mail_barter_tickets_to_add: mailBarterTickets,
                bank_barter_tickets_to_add: bankBarterTickets,
                current_ticket_total: existingTicketTotal,
                projected_ticket_total: newTicketTotal,
                current_entrant_count: oldEntrantsCount,
                projected_entrant_count: newEntrantsCount
        }
        window.LAST_IMPORT_DEBUG_REPORT = JSON.stringify(debugPayload, null, 2)

        $box.show()
}

function populateConfirmModal(result) {
        var normalized = normalizeImportResult(result)
        $("#confirm_string").val(normalized.confirm_string)
        $("#confirm_names").val(normalized.confirm_names)
        updateConfirmImportSummary(normalized.import_summary)
}

function setGuildSettingsStatus(message, isError) {
        var $status = $("#guildSettingsStatus")
        $status.text(message || "")
        $status.removeClass("is-error is-pending is-success")
        if (!message) {
                return
        }
        if (isError) {
                $status.addClass("is-error")
        } else {
                $status.addClass("is-success")
        }
}

var GUILD_GAME_SERVER_OPTIONS = ["PC-NA", "PC-EU", "XBOX-NA", "XBOX-EU", "PS-NA", "PS-EU"]
var DEFAULT_GUILD_LOGO_URL = "https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif"
var DEFAULT_GUILD_FAVICON_URL = "/static/favicon-256.png"
var DEFAULT_GUILD_PRIMARY_COLOR = "#284CA6"
var DEFAULT_GUILD_ACCENT_COLOR = "#5078D2"
var GUILD_SETTINGS_DIRTY = false
var GUILD_SETTINGS_LOADING = false

function markGuildSettingsDirty() {
        if (GUILD_SETTINGS_LOADING) {
                return
        }
        GUILD_SETTINGS_DIRTY = true
        var $status = $("#guildSettingsStatus")
        $status.text("You have unsaved changes.")
        $status.removeClass("is-error is-success").addClass("is-pending")
}

function clearGuildSettingsDirty(message) {
        GUILD_SETTINGS_DIRTY = false
        setGuildSettingsStatus(message || "", false)
}

function normalizeEsoAccountName(value) {
        var text = $.trim(String(value || ""))
        if (!text) {
                return ""
        }
        return text.charAt(0) === "@" ? text : ("@" + text)
}

function buildGuildMailAccountRow(value) {
        var $row = $('<div class="guild-mail-account-row"></div>')
        var $input = $('<input type="text" class="guild-mail-account-input guild-settings-input" placeholder="@accountname" />').val(value || "")
        var $remove = $('<button type="button" class="manage-access-btn subtle">Remove</button>')
        $remove.on("click", function () {
                $row.remove()
                ensureGuildMailAccountRow()
                markGuildSettingsDirty()
        })
        $row.append($input, $remove)
        return $row
}

function buildGuildBlacklistRow(value) {
        var $row = $('<div class="guild-mail-account-row"></div>')
        var $input = $('<input type="text" class="guild-blacklist-input guild-settings-input" placeholder="@accountname" />').val(value || "")
        var $remove = $('<button type="button" class="manage-access-btn subtle">Remove</button>')
        $remove.on("click", function () {
                $row.remove()
                ensureGuildBlacklistRow()
                markGuildSettingsDirty()
        })
        $row.append($input, $remove)
        return $row
}

function ensureGuildMailAccountRow() {
        var $list = $("#guildSettingsMailAccountsList")
        if ($list.children().length === 0) {
                $list.append(buildGuildMailAccountRow(""))
        }
}

function renderGuildMailAccountRows(accounts) {
        var $list = $("#guildSettingsMailAccountsList")
        $list.empty()
        if (!$.isArray(accounts) || accounts.length === 0) {
                $list.append(buildGuildMailAccountRow(""))
                return
        }
        $.each(accounts, function (_, account) {
                $list.append(buildGuildMailAccountRow(account))
        })
}

function ensureGuildBlacklistRow() {
        var $list = $("#guildSettingsImportBlacklistList")
        if ($list.children().length === 0) {
                $list.append(buildGuildBlacklistRow(""))
        }
}

function renderGuildBlacklistRows(accounts) {
        var $list = $("#guildSettingsImportBlacklistList")
        $list.empty()
        if (!$.isArray(accounts) || accounts.length === 0) {
                $list.append(buildGuildBlacklistRow(""))
                return
        }
        $.each(accounts, function (_, account) {
                $list.append(buildGuildBlacklistRow(account ? ("@" + String(account).replace(/^@+/, "")) : ""))
        })
}

function collectGuildMailAccounts() {
        var accounts = []
        $("#guildSettingsMailAccountsList .guild-mail-account-input").each(function () {
                var value = normalizeEsoAccountName($(this).val())
                if (value) {
                        accounts.push(value)
                }
        })
        return accounts
}

function collectGuildImportBlacklist() {
        var accounts = []
        $("#guildSettingsImportBlacklistList .guild-blacklist-input").each(function () {
                var value = normalizeEsoAccountName($(this).val())
                if (value) {
                        accounts.push(value)
                }
        })
        return accounts
}

function populateGuildServerOptions(selectedValue) {
        var $select = $("#guildSettingsGameServer")
        $select.empty()
        $.each(GUILD_GAME_SERVER_OPTIONS, function (_, optionValue) {
                var $option = $("<option></option>").attr("value", optionValue).text(optionValue)
                if (optionValue === selectedValue) {
                        $option.prop("selected", true)
                }
                $select.append($option)
        })
}

function getSupportedTimeZones() {
        var fallbackZones = [
                "America/New_York",
                "America/Chicago",
                "America/Denver",
                "America/Los_Angeles",
                "America/Phoenix",
                "America/Anchorage",
                "Pacific/Honolulu",
                "Europe/London",
                "Europe/Paris",
                "Europe/Berlin",
                "Australia/Sydney",
                "Asia/Tokyo"
        ]
        var zones = []
        if (typeof Intl !== "undefined" && typeof Intl.supportedValuesOf === "function") {
                try {
                        zones = Intl.supportedValuesOf("timeZone") || []
                } catch (error) {
                        zones = []
                }
        }
        if (!zones.length) {
                zones = fallbackZones.slice()
        }
        return zones
}

function populateTimeZoneOptions(selectSelector, selectedValue, includeBrowserOption) {
        var zones = getSupportedTimeZones()
        if (selectedValue && zones.indexOf(selectedValue) === -1) {
                zones.unshift(selectedValue)
        }
        var $select = $(selectSelector)
        $select.empty()
        if (includeBrowserOption) {
                var browserLabel = "Use Browser Local Time"
                var $browserOption = $("<option></option>").attr("value", "browser").text(browserLabel)
                if (!selectedValue || selectedValue === "browser") {
                        $browserOption.prop("selected", true)
                }
                $select.append($browserOption)
        }
        $.each(zones, function (_, zoneValue) {
                var $option = $("<option></option>").attr("value", zoneValue).text(zoneValue)
                if (zoneValue === selectedValue) {
                        $option.prop("selected", true)
                }
                $select.append($option)
        })
}

function populateGuildTimeZoneOptions(selectedValue) {
        populateTimeZoneOptions("#guildSettingsTimeZone", selectedValue, false)
}

function populateAccountTimeZoneOptions(selectedValue) {
        populateTimeZoneOptions("#accountSettingsTimeZone", selectedValue || "browser", true)
}

function renderGuildSisterGuilds(options, currentShortname, selectedValues) {
        var selectedSet = {}
        $.each(selectedValues || [], function (_, value) {
                selectedSet[String(value || "").toLowerCase()] = true
        })
        var $list = $("#guildSettingsSisterGuilds")
        $list.empty()
        $.each(options || [], function (_, guild) {
                var shortname = String(guild.guild_shortname || "").toLowerCase()
                if (!shortname || shortname === String(currentShortname || "").toLowerCase()) {
                        return
                }
                var $label = $('<label class="manage-access-checkbox"></label>')
                var $input = $('<input type="checkbox" class="guild-sister-checkbox" />').val(shortname)
                if (selectedSet[shortname]) {
                        $input.prop("checked", true)
                }
                $label.append($input).append(" " + (guild.guild_name || shortname))
                $list.append($label)
        })
        if ($list.children().length === 0) {
                $list.append('<p class="guild-settings-help is-inline">No other guilds are available to link yet.</p>')
        }
}

function collectSelectedSisterGuilds() {
        var sisterGuilds = []
        $("#guildSettingsSisterGuilds .guild-sister-checkbox:checked").each(function () {
                var value = $.trim(String($(this).val() || "")).toLowerCase()
                if (value) {
                        sisterGuilds.push(value)
                }
        })
        return sisterGuilds
}

function applyGuildBranding(guild) {
        guild = guild || {}
        var logoUrl = $.trim(String(guild.guild_logo_url || "")) || DEFAULT_GUILD_LOGO_URL
        var faviconUrl = $.trim(String(guild.guild_favicon_url || "")) || DEFAULT_GUILD_FAVICON_URL
        var primaryColor = normalizeBrandColor(guild.guild_primary_color, DEFAULT_GUILD_PRIMARY_COLOR)
        var accentColor = normalizeBrandColor(guild.guild_accent_color, DEFAULT_GUILD_ACCENT_COLOR)
        $("#mainLogo").attr("src", logoUrl)
        $("#adminProfileLogo").attr("src", logoUrl)
        updateAppFavicons(faviconUrl)
        applyBrandColors(primaryColor, accentColor)
}

function updateGuildLogoPreview(urlValue) {
        var logoUrl = $.trim(String(urlValue || "")) || DEFAULT_GUILD_LOGO_URL
        $("#guildSettingsLogoPreview").attr("src", logoUrl)
}

function updateGuildFaviconPreview(urlValue) {
        var faviconUrl = $.trim(String(urlValue || "")) || DEFAULT_GUILD_FAVICON_URL
        $("#guildSettingsFaviconPreview").attr("src", faviconUrl)
}

function normalizeBrandColor(value, fallback) {
        var raw = $.trim(String(value || ""))
        if (!raw) {
                return fallback
        }
        if (raw.charAt(0) !== "#") {
                raw = "#" + raw
        }
        if (!/^#[0-9a-fA-F]{6}$/.test(raw)) {
                return fallback
        }
        return raw.toUpperCase()
}

function hexToRgbList(hexValue) {
        var hex = normalizeBrandColor(hexValue, "#000000").slice(1)
        return [
                parseInt(hex.slice(0, 2), 16),
                parseInt(hex.slice(2, 4), 16),
                parseInt(hex.slice(4, 6), 16)
        ].join(",")
}

function applyBrandColors(primaryColor, accentColor) {
        var root = document.documentElement
        var normalizedPrimary = normalizeBrandColor(primaryColor, DEFAULT_GUILD_PRIMARY_COLOR)
        var normalizedAccent = normalizeBrandColor(accentColor, DEFAULT_GUILD_ACCENT_COLOR)
        root.style.setProperty("--brand-primary", normalizedPrimary)
        root.style.setProperty("--brand-accent", normalizedAccent)
        root.style.setProperty("--brand-primary-rgb", hexToRgbList(normalizedPrimary))
        root.style.setProperty("--brand-accent-rgb", hexToRgbList(normalizedAccent))
}

function updateAppFavicons(faviconUrl) {
        $("#appFaviconIco").attr("href", faviconUrl)
        $("#appFavicon32").attr("href", faviconUrl)
        $("#appFavicon16").attr("href", faviconUrl)
}

function renderProfileGuildLinks(currentShortname, sisterGuilds, guildChoices) {
        var $container = $("#profileGuildLinks")
        $container.empty()
        var currentSlug = String(currentShortname || "").toLowerCase()
        var selected = {}
        $.each(sisterGuilds || [], function (_, shortname) {
                selected[String(shortname || "").toLowerCase()] = true
        })
        $.each(guildChoices || [], function (_, guild) {
                var shortname = String(guild.guild_shortname || "").toLowerCase()
                var reverseLinks = {}
                $.each(String(guild.guild_sister_guilds || "").split(","), function (_, value) {
                        var slug = $.trim(String(value || "")).toLowerCase()
                        if (slug) {
                                reverseLinks[slug] = true
                        }
                })
                var shouldShow = selected[shortname] || reverseLinks[currentSlug]
                if (!shortname || shortname === currentSlug || !shouldShow) {
                        return
                }
                var $link = $('<a class="profile-menu-item"></a>').attr("href", "/" + shortname + "/")
                $link.append(
                        '<span class="profile-menu-icon"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 12h18"></path><path d="M15 5l6 7-6 7"></path></svg></span>'
                )
                $link.append($('<span class="profile-menu-text"></span>').text("Swap to " + (guild.guild_name || shortname.toUpperCase())))
                $container.append($link)
        })
        $("#profileGuildLinksSection").toggle($container.children().length > 0)
}

var BOUNTY_LIST_DIRTY = false
var BOUNTY_LIST_LOADING = false

function formatCommaNumber(value) {
        var raw = $.trim(String(value || ""))
        if (!raw) {
                return ""
        }
        raw = raw.replace(/,/g, "")
        if (!/^\d+$/.test(raw)) {
                return $.trim(String(value || ""))
        }
        return raw.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
}

function normalizeNumberString(value, fallbackValue) {
        var raw = $.trim(String(value || ""))
        if (!raw) {
                return fallbackValue
        }
        return raw.replace(/,/g, "")
}

function setBountyListDirtyStatus(message, statusClass) {
        var $status = $("#bountyListStatus")
        $status.text(message || "")
        $status.removeClass("is-error is-success is-pending")
        if (statusClass) {
                $status.addClass(statusClass)
        }
}

function markBountyListDirty() {
        if (BOUNTY_LIST_LOADING) {
                return
        }
        BOUNTY_LIST_DIRTY = true
        setBountyListDirtyStatus("You have unsaved changes.", "is-pending")
}

function clearBountyListDirty(message) {
        BOUNTY_LIST_DIRTY = false
        if (!message) {
                setBountyListDirtyStatus("", "")
                return
        }
        setBountyListDirtyStatus(message, "is-success")
}

function showGuildSettingsModal() {
        GUILD_SETTINGS_LOADING = true
        clearGuildSettingsDirty("")
        hideLegacyModal("#account_settings_template")
        $.when($.getJSON("json/get/guild"), $.getJSON("json/get/guild_choices")).done(function (guildResponse, choicesResponse) {
                var result = guildResponse[0] || {}
                var choices = (choicesResponse[0] && choicesResponse[0].guilds) || []
                $("#guildSettingsName").val(result.guild_name || "")
                $("#guildSettingsShortname").val(result.guild_shortname || "")
                $("#guildSettingsEsoId").val(result.guild_eso_id || "")
                $("#guildSettingsLogoUrl").val(result.guild_logo_url || "")
                $("#guildSettingsFaviconUrl").val(result.guild_favicon_url || "")
                $("#guildSettingsPrimaryColor").val(normalizeBrandColor(result.guild_primary_color, DEFAULT_GUILD_PRIMARY_COLOR))
                $("#guildSettingsAccentColor").val(normalizeBrandColor(result.guild_accent_color, DEFAULT_GUILD_ACCENT_COLOR))
                updateGuildLogoPreview(result.guild_logo_url || "")
                updateGuildFaviconPreview(result.guild_favicon_url || "")
                populateGuildTimeZoneOptions(result.guild_timezone || "America/New_York")
                populateGuildServerOptions(result.guild_game_server || "PC-NA")
                renderGuildMailAccountRows(result.guild_expected_mail_accounts || [])
                renderGuildBlacklistRows(result.guild_import_blacklist || [])
                renderGuildSisterGuilds(choices, result.guild_shortname || "", result.guild_sister_guilds || [])
                GUILD_SETTINGS_LOADING = false
                clearGuildSettingsDirty("")
                showLegacyModal("#guild_settings_template", "confirm")
        }).fail(function () {
                setGuildSettingsStatus("Unable to load guild settings right now.", true)
                updateGuildLogoPreview("")
                updateGuildFaviconPreview("")
                $("#guildSettingsFaviconUrl").val("")
                $("#guildSettingsPrimaryColor").val(DEFAULT_GUILD_PRIMARY_COLOR)
                $("#guildSettingsAccentColor").val(DEFAULT_GUILD_ACCENT_COLOR)
                populateGuildTimeZoneOptions("America/New_York")
                populateGuildServerOptions("PC-NA")
                renderGuildMailAccountRows([])
                renderGuildBlacklistRows([])
                renderGuildSisterGuilds([], "", [])
                GUILD_SETTINGS_LOADING = false
                showLegacyModal("#guild_settings_template", "confirm")
        })
}

function setBountyListStatus(message, isError) {
        setBountyListDirtyStatus(message || "", isError ? "is-error" : (message ? "is-success" : ""))
}

  function buildBountyListRow(item) {
        item = item || {}
        var $row = $('<tr class="bounty-list-row"></tr>')
        var $name = $('<input type="text" class="guild-settings-input bounty-item-name" placeholder="Item Name" />').val(item.item_name || "")
        var $code = $('<input type="text" class="guild-settings-input bounty-item-code" placeholder="item code" />').val(item.item_code || "")
        var $quantity = $('<input type="number" min="1" step="1" class="guild-settings-input bounty-item-quantity" placeholder="1" />').val(item.quantity || 1)
        var $value = $('<input type="text" class="guild-settings-input bounty-item-value" placeholder="0" inputmode="numeric" />').val(formatCommaNumber(item.item_value || 0))
        var $rate = $('<input type="number" min="0" step="1" class="guild-settings-input bounty-item-rate" placeholder="0" />').val(item.barter_rate || 0)
        var $remove = $('<button type="button" class="manage-access-btn subtle">Remove</button>')
        $remove.on("click", function () {
                $row.remove()
                markBountyListDirty()
        })
        $value.on("blur", function () {
                $(this).val(formatCommaNumber($(this).val()))
        })
        $row.append(
                $("<td></td>").append($name),
                $("<td></td>").append($code),
                $("<td></td>").append($quantity),
                $("<td></td>").append($value),
                $("<td></td>").append($rate),
                $("<td></td>").append($remove)
        )
        return $row
  }

function renderBountyListRows(items) {
        var $list = $("#bountyListRows")
        $list.empty()
        $.each(items || [], function (_, item) {
                $list.append(buildBountyListRow(item))
        })
        if (!$list.children().length) {
                $list.append(buildBountyListRow({}))
        }
}

function collectBountyListRows() {
        var rows = []
        $("#bountyListRows .bounty-list-row").each(function () {
                var item = {
                        item_name: $.trim($(this).find(".bounty-item-name").val() || ""),
                        item_code: $.trim($(this).find(".bounty-item-code").val() || ""),
                        quantity: $.trim($(this).find(".bounty-item-quantity").val() || ""),
                        item_value: normalizeNumberString($(this).find(".bounty-item-value").val(), ""),
                        barter_rate: $.trim($(this).find(".bounty-item-rate").val() || "")
                }
                if (item.item_name || item.item_code || item.quantity || item.item_value || item.barter_rate) {
                        rows.push(item)
                }
        })
        return rows
}

function parseBountyImportText(raw) {
        var lines = String(raw || "").split(/\r?\n/)
        var rows = []
        $.each(lines, function (_, line) {
                var trimmed = $.trim(line)
                if (!trimmed) {
                        return
                }
                var cols = trimmed.split("\t")
                if (cols.length < 2) {
                        cols = trimmed.split(/\s{2,}/)
                }
                cols = $.map(cols, function (value) { return $.trim(value) })
                if (cols.length < 2) {
                        return
                }
                var first = String(cols[0] || "").toLowerCase()
                var second = String(cols[1] || "").toLowerCase()
                if ((first === "item" || first === "item name" || first === "name") && (second === "item code" || second === "code")) {
                        return
                }
                rows.push({
                        item_name: cols[0] || "",
                        item_code: cols[1] || "",
                        quantity: cols.length > 2 ? (cols[2] || "1") : "1",
                        item_value: cols.length > 3 ? normalizeNumberString(cols[3] || "0", "0") : "0",
                        barter_rate: cols.length > 4 ? (cols[4] || "0") : "0"
                })
        })
        return rows
}

function applyBountyImportText() {
        var parsed = parseBountyImportText($("#bountyListPasteInput").val())
        if (!parsed.length) {
                setBountyListStatus("No valid bounty rows were found in the pasted text.", true)
                return
        }
        renderBountyListRows(parsed)
        BOUNTY_LIST_DIRTY = true
        setBountyListDirtyStatus("You have unsaved changes.", "is-pending")
}

function copyBountyListToSpreadsheet() {
        var rows = collectBountyListRows()
        var $button = $("#copyBountyListButton")
        var originalText = $button.text()
        var payload = ["Item Name\tItem Code\tQuantity\tItem Value\tBarter Rate"]
        $.each(rows, function (_, item) {
                payload.push([
                        item.item_name || "",
                        item.item_code || "",
                        item.quantity || "",
                        item.item_value || "",
                        item.barter_rate || ""
                ].join("\t"))
        })
        navigator.clipboard.writeText(payload.join("\n")).then(function () {
                setBountyListStatus("Bounty list copied to clipboard.", false)
                $button.text("Copied")
                window.setTimeout(function () {
                        $button.text(originalText)
                }, 2400)
        }).catch(function () {
                setBountyListStatus("Could not copy the bounty list automatically.", true)
        })
}

function showBountyListModal() {
        BOUNTY_LIST_LOADING = true
        clearBountyListDirty("")
        $("#bountyListPasteInput").val("")
        $.getJSON("json/get/barter_bounty_list", function (result) {
                renderBountyListRows(result.items || [])
                BOUNTY_LIST_LOADING = false
                clearBountyListDirty("")
                showLegacyModal("#bounty_list_template", "confirm")
        }).fail(function () {
                renderBountyListRows([])
                BOUNTY_LIST_LOADING = false
                setBountyListStatus("Unable to load the bounty list right now.", true)
                showLegacyModal("#bounty_list_template", "confirm")
        })
}

function saveBountyList() {
        setBountyListStatus("Saving...", false)
        $.ajax({
                type: "POST",
                url: "json/set/barter_bounty_list",
                data: {
                        items_json: JSON.stringify(collectBountyListRows())
                },
                success: function (result) {
                        if (result.error) {
                                setBountyListStatus(result.error, true)
                                return
                        }
                        renderBountyListRows(result.items || [])
                        $("#bountyListPasteInput").val("")
                        clearBountyListDirty("Barter bounty list saved.")
                },
                error: function () {
                        setBountyListStatus("Save failed.", true)
                }
        })
}

function saveGuildSettings() {
        var accounts = collectGuildMailAccounts()
        var blacklist = collectGuildImportBlacklist()
        setGuildSettingsStatus("Saving...", false)
        $.ajax({
                type: "POST",
                url: "json/set/guild_settings",
                data: {
                        guild_name: $("#guildSettingsName").val(),
                        guild_shortname: $("#guildSettingsShortname").val(),
                        guild_eso_id: $("#guildSettingsEsoId").val(),
                        guild_logo_url: $("#guildSettingsLogoUrl").val(),
                        guild_favicon_url: $("#guildSettingsFaviconUrl").val(),
                        guild_primary_color: $("#guildSettingsPrimaryColor").val(),
                        guild_accent_color: $("#guildSettingsAccentColor").val(),
                        guild_timezone: $("#guildSettingsTimeZone").val(),
                        guild_game_server: $("#guildSettingsGameServer").val(),
                        guild_sister_guilds: collectSelectedSisterGuilds().join(","),
                        guild_expected_mail_accounts: accounts.join(","),
                        guild_import_blacklist: blacklist.join(",")
                },
                success: function (result) {
                        if (result.error) {
                                setGuildSettingsStatus(result.error, true)
                                return
                        }
                        var guild = result.guild || {}
                        $("#guild_header").text(guild.guild_name || "")
                        $("#display_guild_header").text(guild.guild_name || "")
                        applyGuildBranding(guild)
                        if (guild.guild_shortname && guild.guild_shortname !== ADMIN_GUILD_SLUG) {
                                clearGuildSettingsDirty("Guild settings saved. Redirecting to the new guild URL...")
                                window.setTimeout(function () {
                                        window.location.href = "/" + guild.guild_shortname + "/"
                                }, 700)
                                return
                        }
                        clearGuildSettingsDirty("Guild settings saved.")
                },
                error: function () {
                        setGuildSettingsStatus("Save failed.", true)
                }
        })
}

function buildImportTimeLabel(item) {
        try {
                var isObjectRow = (item && typeof item === "object" && !$.isArray(item))
                var subject = isObjectRow ? (item.subject || "") : (item[2] || "")
                var sourceType = isObjectRow ? String(item.source_type || "").toUpperCase() : ((subject === "GUILD BANK DEPOSIT") ? "BANK" : "MAIL")
                var paidTickets = isObjectRow ? Number(item.paid_tickets || 0) : Number(item[1] || 0)
                var barterTickets = isObjectRow ? Number(item.barter_tickets || 0) : 0
                var sourceLabel = "[Mail]"

                if (barterTickets > 0 && paidTickets > 0) {
                        sourceLabel = (sourceType === "BANK") ? "[Gold+Barter-Bank]" : "[Gold+Barter-Mail]"
                } else if (barterTickets > 0) {
                        sourceLabel = (sourceType === "BANK") ? "[Barter-Bank]" : "[Barter-Mail]"
                } else if (paidTickets > 0) {
                        sourceLabel = (sourceType === "BANK") ? "[Gold-Bank]" : "[Gold-Mail]"
                } else if (sourceType === "BANK") {
                        sourceLabel = "[Gold-Bank]"
                }

                var rawValue = isObjectRow ? item.timestamp : item[3]
                var timestampLabel = ""
                if (rawValue !== null && rawValue !== undefined && rawValue !== "") {
                        var epochSeconds = Number(rawValue)
                        if (!isNaN(epochSeconds) && epochSeconds > 0) {
                                timestampLabel = formatAdminDateTime(epochSeconds, false)
                        } else {
                                timestampLabel = $.trim(String(rawValue))
                        }
                }
                return timestampLabel ? (sourceLabel + " " + timestampLabel) : sourceLabel
        } catch (error) {
                console.warn("Failed to build import time label", error, item)
                return "[Gold-Mail]"
        }
}

function buildBarterItemSummary(barterItems) {
        if (!$.isArray(barterItems) || !barterItems.length) {
                return ""
        }

        var parts = []
        for (var i = 0; i < barterItems.length; i++) {
                var row = barterItems[i] || {}
                var itemName = $.trim(String(row.item_name || row.name || ""))
                var quantity = Number(row.quantity || row.qty || 0)
                if (!itemName) {
                        continue
                }
                if (quantity > 0) {
                        parts.push(quantity.toLocaleString() + "x " + itemName)
                } else {
                        parts.push(itemName)
                }
        }

        return parts.join(", ")
}

var ADMIN_ACCOUNT_SETTINGS = {
        timezone: ${repr(getattr(request.user, "timezone", None) or "") | n},
        datetime_format: ${repr(getattr(request.user, "datetime_format", "us_12") or "us_12") | n}
}

function getAdminDateTimeFormatConfig() {
        var formatKey = String(ADMIN_ACCOUNT_SETTINGS.datetime_format || "us_12").toLowerCase()
        var configs = {
                us_12: { locale: "en-US", hour12: true },
                us_24: { locale: "en-US", hour12: false },
                intl_12: { locale: "en-GB", hour12: true },
                intl_24: { locale: "en-GB", hour12: false }
        }
        return configs[formatKey] || configs.us_12
}

function formatAdminDateTime(epochSeconds, includeTimeZoneName) {
        var value = Number(epochSeconds)
        if (isNaN(value) || value <= 0) {
                return ""
        }
        var formatConfig = getAdminDateTimeFormatConfig()
        var options = {
                month: "numeric",
                day: "numeric",
                year: "numeric",
                hour: "numeric",
                minute: "2-digit",
                second: "2-digit",
                hour12: formatConfig.hour12
        }
        var timezoneValue = $.trim(String(ADMIN_ACCOUNT_SETTINGS.timezone || ""))
        if (timezoneValue && timezoneValue !== "browser") {
                options.timeZone = timezoneValue
        }
        if (includeTimeZoneName) {
                options.timeZoneName = "short"
        }
        try {
                return new Date(value * 1000).toLocaleString(formatConfig.locale, options)
        } catch (error) {
                console.warn("Failed to format admin datetime with preferred timezone", error, options)
                delete options.timeZone
                return new Date(value * 1000).toLocaleString(formatConfig.locale, options)
        }
}

function formatAdminTimestamp(epochSeconds) {
        return formatAdminDateTime(epochSeconds, true)
}

function normalizeEasternTimeLabel(value) {
        var text = $.trim(String(value || ""))
        if (!text) {
                return ""
        }
        var easternShort = new Intl.DateTimeFormat("en-US", {
                timeZone: "America/New_York",
                timeZoneName: "short"
        }).formatToParts(new Date()).find(function (part) {
                return part.type === "timeZoneName"
        })
        var currentEastern = easternShort ? easternShort.value : "ET"
        return text.replace(/\bEDT\b|\bEST\b/g, currentEastern)
}

function buildRaffleHeaderParts(raffleNumber, raffleTitle, raffleTime) {
        var numberText = $.trim(String(raffleNumber || ""))
        var titleText = $.trim(String(raffleTitle || ""))
        var timeText = normalizeEasternTimeLabel(raffleTime)
        var headingText = ""
        var trailingText = ""

        if (titleText) {
                headingText = "#" + numberText
                trailingText = titleText + (timeText ? " • " + timeText : "")
        } else {
                headingText = "#" + numberText + " Raffle"
                trailingText = timeText ? "Drawing: " + timeText : ""
        }

        return {
                heading: headingText,
                trailing: trailingText,
                separator: (headingText && trailingText) ? " • " : ""
        }
}

var ADMIN_GUILD_SLUG = "${request.matchdict.get('guild', '')}"
var IMPORT_HISTORY_PREFIX = "raffle_import_history:"

function getCurrentImportHistoryKey() {
        var raffleNumber = normalizeFieldValue(CURRENT_RAFFLE_INFO.raffle_subheader)
        if (!ADMIN_GUILD_SLUG || !raffleNumber) {
                return null
        }
        return IMPORT_HISTORY_PREFIX + ADMIN_GUILD_SLUG + ":" + raffleNumber
}

function loadImportHistoryForCurrentRaffle() {
        var key = getCurrentImportHistoryKey()
        if (!key) {
                return []
        }

        try {
                var raw = window.localStorage.getItem(key)
                var parsed = raw ? JSON.parse(raw) : []
                return Array.isArray(parsed) ? parsed : []
        } catch (error) {
                return []
        }
}

function saveImportHistoryForCurrentRaffle(entries) {
        var key = getCurrentImportHistoryKey()
        if (!key) {
                return
        }
        window.localStorage.setItem(key, JSON.stringify(entries || []))
}

function pruneImportHistoryToCurrentRaffle() {
        var currentKey = getCurrentImportHistoryKey()
        if (!currentKey || !window.localStorage) {
                return
        }

        var prefix = IMPORT_HISTORY_PREFIX + ADMIN_GUILD_SLUG + ":"
        for (var i = window.localStorage.length - 1; i >= 0; i--) {
                var key = window.localStorage.key(i)
                if (!key || key.indexOf(prefix) !== 0) {
                        continue
                }
                if (key !== currentKey) {
                        window.localStorage.removeItem(key)
                }
        }
}

function storeImportBatch(importKind, result) {
        var normalized = normalizeImportResult(result)
        if (!normalized.confirm_string && !normalized.confirm_names) {
                return
        }

        var entries = loadImportHistoryForCurrentRaffle()
        entries.unshift({
                id: String(Date.now()),
                kind: importKind || "import",
                saved_at: new Date().toISOString(),
                confirm_string: normalized.confirm_string,
                confirm_names: normalized.confirm_names,
                import_summary: normalized.import_summary
        })
        saveImportHistoryForCurrentRaffle(entries.slice(0, 12))
}

function formatRecentImportTime(isoValue) {
        if (!isoValue) {
                return ""
        }
        var date = new Date(isoValue)
        if (isNaN(date.getTime())) {
                return ""
        }
        return date.toLocaleString([], { month: "numeric", day: "numeric", hour: "numeric", minute: "2-digit" })
}

function formatImportKindLabel(kind) {
        if (kind === "lua") return "Lua Import"
        if (kind === "paid") return "Paid Import"
        if (kind === "barter") return "Barter Import"
        return "Import"
}

function reopenStoredImport(index) {
        var entries = loadImportHistoryForCurrentRaffle()
        var entry = entries[index]
        if (!entry) {
                alert("That saved import batch is no longer available.")
                return
        }

        hideLegacyModal("#recent_imports_template")
        hideLegacyModal("#barter_template")
        hideLegacyModal("#paid_template")
        showLegacyModal("#confirm_template", "confirm")
        populateConfirmModal(entry)
}

function renderRecentImportsList() {
        var entries = loadImportHistoryForCurrentRaffle()
        var $host = $("#recent_imports_data")
        $host.empty()

        if (!entries.length) {
                $host.append('<div class="recent-import-empty">No saved import batches for this raffle yet.</div>')
                return
        }

        entries.forEach(function (entry, index) {
                var summaryText = formatImportSummaryText(entry.import_summary) || "Saved import batch."
                $host.append(
                        '<div class="recent-import-item">' +
                        '  <div class="recent-import-top">' +
                        '    <div class="recent-import-kind">' + escapeHtml(formatImportKindLabel(entry.kind)) + '</div>' +
                        '    <div class="recent-import-time">' + escapeHtml(formatRecentImportTime(entry.saved_at)) + '</div>' +
                        '  </div>' +
                        '  <div class="recent-import-summary">' + escapeHtml(summaryText) + '</div>' +
                        '  <div class="recent-import-actions"><button type="button" class="recent-import-open" onclick="reopenStoredImport(' + index + ')">Open</button></div>' +
                        '</div>'
                )
        })
}

function showRecentImportsModal() {
        renderRecentImportsList()
        hideLegacyModal("#account_settings_template")
        hideLegacyModal("#manage_access_template")
        hideLegacyModal("#confirm_template")
        hideLegacyModal("#import_template")
        hideLegacyModal("#barter_template")
        hideLegacyModal("#paid_template")
        showLegacyModal("#recent_imports_template", "confirm")
}

function formatBarterSummaryValue(value) {
        var parsed = Number(value) || 0
        return parsed.toLocaleString()
}

function renderBarterSummary(result) {
        var rows = (result && result.rows) || []
        var totals = (result && result.totals) || {}
        var $host = $("#barter_summary_data")
        $host.empty()

        if (!rows.length) {
                $host.append('<div class="recent-import-empty">No barter items have been accepted for this raffle yet.</div>')
                return
        }

        var html = ''
        html += '<div class="barter-summary-shell">'
        html += '  <div class="barter-summary-toolbar"><button type="button" class="manage-access-btn subtle" id="copyBarterSummaryButton" onclick="copyBarterSummaryToSpreadsheet()">Copy to Spreadsheet</button></div>'
        html += '  <table class="barter-summary-table">'
        html += '    <thead><tr><th>Item Name</th><th>Total Bartered</th><th>Total Row Value</th></tr></thead>'
        html += '    <tbody>'
        rows.forEach(function (row) {
                html += '      <tr>'
                html += '        <td>' + escapeHtml(row.item_name || '') + '</td>'
                html += '        <td>' + escapeHtml(formatBarterSummaryValue(row.total_bartered)) + '</td>'
                html += '        <td>' + escapeHtml(formatBarterSummaryValue(row.total_row_value)) + '</td>'
                html += '      </tr>'
        })
        html += '      <tr class="barter-summary-total-row">'
        html += '        <td>TOTAL</td>'
        html += '        <td>' + escapeHtml(formatBarterSummaryValue(totals.total_bartered)) + '</td>'
        html += '        <td>' + escapeHtml(formatBarterSummaryValue(totals.total_row_value)) + '</td>'
        html += '      </tr>'
        html += '    </tbody>'
        html += '  </table>'
        html += '</div>'
        $host.append(html)
}

function copyBarterSummaryToSpreadsheet() {
        $.getJSON("json/get/barter_summary", function (result) {
                var rows = (result && result.rows) || []
                var totals = (result && result.totals) || {}
                var lines = ["Item Name\tTotal Bartered\tTotal Row Value"]
                rows.forEach(function (row) {
                        lines.push([
                                row.item_name || "",
                                formatBarterSummaryValue(row.total_bartered),
                                formatBarterSummaryValue(row.total_row_value)
                        ].join("\t"))
                })
                lines.push([
                        "TOTAL",
                        formatBarterSummaryValue(totals.total_bartered),
                        formatBarterSummaryValue(totals.total_row_value)
                ].join("\t"))
                var text = lines.join("\n")
                navigator.clipboard.writeText(text).then(function () {
                        var $button = $("#copyBarterSummaryButton")
                        $button.text("Copied")
                        window.setTimeout(function () { $button.text("Copy to Spreadsheet") }, 1800)
                }).catch(function () {
                        alert("Could not copy the barter summary automatically.")
                })
        }).fail(function () {
                alert("Unable to load the barter summary right now.")
        })
}

function showBarterSummaryModal() {
        $.getJSON("json/get/barter_summary", function (result) {
                renderBarterSummary(result || {})
                hideLegacyModal("#account_settings_template")
                hideLegacyModal("#manage_access_template")
                hideLegacyModal("#guild_settings_template")
                hideLegacyModal("#bounty_list_template")
                hideLegacyModal("#recent_imports_template")
                hideLegacyModal("#confirm_template")
                hideLegacyModal("#import_template")
                hideLegacyModal("#barter_template")
                hideLegacyModal("#paid_template")
                showLegacyModal("#barter_summary_template", "confirm")
        }).fail(function () {
                alert("Unable to load the barter summary right now.")
        })
}

var ACCESS_MANAGER_STATE = {
        users: [],
        guilds: []
}

function setPasswordFieldsVisible(fieldIds, visible) {
        fieldIds.forEach(function (fieldId) {
                var field = document.getElementById(fieldId)
                if (field) {
                        field.type = visible ? "text" : "password"
                }
        })
}

function renderAccessManager() {
        var $host = $("#manage_access_users")
        $host.empty()

        if (!ACCESS_MANAGER_STATE.users.length) {
                $host.append('<div class="recent-import-empty">No admin users found.</div>')
                return
        }

        ACCESS_MANAGER_STATE.users.forEach(function (user) {
                var guildMarkup = ACCESS_MANAGER_STATE.guilds.map(function (guild) {
                        var checked = user.guild_admins.indexOf(guild.guild_shortname) >= 0 ? ' checked' : ''
                        return '<label class="manage-access-checkbox"><input type="checkbox" class="manage-access-guild" data-auth-id="' + user.auth_id + '" value="' + escapeHtml(guild.guild_shortname) + '"' + checked + ' /> <span>' + escapeHtml(guild.guild_shortname.toUpperCase()) + '</span></label>'
                }).join("")

                var roleParts = []
                if (user.is_owner) {
                        roleParts.push("Owner")
                }
                if (user.is_superadmin) {
                        roleParts.push("Superadmin")
                }
                if (user.guild_admins.length) {
                        roleParts.push("Guild admin: " + user.guild_admins.join(", "))
                }
                if (!roleParts.length) {
                        roleParts.push("No admin roles assigned")
                }

                $host.append(
                        '<div class="manage-access-user" data-auth-id="' + user.auth_id + '">' +
                        '  <div class="manage-access-user-top">' +
                        '    <div>' +
                        '      <div class="manage-access-username">' + escapeHtml(user.auth_name) + '</div>' +
                        '      <div class="manage-access-roleline">' + escapeHtml(roleParts.join(" | ")) + '</div>' +
                        '    </div>' +
                        '  </div>' +
                        '  <div class="manage-access-controls">' +
                        '    <label class="manage-access-checkbox"><input type="checkbox" class="manage-access-superadmin" data-auth-id="' + user.auth_id + '"' + (user.is_superadmin ? ' checked' : '') + ' /> <span>Superadmin</span></label>' +
                        '    <div class="manage-access-guilds">' + guildMarkup + '</div>' +
                        '  </div>' +
                        '  <div class="manage-access-actions">' +
                        '    <button type="button" class="manage-access-btn" onclick="resetAccessUserPassword(' + user.auth_id + ', \'' + escapeHtml(user.auth_name) + '\')">Reset Password</button>' +
                        '    <button type="button" class="manage-access-btn" onclick="saveAccessUser(' + user.auth_id + ')">Save Access</button>' +
                        '    <button type="button" class="manage-access-btn is-danger" onclick="deleteAccessUser(' + user.auth_id + ', \'' + escapeHtml(user.auth_name) + '\')">Delete User</button>' +
                        '  </div>' +
                        '</div>'
                )
        })
}

function setAccessManagerStatus(message, isError) {
        var $status = $("#manageAccessStatus")
        $status.text(message || "")
        $status.css("color", isError ? "#8b1e1e" : "#536476")
}

function renderAccessCreateGuilds() {
        var $host = $("#manageAccessCreateGuilds")
        $host.empty()
        ACCESS_MANAGER_STATE.guilds.forEach(function (guild) {
                $host.append('<label class="manage-access-checkbox"><input type="checkbox" value="' + escapeHtml(guild.guild_shortname) + '" /> <span>' + escapeHtml(guild.guild_shortname.toUpperCase()) + '</span></label>')
        })
}

function loadAccessManagerModal(statusMessage, isError) {
        setAccessManagerStatus("Loading users...", false)
        $.getJSON("json/get/auth_users", function (result) {
                if (isActionError(result)) {
                        setAccessManagerStatus(actionErrorMessage(result), true)
                        return
                }
                ACCESS_MANAGER_STATE.users = result.users || []
                ACCESS_MANAGER_STATE.guilds = result.guilds || []
                renderAccessCreateGuilds()
                renderAccessManager()
                setAccessManagerStatus(statusMessage || "Superadmins can create users and assign guild access here.", !!isError)
        }).fail(function () {
                setAccessManagerStatus("Unable to load user access right now.", true)
        })
}

function showManageAccessModal() {
        hideLegacyModal("#change_password_template")
        hideLegacyModal("#account_settings_template")
        hideLegacyModal("#recent_imports_template")
        hideLegacyModal("#confirm_template")
        hideLegacyModal("#import_template")
        hideLegacyModal("#barter_template")
        hideLegacyModal("#paid_template")
        showLegacyModal("#manage_access_template", "confirm")
        loadAccessManagerModal()
}

function showChangePasswordModal(forceChange) {
        var $template = $("#change_password_template")
        $template.data("force-change", forceChange ? "1" : "0")
        $("#changePasswordCurrent").val("")
        $("#changePasswordNew").val("")
        $("#changePasswordConfirm").val("")
        $("#changePasswordShow").prop("checked", false)
        setPasswordFieldsVisible(["changePasswordCurrent", "changePasswordNew", "changePasswordConfirm"], false)
        setChangePasswordStatus(forceChange ? "Choose a new password before continuing." : "Update your password here.", false)
        hideLegacyModal("#manage_access_template")
        hideLegacyModal("#account_settings_template")
        hideLegacyModal("#recent_imports_template")
        hideLegacyModal("#confirm_template")
        hideLegacyModal("#import_template")
        hideLegacyModal("#barter_template")
        hideLegacyModal("#paid_template")
        showLegacyModal("#change_password_template", "confirm")
}

function setChangePasswordStatus(message, isError) {
        var $status = $("#changePasswordStatus")
        $status.text(message || "")
        $status.toggleClass("is-error", !!isError)
}

function submitOwnPasswordChange() {
        $.ajax({
                type: "POST",
                url: "json/set/change_password",
                data: {
                        current_password: $("#changePasswordCurrent").val(),
                        new_password: $("#changePasswordNew").val(),
                        confirm_password: $("#changePasswordConfirm").val()
                },
                success: function (result) {
                        if (isActionError(result)) {
                                setChangePasswordStatus(actionErrorMessage(result), true)
                                return
                        }
                        setChangePasswordStatus("Password updated.", false)
                        hideLegacyModal("#change_password_template")
                        window.location.reload()
                },
                error: function () {
                        setChangePasswordStatus("Unable to change password right now.", true)
                },
                xhrFields: {
                        withCredentials: true
                }
        })
}

function setAccountSettingsStatus(message, isError) {
        var $status = $("#accountSettingsStatus")
        $status.text(message || "")
        $status.toggleClass("is-error", !!isError)
}

function populateAccountDateTimeFormatOptions(selectedValue) {
        var options = [
                { value: "us_12", label: "M/D/YYYY h:mm:ss AM/PM" },
                { value: "us_24", label: "M/D/YYYY HH:mm:ss" },
                { value: "intl_12", label: "D/M/YYYY h:mm:ss AM/PM" },
                { value: "intl_24", label: "D/M/YYYY HH:mm:ss" }
        ]
        var normalized = String(selectedValue || "us_12").toLowerCase()
        var $select = $("#accountSettingsDateTimeFormat")
        $select.empty()
        $.each(options, function (_, option) {
                var $option = $("<option></option>").attr("value", option.value).text(option.label)
                if (option.value === normalized) {
                        $option.prop("selected", true)
                }
                $select.append($option)
        })
}

function applyAccountSettings(settings) {
        settings = settings || {}
        ADMIN_ACCOUNT_SETTINGS.timezone = $.trim(String(settings.auth_timezone || ""))
        ADMIN_ACCOUNT_SETTINGS.datetime_format = $.trim(String(settings.auth_datetime_format || "us_12")) || "us_12"
}

function showAccountSettingsModal() {
        if ($("#change_password_template").data("force-change") === "1" && $("#change_password_template").is(":visible")) {
                return
        }
        setAccountSettingsStatus("Loading account settings...", false)
        $.getJSON("json/get/account_settings", function (result) {
                if (isActionError(result)) {
                        setAccountSettingsStatus(actionErrorMessage(result), true)
                        return
                }
                var settings = result.settings || {}
                $("#accountSettingsTimeZone").val("browser")
                populateAccountTimeZoneOptions(settings.auth_timezone || "browser")
                populateAccountDateTimeFormatOptions(settings.auth_datetime_format || "us_12")
                setAccountSettingsStatus("", false)
                hideLegacyModal("#change_password_template")
                hideLegacyModal("#manage_access_template")
                hideLegacyModal("#recent_imports_template")
                hideLegacyModal("#confirm_template")
                hideLegacyModal("#import_template")
                hideLegacyModal("#barter_template")
                hideLegacyModal("#paid_template")
                hideLegacyModal("#guild_settings_template")
                showLegacyModal("#account_settings_template", "confirm")
        }).fail(function () {
                populateAccountTimeZoneOptions("browser")
                populateAccountDateTimeFormatOptions("us_12")
                setAccountSettingsStatus("Unable to load account settings right now.", true)
                hideLegacyModal("#change_password_template")
                hideLegacyModal("#manage_access_template")
                hideLegacyModal("#recent_imports_template")
                hideLegacyModal("#confirm_template")
                hideLegacyModal("#import_template")
                hideLegacyModal("#barter_template")
                hideLegacyModal("#paid_template")
                hideLegacyModal("#guild_settings_template")
                showLegacyModal("#account_settings_template", "confirm")
        })
}

function saveAccountSettings() {
        setAccountSettingsStatus("Saving...", false)
        $.ajax({
                type: "POST",
                url: "json/set/account_settings",
                data: {
                        auth_timezone: $("#accountSettingsTimeZone").val(),
                        auth_datetime_format: $("#accountSettingsDateTimeFormat").val()
                },
                success: function (result) {
                        if (isActionError(result)) {
                                setAccountSettingsStatus(actionErrorMessage(result), true)
                                return
                        }
                        applyAccountSettings(result.settings || {})
                        setAccountSettingsStatus("Account settings saved.", false)
                        if (window.CURRENT_RAFFLE_INFO && CURRENT_RAFFLE_INFO.raffle_updated) {
                                var updated = formatAdminTimestamp(CURRENT_RAFFLE_INFO.raffle_updated)
                                var updatedBy = $.trim(String(CURRENT_RAFFLE_INFO.raffle_updated_by || ""))
                                var rendered = updated ? (updatedBy ? ("Last Updated " + updated + " by " + updatedBy) : ("Last Updated " + updated)) : ""
                                $("#raffle_updated").text(rendered)
                                $("#display_raffle_updated").text(rendered)
                        }
                },
                error: function () {
                        setAccountSettingsStatus("Unable to save account settings right now.", true)
                },
                xhrFields: {
                        withCredentials: true
                }
        })
}

function createAccessUser() {
        var username = $.trim($("#manageAccessUsername").val())
        var password = $("#manageAccessPassword").val()
        var confirmPassword = $("#manageAccessPasswordConfirm").val()
        var isSuperadmin = $("#manageAccessCreateSuperadmin").is(":checked")
        var guilds = []

        $("#manageAccessCreateGuilds input:checked").each(function () {
                guilds.push($(this).val())
        })

        $.ajax({
                type: "POST",
                url: "json/set/auth_user_create",
                data: {
                        auth_name: username,
                        auth_password: password,
                        auth_password_confirm: confirmPassword,
                        is_superadmin: isSuperadmin ? "1" : "0",
                        guild_admins: guilds.join(",")
                },
                success: function (result) {
                        if (isActionError(result)) {
                                setAccessManagerStatus(actionErrorMessage(result), true)
                                return
                        }
                        $("#manageAccessUsername").val("")
                        $("#manageAccessPassword").val("")
                        $("#manageAccessPasswordConfirm").val("")
                        $("#manageAccessCreateSuperadmin").prop("checked", false)
                        $("#manageAccessShowPassword").prop("checked", false)
                        setPasswordFieldsVisible(["manageAccessPassword", "manageAccessPasswordConfirm"], false)
                        $("#manageAccessCreateGuilds input").prop("checked", false)
                        loadAccessManagerModal()
                        setAccessManagerStatus("User created. They will be asked to choose a new password after first login.", false)
                },
                error: function () {
                        setAccessManagerStatus("Unable to create that user.", true)
                },
                xhrFields: {
                        withCredentials: true
                }
        })
}

function resetAccessUserPassword(userId, username) {
        var password = window.prompt('Set a temporary password for "' + username + '"')
        if (password == null) {
                return
        }
        var confirmPassword = window.prompt('Confirm the temporary password for "' + username + '"')
        if (confirmPassword == null) {
                return
        }
        if (password !== confirmPassword) {
                setAccessManagerStatus("Temporary password and confirmation do not match.", true)
                window.alert("Temporary password and confirmation do not match.")
                return
        }

        $.ajax({
                type: "POST",
                url: "json/set/auth_user_reset_password",
                data: {
                        auth_id: userId,
                        auth_password: password,
                        auth_password_confirm: confirmPassword
                },
                success: function (result) {
                        if (isActionError(result)) {
                                setAccessManagerStatus(actionErrorMessage(result), true)
                                window.alert(actionErrorMessage(result))
                                return
                        }
                        loadAccessManagerModal()
                        setAccessManagerStatus("Password reset. That user will be asked to choose a new password after login.", false)
                        window.alert('Password reset for "' + username + '". They will be asked to choose a new password after login.')
                },
                error: function () {
                        setAccessManagerStatus("Unable to reset that password.", true)
                        window.alert("Unable to reset that password right now.")
                },
                xhrFields: {
                        withCredentials: true
                }
        })
}

function saveAccessUser(userId) {
        var isSuperadmin = $('.manage-access-superadmin[data-auth-id="' + userId + '"]').is(":checked")
        var guilds = []
        $('.manage-access-guild[data-auth-id="' + userId + '"]:checked').each(function () {
                guilds.push($(this).val())
        })

        $.ajax({
                type: "POST",
                url: "json/set/auth_user_roles",
                data: {
                        auth_id: userId,
                        is_superadmin: isSuperadmin ? "1" : "0",
                        guild_admins: guilds.join(",")
                },
                success: function (result) {
                        if (isActionError(result)) {
                                var errorMessage = actionErrorMessage(result)
                                window.alert(errorMessage)
                                loadAccessManagerModal(errorMessage, true)
                                return
                        }
                        loadAccessManagerModal("Access updated.", false)
                        window.alert("Access updated.")
                },
                error: function () {
                        setAccessManagerStatus("Unable to update that user.", true)
                        window.alert("Unable to update that user right now.")
                },
                xhrFields: {
                        withCredentials: true
                }
        })
}

function deleteAccessUser(userId, username) {
        if (!window.confirm('Delete user "' + username + '"? This removes login access immediately.')) {
                return
        }

        $.ajax({
                type: "POST",
                url: "json/set/auth_user_delete",
                data: {
                        auth_id: userId
                },
                success: function (result) {
                        if (isActionError(result)) {
                                setAccessManagerStatus(actionErrorMessage(result), true)
                                return
                        }
                        loadAccessManagerModal()
                        setAccessManagerStatus("User deleted.", false)
                },
                error: function () {
                        setAccessManagerStatus("Unable to delete that user.", true)
                },
                xhrFields: {
                        withCredentials: true
                }
        })
}

function copyTextAreaValue(textareaId, buttonEl) {
        var field = document.getElementById(textareaId)
        if (!field) {
                return
        }

        var originalLabel = buttonEl ? buttonEl.textContent : ""
        field.focus()
        field.select()
        field.setSelectionRange(0, field.value.length)

        var copyPromise
        if (navigator.clipboard && window.isSecureContext) {
                copyPromise = navigator.clipboard.writeText(field.value)
        } else {
                copyPromise = new Promise(function (resolve, reject) {
                        try {
                                if (document.execCommand("copy")) {
                                        resolve()
                                } else {
                                        reject(new Error("copy failed"))
                                }
                        } catch (error) {
                                reject(error)
                        }
                })
        }

        copyPromise.then(function () {
                if (buttonEl) {
                        buttonEl.textContent = "Copied"
                        window.setTimeout(function () {
                                buttonEl.textContent = originalLabel || "Copy"
                        }, 1200)
                }
        }).catch(function () {
                window.alert("Copy failed. Please copy the text manually.")
        })
}

var NOTE_TAB_ORDER = [
        { key: "raffle_notes_admin", label: "ADMIN" },
        { key: "raffle_notes", label: "PUBLIC 1" },
        { key: "raffle_notes_public_2", label: "PUBLIC 2" }
]

var NOTE_EDITOR_STATE = {
        activeKey: "raffle_notes_admin",
        drafts: {
                raffle_notes_admin: "",
                raffle_notes: "",
                raffle_notes_public_2: ""
        },
        dirty: false,
        isEditing: false
}

function getNotesEditorSurface() {
        return document.getElementById("notesEditorSurface")
}

function syncNotesEditorPlaceholder() {
        var surface = getNotesEditorSurface()
        if (!surface) {
                return
        }

        var plainText = (surface.textContent || "").replace(/\u00a0/g, " ").trim()
        surface.classList.toggle("is-empty", !plainText && !surface.querySelector("img, ul, ol, li, a, span, div, p, br"))
}

function setNoteSaveState(isDirty, message) {
        NOTE_EDITOR_STATE.dirty = !!isDirty

        var saveBtn = document.getElementById("notesSaveBtn")
        var status = document.getElementById("notesSaveStatus")

        if (saveBtn) {
                saveBtn.classList.toggle("is-dirty", !!isDirty)
                saveBtn.textContent = "Save All"
                saveBtn.style.display = !!isDirty ? "" : "none"
        }
        if (status) {
                status.textContent = message || (isDirty ? "Unsaved changes" : "Saved")
        }
}

function applyNotesEditorMode() {
        var panel = document.getElementById("notesPanel")
        var surface = getNotesEditorSurface()
        var toggle = document.getElementById("notesEditorToggle")

        if (!panel || !surface || !toggle) {
                return
        }

        panel.classList.toggle("is-read-mode", !NOTE_EDITOR_STATE.isEditing)
        surface.setAttribute("contenteditable", NOTE_EDITOR_STATE.isEditing ? "true" : "false")
        toggle.lastChild.textContent = NOTE_EDITOR_STATE.isEditing ? "Close Editor" : "Edit Notes"
}

function setNotesEditingMode(isEditing) {
        NOTE_EDITOR_STATE.isEditing = !!isEditing
        applyNotesEditorMode()

        if (NOTE_EDITOR_STATE.isEditing) {
                var surface = getNotesEditorSurface()
                if (surface) {
                        surface.focus()
                }
        }
}

function persistActiveNoteDraft() {
        var surface = getNotesEditorSurface()
        if (!surface || !NOTE_EDITOR_STATE.activeKey) {
                return
        }

        NOTE_EDITOR_STATE.drafts[NOTE_EDITOR_STATE.activeKey] = surface.innerHTML
        $("#" + NOTE_EDITOR_STATE.activeKey).val(surface.innerHTML)
        syncNotesEditorPlaceholder()
}

function renderActiveNoteTab() {
        $(".note-tab").removeClass("active")
        $('.note-tab[data-note-key="' + NOTE_EDITOR_STATE.activeKey + '"]').addClass("active")
}

function loadNoteTab(noteKey, options) {
        options = options || {}
        if (!options.skipPersist) {
                persistActiveNoteDraft()
        }
        NOTE_EDITOR_STATE.activeKey = noteKey

        var surface = getNotesEditorSurface()
        if (!surface) {
                return
        }

        surface.innerHTML = NOTE_EDITOR_STATE.drafts[noteKey] || ""
        renderActiveNoteTab()
        syncNotesEditorPlaceholder()
}

function loadNoteDraftsFromRaffle(result) {
        NOTE_EDITOR_STATE.drafts.raffle_notes_admin = result["raffle_notes_admin"] || ""
        NOTE_EDITOR_STATE.drafts.raffle_notes = result["raffle_notes"] || ""
        NOTE_EDITOR_STATE.drafts.raffle_notes_public_2 = result["raffle_notes_public_2"] || ""

        $("#raffle_notes_admin").val(NOTE_EDITOR_STATE.drafts.raffle_notes_admin)
        $("#raffle_notes").val(NOTE_EDITOR_STATE.drafts.raffle_notes)
        $("#raffle_notes_public_2").val(NOTE_EDITOR_STATE.drafts.raffle_notes_public_2)

        loadNoteTab(NOTE_EDITOR_STATE.activeKey || "raffle_notes_admin", { skipPersist: true })
        setNoteSaveState(false, "Saved")
        applyNotesEditorMode()
}

function execNoteCommand(command, value) {
        var surface = getNotesEditorSurface()
        if (!surface) {
                return
        }

        surface.focus()
        document.execCommand(command, false, value || null)
        persistActiveNoteDraft()
        setNoteSaveState(true, "Unsaved changes")
}

function saveNotes() {
        persistActiveNoteDraft()
        var saveBtn = document.getElementById("notesSaveBtn")
        if (saveBtn) {
                saveBtn.disabled = true
                saveBtn.textContent = "Saving..."
        }

        $.ajax({
                type: "POST",
                url: "json/set/raffle_notes",
                data: {
                        raffle_notes: $("#raffle_notes").val(),
                        raffle_notes_admin: $("#raffle_notes_admin").val(),
                        raffle_notes_public_2: $("#raffle_notes_public_2").val()
                },
                success: function () {
                        setNoteSaveState(false, "Saved")
                },
                error: function () {
                        setNoteSaveState(true, "Save failed")
                },
                complete: function () {
                        if (saveBtn) {
                                saveBtn.disabled = false
                                saveBtn.textContent = "Save All"
                        }
                },
                xhrFields: {
                        withCredentials: true
                }
        })
}

function addPrizeCard() {
        saveAllVisiblePrizeForms()
                .done(function () {
                        $.getJSON("json/set/prize_add", function (result) {
                                if (result) {
                                        get_prize_info({ scrollToLast: true })
                                }
                        })
                })
                .fail(function (result) {
                        if (isActionError(result)) {
                                alert(actionErrorMessage(result))
                                get_prize_info()
                        }
                })
        return false
}

function cloneLastPrizeCard() {
        saveAllVisiblePrizeForms()
                .done(function () {
                        $.getJSON("json/set/prize_clone_last", function (result) {
                                if (isActionError(result)) {
                                        alert(actionErrorMessage(result))
                                        return
                                }
                                get_prize_info({ scrollToLast: true })
                        })
                })
                .fail(function (result) {
                        if (isActionError(result)) {
                                alert(actionErrorMessage(result))
                                get_prize_info()
                        }
                })
        return false
}

$(document).on("input blur", ".prize_value", function () {
        formatPrizeValueField(this)
})

$(document).on("click", ".note-tab", function () {
        loadNoteTab($(this).data("noteKey"))
})

$(document).on("click", ".note-tool", function () {
        var cmd = $(this).data("cmd")
        if (!cmd) {
                return
        }

        if (cmd === "createLink") {
                var url = window.prompt("Enter a link URL")
                if (!url) {
                        return
                }
                execNoteCommand(cmd, url)
                return
        }

        execNoteCommand(cmd)
})

$(document).on("click", "#notesEditorToggle", function () {
        setNotesEditingMode(!NOTE_EDITOR_STATE.isEditing)
})

$(document).on("click", ".new-raffle-tool", function () {
        var cmd = $(this).data("cmd")
        var editor = this.closest(".new-raffle-note-card").querySelector(".new-raffle-editor")
        if (!cmd || !editor) {
                return
        }

        if (cmd === "createLink") {
                var url = window.prompt("Enter a link URL")
                if (!url) {
                        return
                }
                execRichTextCommand(editor, cmd, url)
                return
        }

        execRichTextCommand(editor, cmd)
})

$(document).on("change input", ".new-raffle-color", function () {
        var editor = this.closest(".new-raffle-note-card").querySelector(".new-raffle-editor")
        execRichTextCommand(editor, "foreColor", this.value)
})

$(document).on("input", ".new-raffle-editor", function () {
        syncEditorPlaceholder(this)
})

$(document).on("click", ".new-raffle-clear", function () {
        var editor = this.closest(".new-raffle-note-card").querySelector(".new-raffle-editor")
        if (!editor) {
                return
        }
        editor.innerHTML = ""
        syncEditorPlaceholder(editor)
        editor.focus()
})

$(document).on("click", "#newRaffleModalClose, #newRaffleCancel", function () {
        hideNewRaffleModal()
})

$(document).on("click", "#newRaffleCreate", function () {
        var payload = collectNewRafflePayload()
        var createBtn = this

        if (!payload.raffle_guild_num) {
                alert("Please enter a raffle number before creating the new raffle.")
                $("#newRaffleNumber").focus()
                return
        }

        createBtn.disabled = true
        createBtn.textContent = "Creating..."

        $.ajax({
                type: "POST",
                url: "json/set/open_raffle",
                data: payload,
                success: function (result) {
                        if (isActionError(result)) {
                                alert(actionErrorMessage(result))
                                return
                        }
                        if (!result || result.ok !== true) {
                                alert("Unable to create the new raffle.")
                                return
                        }
                        hideNewRaffleModal()
                        refresher()
                },
                error: function () {
                        alert("Unable to create the new raffle.")
                },
                complete: function () {
                        createBtn.disabled = false
                        createBtn.textContent = "Create Raffle"
                },
                xhrFields: {
                        withCredentials: true
                }
        })
})

$(document).on("input", "#notesEditorSurface", function () {
        persistActiveNoteDraft()
        setNoteSaveState(true, "Unsaved changes")
})

$(document).on("change input", "#notesTextColor", function () {
        execNoteCommand("foreColor", this.value)
})

$(document).on("click", "#notesSaveBtn", function () {
        saveNotes()
})

$(document).on("click", "#legacy_modal_backdrop", function () {
        if ($("#change_password_template").data("force-change") === "1") {
                return
        }
        hideLegacyModal("#import_template")
        hideLegacyModal("#confirm_template")
        hideLegacyModal("#change_password_template")
        hideLegacyModal("#manage_access_template")
        hideLegacyModal("#recent_imports_template")
        hideLegacyModal("#barter_template")
        hideLegacyModal("#paid_template")
        hideNewRaffleModal()
})

window.addEventListener("beforeunload", function (event) {
        if (!NOTE_EDITOR_STATE.dirty) {
                return
        }

        event.preventDefault()
        event.returnValue = ""
})


// Some of my best friends use JSON!
var GLOBAL_PRIZE_ALERTED = false
var CURRENT_RAFFLE_INFO = {
    raffle_subheader: "",
    raffle_time: "",
    raffle_cost: "",
    raffle_status: "LIVE",
    raffle_barter_enabled: 0,
    raffle_gold_mail_enabled: 1,
    raffle_gold_bank_enabled: 1,
    raffle_barter_mail_enabled: 0,
    raffle_barter_bank_enabled: 0,
    raffle_updated: "",
    raffle_updated_by: ""
}

var DEFAULT_RAFFLE_IMPORT_RULES = {
    raffle_gold_mail_enabled: 1,
    raffle_gold_bank_enabled: 1,
    raffle_barter_mail_enabled: 0,
    raffle_barter_bank_enabled: 0
}

function normalizeFieldValue(value) {
    if (value === null || value === undefined) {
        return ""
    }
    return $.trim(String(value))
}

function normalizeToggleEnabledValue(value) {
    return String(value == null ? "" : value).trim().toLowerCase() === "1" ||
        String(value == null ? "" : value).trim().toLowerCase() === "true" ||
        String(value == null ? "" : value).trim().toLowerCase() === "yes" ||
        String(value == null ? "" : value).trim().toLowerCase() === "on"
}

function getNormalizedRaffleImportRules(source) {
    var raw = source || {}
    return {
        raffle_gold_mail_enabled: normalizeToggleEnabledValue(raw.raffle_gold_mail_enabled == null ? DEFAULT_RAFFLE_IMPORT_RULES.raffle_gold_mail_enabled : raw.raffle_gold_mail_enabled) ? 1 : 0,
        raffle_gold_bank_enabled: normalizeToggleEnabledValue(raw.raffle_gold_bank_enabled == null ? DEFAULT_RAFFLE_IMPORT_RULES.raffle_gold_bank_enabled : raw.raffle_gold_bank_enabled) ? 1 : 0,
        raffle_barter_mail_enabled: normalizeToggleEnabledValue(raw.raffle_barter_mail_enabled == null ? (raw.raffle_barter_enabled == null ? DEFAULT_RAFFLE_IMPORT_RULES.raffle_barter_mail_enabled : raw.raffle_barter_enabled) : raw.raffle_barter_mail_enabled) ? 1 : 0,
        raffle_barter_bank_enabled: normalizeToggleEnabledValue(raw.raffle_barter_bank_enabled == null ? (raw.raffle_barter_enabled == null ? DEFAULT_RAFFLE_IMPORT_RULES.raffle_barter_bank_enabled : raw.raffle_barter_enabled) : raw.raffle_barter_bank_enabled) ? 1 : 0
    }
}

function updateBarterToggleVisual(input) {
    var $input = $(input)
    var isEnabled = $input.is(":checked")
    var $scope = $input.closest(".barter-toggle-shell, .guild-settings-barter-strip")
    $scope.find(".barter-toggle-value").text(isEnabled ? "ON" : "OFF").toggleClass("is-on", isEnabled)
}

function syncCurrentRaffleImportRuleState(source) {
    var normalized = getNormalizedRaffleImportRules(source)
    $.each(normalized, function (fieldName, enabledValue) {
        CURRENT_RAFFLE_INFO[fieldName] = enabledValue ? 1 : 0
    })
    CURRENT_RAFFLE_INFO.raffle_barter_enabled = (CURRENT_RAFFLE_INFO.raffle_barter_mail_enabled || CURRENT_RAFFLE_INFO.raffle_barter_bank_enabled) ? 1 : 0

    $(".barter-toggle-input[data-mode='current']").each(function () {
        var fieldName = $(this).attr("data-field")
        var isEnabled = !!CURRENT_RAFFLE_INFO[fieldName]
        this.checked = isEnabled
        updateBarterToggleVisual(this)
    })
}

function saveCurrentRaffleImportRule(fieldName, enabled) {
    var previousState = getNormalizedRaffleImportRules(CURRENT_RAFFLE_INFO)
    var nextState = $.extend({}, previousState)
    nextState[fieldName] = enabled ? 1 : 0
    syncCurrentRaffleImportRuleState(nextState)
    $.ajax({
        type: "POST",
        url: "json/set/raffle",
        data: $.extend({}, nextState),
        success: function (result) {
            if (isActionError(result)) {
                syncCurrentRaffleImportRuleState(previousState)
                alert(actionErrorMessage(result))
                return
            }
            syncCurrentRaffleImportRuleState(result || nextState)
        },
        error: function () {
            syncCurrentRaffleImportRuleState(previousState)
            alert("Unable to update raffle import rules right now.")
        },
        xhrFields: {
            withCredentials: true
        }
    })
}

function padWeekNumber(value) {
    return String(value).padStart(2, "0")
}

function getIsoWeekParts(date) {
    var workingDate = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
    var day = workingDate.getUTCDay() || 7
    workingDate.setUTCDate(workingDate.getUTCDate() + 4 - day)
    var yearStart = new Date(Date.UTC(workingDate.getUTCFullYear(), 0, 1))
    var week = Math.ceil((((workingDate - yearStart) / 86400000) + 1) / 7)

    return {
        year: workingDate.getUTCFullYear(),
        week: week
    }
}

function getSuggestedRaffleNumber() {
    var currentNumber = normalizeFieldValue(CURRENT_RAFFLE_INFO.raffle_subheader)
    if (/^\d{4}$/.test(currentNumber)) {
        var yearPart = parseInt(currentNumber.slice(0, 2), 10)
        var weekPart = parseInt(currentNumber.slice(2), 10)

        if (weekPart >= 52) {
            return String(yearPart + 1).padStart(2, "0") + "01"
        }

        return String(yearPart).padStart(2, "0") + padWeekNumber(weekPart + 1)
    }

    var weekParts = getIsoWeekParts(new Date())
    var fallbackYearPart = String(weekParts.year).slice(-2)
    return fallbackYearPart + padWeekNumber(weekParts.week)
}

function promptForNewRaffleNumber() {
    var suggestedNumber = getSuggestedRaffleNumber()
    var enteredNumber = window.prompt(
        "Open a new raffle.\nSuggested raffle number (editable):",
        suggestedNumber
    )

    if (enteredNumber === null) {
        return null
    }

    enteredNumber = normalizeFieldValue(enteredNumber)
    if (enteredNumber === "") {
        alert("Please enter a raffle number before opening the new raffle.")
        return null
    }

    return enteredNumber
}

function syncEditorPlaceholder(surface) {
    if (!surface) {
        return
    }

    var plainText = (surface.textContent || "").replace(/\u00a0/g, " ").trim()
    surface.classList.toggle("is-empty", !plainText && !surface.querySelector("img, ul, ol, li, a, span, div, p, br"))
}

function execRichTextCommand(surface, command, value) {
    if (!surface) {
        return
    }

    surface.focus()
    document.execCommand(command, false, value || null)
    syncEditorPlaceholder(surface)
}

function populateNewRaffleModal() {
    $("#newRaffleNumber").val(getSuggestedRaffleNumber())
    $("#newRaffleTime").val($("#raffle_time").val() || CURRENT_RAFFLE_INFO.raffle_time || "")
    $("#newRaffleCost").val($("#raffle_cost").val() || CURRENT_RAFFLE_INFO.raffle_cost || "")
    $("#newRaffleTitle").val("")
    $(".barter-toggle-input[data-mode='new']").each(function () {
        var fieldName = $(this).attr("data-field")
        var shouldEnable = !!DEFAULT_RAFFLE_IMPORT_RULES[fieldName]
        $(this).prop("checked", shouldEnable)
        updateBarterToggleVisual(this)
    })
    $("#newRaffleClonePrizes").prop("checked", false)

    document.querySelectorAll(".new-raffle-editor").forEach(function (surface) {
        var noteKey = surface.getAttribute("data-note-key")
        var html = (NOTE_EDITOR_STATE.drafts && NOTE_EDITOR_STATE.drafts[noteKey]) || $("#" + noteKey).val() || ""
        surface.innerHTML = html
        syncEditorPlaceholder(surface)
    })
}

function showNewRaffleModal() {
    closeToolMenus()
    populateNewRaffleModal()
    $("#legacy_modal_backdrop").show()
    $("body").addClass("legacy-modal-open")
    $("#new_raffle_modal").show()
    window.setTimeout(function () {
        var field = document.getElementById("newRaffleNumber")
        if (field) {
            field.focus()
            field.select()
        }
    }, 0)
}

function hideNewRaffleModal() {
    $("#new_raffle_modal").hide()
    syncLegacyModalState()
}

function collectNewRafflePayload() {
    var payload = {
        raffle_guild_num: normalizeFieldValue($("#newRaffleNumber").val()),
        raffle_time: normalizeFieldValue($("#newRaffleTime").val()),
        raffle_ticket_cost: normalizeFieldValue($("#newRaffleCost").val()),
        raffle_title: normalizeFieldValue($("#newRaffleTitle").val()),
        raffle_status: "LIVE",
        clone_prizes: $("#newRaffleClonePrizes").is(":checked") ? "1" : "0"
    }

    $(".barter-toggle-input[data-mode='new']").each(function () {
        var fieldName = $(this).attr("data-field")
        payload[fieldName] = $(this).is(":checked") ? "1" : "0"
    })

    document.querySelectorAll(".new-raffle-editor").forEach(function (surface) {
        var noteKey = surface.getAttribute("data-note-key")
        payload[noteKey] = surface.innerHTML
    })

    return payload
}

function isActionError(result) {
    return result && typeof result === "object" && result.ok === false
}

function actionErrorMessage(result, fallbackMessage) {
    return (result && result.error) || fallbackMessage || "That action could not be completed."
}

function maybePromptCompleteAfterFinalLock(result) {
    if (!result || result.ok !== true || !result.all_finalised) {
        return
    }

    if (normalizeRaffleStatus($("#raffle_status").val()) === "COMPLETE") {
        return
    }

    if (window.confirm('All prizes are now locked. Change raffle status to "COMPLETE" now?')) {
        $("#raffle_status").val("COMPLETE").trigger("change")
    }
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
                applyGuildBranding(result)
                $.getJSON("json/get/guild_choices", function (choicesResult) {
                        renderProfileGuildLinks(result["guild_shortname"], result["guild_sister_guilds"] || [], (choicesResult && choicesResult.guilds) || [])
                })
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
  syncCurrentRaffleImportRuleState(result)
                loadNoteDraftsFromRaffle(result)
                applyAdminStatus(result["raffle_status"])

                CURRENT_RAFFLE_INFO.raffle_subheader = normalizeFieldValue(result["raffle_guild_num"])
                CURRENT_RAFFLE_INFO.raffle_time = normalizeFieldValue(result["raffle_time"])
                CURRENT_RAFFLE_INFO.raffle_cost = normalizeFieldValue(result["raffle_ticket_cost"])
                CURRENT_RAFFLE_INFO.raffle_status = normalizeRaffleStatus(result["raffle_status"])
                pruneImportHistoryToCurrentRaffle()

                var raffleHeader = buildRaffleHeaderParts(result["raffle_guild_num"], result["raffle_title"], result["raffle_time"])
                $("#display_raffle_subheader").text(raffleHeader.heading)
                $("#display_raffle_meta_sep").text(raffleHeader.separator)
                $("#display_raffle_time").text(raffleHeader.trailing)
            })
}
var get_prize_info = function (options) {
        options = options || {}
        var restoreScrollY = options.preserveScroll ? window.pageYOffset : null
        // deal with prizes
        $.getJSON("json/get/prizes", function (result) {
                $("#prize_info").empty()
                var lastPrizeCard = null
                $.each(result, function (index, value) {
                    var template = $("#prize_template").clone()
                    var dom_id = "prize_" + value["prize_id"] + "_"
                    template.attr({"id": dom_id + "block"})
                    // fix the prize number
                    $("#prize_number", template).attr({"id": dom_id + "number"}).val(value["prize_text2"])
                    var pwinner = value["prize_winner"]
                    if (String(pwinner) === "0") {
                        pwinner = ""
                    }
                    var pname = value["prize_winner_name"]
                    $("#prize_winner", template).attr({"id": dom_id + "winner"}).val(pwinner)
                    if (value["prize_finalised"] != 0) {
                        $("#prize_winner_name", template).addClass("finalised")
                    }
                    $("#prize_winner_name", template).attr({"id": dom_id + "winner_name"}).text(pname)

                    // at least the prize details are here
                    $("#prize_item", template).attr({"id": dom_id + "item"}).val(value["prize_text"] || "")
                    $("#prize_badge", template).attr({"id": dom_id + "badge"})
                    var prizeValueField = $("#prize_value", template)
                        .attr({"id": dom_id + "value"})
                        .val(value["prize_value"] == null ? "" : value["prize_value"])[0]
                    formatPrizeValueField(prizeValueField)
                    $("#prize_style", template).attr({"id": dom_id + "style"})
                    applyPrizeStyleState(template, value["prize_style"])
                    if (value["prize_finalised"] != 0) {
                        $("#prize_delete", template).remove()
                        $("#prize_roll", template).remove()
                        $("#prize_finalise", template)
                            .attr({"id": dom_id + "finalise", "title": "Unlock winner"})
                            .removeClass("prize_finalise")
                            .addClass("prize_unlock")
                        $("input[type='text'][name], select[name]", template).prop("disabled", true)
                    } else {
                        $("#prize_finalise", template).attr({"id": dom_id + "finalise", "title": "Lock winner"})
                        $("#prize_delete", template).attr({"id": dom_id + "delete"})
                        $("#prize_roll", template).attr({"id": dom_id + "roll"})
                    }
                    $("#prize_clone", template).attr({"id": dom_id + "clone"})
                    $("#prize_template_form", template).attr({"id": "prize_" + value["prize_id"] + "_form"})
                    $(".prize_id", template).val(value["prize_id"])

                    $(".prize_delete", template).click(function (event) {
                        event.preventDefault()
                        if (GLOBAL_PRIZE_ALERTED == false) {
                            GLOBAL_PRIZE_ALERTED = true
                            var r = confirm("Prize deletion is final and irreversible. You will only be shown this message once per session. Press OK to confirm deletion, or cancel to go back.")
                            if (r == false) {
                                return
                            }
                        }

                        $.getJSON("json/set/prize_delete/" + value["prize_id"], function (result) {
                            if (isActionError(result)) {
                                alert(actionErrorMessage(result))
                                return
                            }
                            get_prize_info({ preserveScroll: true })
                            })
                        
                    })
                    $(".prize_finalise", template).click(function (event) {
                            event.preventDefault()
                            $.getJSON("json/set/prize_finalise/" + value["prize_id"], function (result) {
                                if (isActionError(result)) {
                                    alert(actionErrorMessage(result))
                                    return
                                }
                                maybePromptCompleteAfterFinalLock(result)
                                get_prize_info({ preserveScroll: true })
                                })
                            })
                    $(".prize_unlock", template).click(function (event) {
                            event.preventDefault()
                            var warning = normalizeRaffleStatus($("#raffle_status").val()) === "COMPLETE"
                                ? "This raffle is already COMPLETE. Unlocking will hide this winner again and let you edit it. Continue?"
                                : "Unlock this prize so the winner can be changed? The finalized winner will no longer be shown publicly."
                            if (!window.confirm(warning)) {
                                return
                            }
                            $.getJSON("json/set/prize_unfinalise/" + value["prize_id"], function (result) {
                                if (isActionError(result)) {
                                    alert(actionErrorMessage(result))
                                    return
                                }
                                get_prize_info({ preserveScroll: true })
                                })
                            })
                    $(".prize_roll", template).click(function (event) {
                            event.preventDefault()
                            $.getJSON("json/set/prize_roll/" + value["prize_id"], function (result) {
                                if (isActionError(result)) {
                                    alert(actionErrorMessage(result))
                                    return
                                }
                                get_prize_info({ preserveScroll: true })
                                })
                            })
                    $(".prize_clone", template).click(function (event) {
                            event.preventDefault()
                            savePrizeForm($("#" + dom_id + "form"), { silent: true })
                                .done(function () {
                                    $.getJSON("json/set/prize_clone_below/" + value["prize_id"], function (result) {
                                        if (isActionError(result)) {
                                            alert(actionErrorMessage(result))
                                            return
                                        }
                                        get_prize_info({ preserveScroll: true })
                                    })
                                })
                                .fail(function (result) {
                                    if (isActionError(result)) {
                                        alert(actionErrorMessage(result))
                                        get_prize_info({ preserveScroll: true })
                                    }
                                })
                            })

                    $(".prize_style", template).change(function () {
                            applyPrizeStyleState(template, $(this).val())
                    })

                    $("input[type='text'][name], select[name]", template).change(function () {
                            savePrizeForm($("#" + dom_id + "form"), {
                                refreshAfterSave: true,
                                refreshOptions: { preserveScroll: true }
                            }).fail(function () {
                                get_prize_info({ preserveScroll: true })
                            })
                            })

                    $("#prize_info").append(template)
                    lastPrizeCard = $("#" + dom_id + "block")
                })

                if (options.scrollToLast && lastPrizeCard && lastPrizeCard.length) {
                    lastPrizeCard[0].scrollIntoView({ behavior: "smooth", block: "nearest" })
                } else if (restoreScrollY !== null) {
                    window.scrollTo(0, restoreScrollY)
                }
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

        var rangeText = row.length > 5 ? (row[5] || "") : ""

        if (!rangeText) {
            var total = Number(row[2]) || 0
            if (total > 0) {
                var runningEnd = runningStart + total - 1
                rangeText = runningStart + "-" + runningEnd
                runningStart = runningEnd + 1
            }
        }

        var newRow = row.slice()
        newRow.push(encodeSortableRange(rangeText))
        output.push(newRow)
    }

    return output
}

function encodeSortableRange(rangeText) {
    var text = String(rangeText || "").trim()
    if (!text) {
        return ""
    }

    var firstPart = text.split(",")[0].trim()
    var match = firstPart.match(/^(\d+)/)
    if (!match) {
        return text
    }

    return match[1].padStart(10, "0") + "|" + text
}

function renderSortableRange(value) {
    var text = String(value || "")
    var pipeIndex = text.indexOf("|")
    return pipeIndex >= 0 ? text.slice(pipeIndex + 1) : text
}

function getSortableRangeStart(value) {
    var text = renderSortableRange(value)
    var firstPart = String(text || "").split(",")[0].trim()
    var match = firstPart.match(/^(\d+)/)
    return match ? Number(match[1]) : Number.MAX_SAFE_INTEGER
}

function compareTicketRowsByColumn(aRow, bRow, columnIndex, sortOrder, rangeColumnIndex) {
    var direction = sortOrder === "desc" ? -1 : 1
    var aValue = aRow[columnIndex]
    var bValue = bRow[columnIndex]
    var primary = 0

    if (columnIndex === rangeColumnIndex) {
        primary = getSortableRangeStart(aValue) - getSortableRangeStart(bValue)
    } else if (columnIndex >= 2 && columnIndex < rangeColumnIndex) {
        primary = (Number(aValue) || 0) - (Number(bValue) || 0)
    } else {
        primary = String(aValue || "").localeCompare(String(bValue || ""), undefined, { sensitivity: "base" })
    }

    if (primary !== 0) {
        return primary * direction
    }

    return getSortableRangeStart(aRow[rangeColumnIndex]) - getSortableRangeStart(bRow[rangeColumnIndex])
}

function applyTicketSortTieBreak(hot, destinationSortConfigs) {
    if (!hot || !destinationSortConfigs || !destinationSortConfigs.length) {
        return
    }

    var primarySort = destinationSortConfigs[0]
    if (!primarySort || primarySort.column == null || !primarySort.sortOrder) {
        return
    }

    var sourceData = hot.getSourceDataArray()
    if (!sourceData || !sourceData.length) {
        return
    }

    var extended = hot.countCols() > 4
    var realRows = getTicketDataRows(sourceData, extended)
    if (!realRows.length) {
        return
    }

    var rangeColumnIndex = hot.countCols() - 1
    var sortedData = realRows.slice().sort(function(aRow, bRow) {
        return compareTicketRowsByColumn(aRow, bRow, primarySort.column, primarySort.sortOrder, rangeColumnIndex)
    })

    hot.loadData(sortedData)
}

function getTicketDataRows(data, extended) {
    var rows = []

    for (var i = 0; i < (data || []).length; i++) {
        var row = data[i]
        if (!row) {
            continue
        }

        var name = row[1]
        if (name == null || $.trim(String(name)) === "") {
            continue
        }

        if (extended) {
            var paid = Number(row[3]) || 0
            var bar = Number(row[4]) || 0
            if (paid === 0 && bar === 0) {
                continue
            }
        } else {
            var total = Number(row[2]) || 0
            if (total === 0) {
                continue
            }
        }

        rows.push(row)
    }

    return rows
}

function renderTicketTotalsFooter(data, extended) {
    var rows = getTicketDataRows(data, extended)
    var total = 0
    var paid = 0
    var bar = 0

    for (var i = 0; i < rows.length; i++) {
        total += Number(rows[i][2]) || 0
        if (extended) {
            paid += Number(rows[i][3]) || 0
            bar += Number(rows[i][4]) || 0
        }
    }

    var html = '<div class="ticket-summary-box">'
    html += '  <div class="ticket-summary-row"><span class="ticket-summary-label">Total Tickets</span><span class="ticket-summary-value total">' + total.toLocaleString() + '</span></div>'
    if (extended) {
        html += '  <div class="ticket-summary-row"><span class="ticket-summary-label">Paid</span><span class="ticket-summary-value">' + paid.toLocaleString() + '</span></div>'
        html += '  <div class="ticket-summary-row"><span class="ticket-summary-label">Barter</span><span class="ticket-summary-value">' + bar.toLocaleString() + '</span></div>'
    }
    html += '</div>'

    $("#ticket_totals_footer").html(html)
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
            if (source == "ignore" || source == "loadData") { return }

% if request.extended_tickets:
            if (change) {
                var row = parseInt(change[0][0], 10)
                if (isNaN(row) || row < 0) {
                    return
                }

                var ti = $("#ticket_info")

                var paid = ti.handsontable("getDataAtCell", row, 3)
                var bart = ti.handsontable("getDataAtCell", row, 4)
                
                // Ensure values are numbers
                paid = isNaN(paid) ? 0 : Number(paid)
                bart = isNaN(bart) ? 0 : Number(bart)

                var total = paid + bart

                ti.handsontable("setDataAtCell", row, 2, total, "ignore")
            }
% endif
            setTimeout(function () {
                var data = $("#ticket_info").handsontable("getData")
                renderTicketTotalsFooter(data, ${'true' if request.extended_tickets else 'false'})
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
                if (!result || !result.timestamp) {
                        CURRENT_RAFFLE_INFO.raffle_updated = ""
                        CURRENT_RAFFLE_INFO.raffle_updated_by = ""
                        $("#raffle_updated").text("")
                        $("#display_raffle_updated").text("")
                        return
                }

                CURRENT_RAFFLE_INFO.raffle_updated = result.timestamp
                CURRENT_RAFFLE_INFO.raffle_updated_by = result.updated_by || ""
                var updated = formatAdminTimestamp(result.timestamp)
                var updatedBy = $.trim(String(result.updated_by || ""))
                var rendered = updatedBy ? ("Last Updated " + updated.toString() + " by " + updatedBy) : ("Last Updated " + updated.toString())

                $("#raffle_updated").text(rendered)
                $("#display_raffle_updated").text(rendered)
                
                })
% if request.extended_tickets:
        $.getJSON(window.location.pathname + "json/get/tickets_extended", function (result) {
                result = addTicketRanges(result, true)
                $("#ticket_info").handsontable("destroy")
                $("#ticket_info").handsontable({
                        data: result,
                        height: "auto",
                        rowHeaders: false,
                        colHeaders: ["#", "Name", "Total", "Paid", "Bar", "Range"],
                        colWidths: [28, 132, 56, 52, 64, 184],
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
                                className: 'totals-column',
                                currentColClassName: 'totals-column',
                            },
                            {
                                type: 'numeric',
                                format: '1,000,000',
                                className: 'ticket-neutral-column',
                                allowInvalid: false,
                            },
                            {
                                type: 'numeric',
                                format: '1,000,000',
                                className: 'ticket-neutral-column',
                                allowInvalid: false,
                            },
                            {
                                className: "ticket-range-cell",
                                readOnly: true,
                                renderer: function(instance, td, row, col, prop, value, cellProperties) {
                                    Handsontable.renderers.TextRenderer.apply(this, arguments)
                                    td.textContent = renderSortableRange(value)
                                },
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
                        afterColumnSort: function(currentSortConfig, destinationSortConfigs) {
                            applyTicketSortTieBreak(this, destinationSortConfigs)
                        },
                        })
                    var data = $("#ticket_info").handsontable("getData")
                    var rows = getTicketDataRows(data, true)
                    var total_tickets = 0
                    var total_participants = rows.length
                    for (var i = 0; i < rows.length; i++) {
                        total_tickets = total_tickets + (Number(rows[i][2]) || 0)
                    }
                    renderTicketTotalsFooter(data, true)
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
                        height: "auto",
                        rowHeaders: false,
                        colHeaders: ["#", "Name", "Total", "Range"],
                        colWidths: [34, 164, 50, 184],
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
                                className: "ticket-range-cell",
                                readOnly: true,
                                renderer: function(instance, td, row, col, prop, value, cellProperties) {
                                    Handsontable.renderers.TextRenderer.apply(this, arguments)
                                    td.textContent = renderSortableRange(value)
                                },
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
                        afterColumnSort: function(currentSortConfig, destinationSortConfigs) {
                            applyTicketSortTieBreak(this, destinationSortConfigs)
                        },
                        })
                    var data = $("#ticket_info").handsontable("getData")
                    var rows = getTicketDataRows(data, false)
                    var total_tickets = 0
                    var total_participants = rows.length
                    for (var i = 0; i < rows.length; i++) {
                        total_tickets = total_tickets + (Number(rows[i][2]) || 0)
                    }
                    renderTicketTotalsFooter(data, false)
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

                if (fieldId === "raffle_status") {
                    applyAdminStatus($field.val())
                }

                $.ajax({
                    type: "POST",
                    url: "json/set/raffle",
                    data: $("#ginfo_form").serialize(),
                    success: function (result) {
                        if (isActionError(result)) {
                            if (fieldId === "raffle_status") {
                                var previousStatus = normalizeRaffleStatus(CURRENT_RAFFLE_INFO.raffle_status)
                                $field.val(previousStatus)
                                applyAdminStatus(previousStatus)
                            }
                            alert(actionErrorMessage(result))
                            return
                        }

                        if (trackedMap[fieldId]) {
                            CURRENT_RAFFLE_INFO[trackedMap[fieldId]] = normalizeFieldValue($field.val())
                        }
                    if (fieldId === "raffle_status") {
                        var savedStatus = normalizeRaffleStatus((result && result.raffle_status) || $field.val())
                        $field.val(savedStatus)
                        applyAdminStatus(savedStatus)
                        CURRENT_RAFFLE_INFO.raffle_status = savedStatus
                    }
                    if (result) {
                        syncCurrentRaffleImportRuleState(result)
                    }
                },
                xhrFields: {
                    withCredentials: true
                }
            })
        })
            $(document).on("change", ".barter-toggle-input", function () {
                updateBarterToggleVisual(this)
            })
            $(document).on("change", ".barter-toggle-input[data-mode='current']", function () {
                var fieldName = $(this).attr("data-field")
                if (!fieldName) {
                    return
                }
                saveCurrentRaffleImportRule(fieldName, $(this).is(":checked"))
            })
            $("#add_prize_button").click(function (event) {
                event.preventDefault()
                addPrizeCard()
            })
            $("#manual_refresh").click(function () {
                get_ticket_table()
                get_ticket_list()
            })
            $("#new_raffle_button").click(function (event) {
                    event.preventDefault()
                    if (normalizeRaffleStatus($("#raffle_status").val()) !== "COMPLETE") {
                        alert('Set the raffle status to "COMPLETE" before opening a new raffle.')
                        return
                    }
                    showNewRaffleModal()
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
                
                showLegacyModal("#import_template", "import")
                var importRows = $.isArray(response) ? response : (response.rows || [])
                var importWarnings = $.isArray(response.warnings) ? response.warnings : []
                var importContext = response && response.import_context ? $.extend({}, response.import_context) : null
                if (importContext) {
                    importContext.import_rows = importRows
                }
                updateImportGuardrailSummary(importWarnings)
                updateImportFileSummary(importContext)
                var mismatchPrompts = collectImportMismatchPrompts(importWarnings)
                if (mismatchPrompts.length) {
                    var proceed = window.confirm(mismatchPrompts.join("\n\n"))
                    if (!proceed) {
                        hideLegacyModal("#import_template")
                        return
                    }
                }
                // get the first header
                var headline = $("#import_data_here tr").first().clone() 
                $("#import_data_here").empty().append(headline)
                var table = $("#import_data_here")
                if (!importRows.length) {
                    var emptyTr = $("<tr></tr>")
                    $("<td colspan='5' class='import-empty-state'></td>")
                        .text("No new eligible ticket rows were found in this file.")
                        .appendTo(emptyTr)
                    table.append(emptyTr)
                    $("#check_all").prop("checked", false)
                    return
                }
                $.each(importRows, function (key, item) {
                    var itemName = (item && typeof item === "object" && !Array.isArray(item)) ? (item.name || "") : item[0]
                    var itemUid = (item && typeof item === "object" && !Array.isArray(item)) ? (item.uid || "") : item[4]
                    var itemTotal = (item && typeof item === "object" && !Array.isArray(item)) ? (item.total_tickets || 0) : item[1]
                    var itemPaid = (item && typeof item === "object" && !Array.isArray(item)) ? (item.paid_tickets || 0) : item[1]
                    var itemBarter = (item && typeof item === "object" && !Array.isArray(item)) ? (item.barter_tickets || 0) : 0
                    var itemSubject = (item && typeof item === "object" && !Array.isArray(item)) ? (item.subject || "") : item[2]
                    var itemBarterItems = (item && typeof item === "object" && !Array.isArray(item) && $.isArray(item.barter_items)) ? item.barter_items : []
                    var itemBarterJson = JSON.stringify(itemBarterItems)
                    var itemBarterSummary = buildBarterItemSummary(itemBarterItems)
                    var tr = $("<tr></tr>")
                    var td = $("<td></td>")
                    var name_td = td.clone()
                    var name = $("<input type='text' name='row"+key+"_name' />").val(itemName).appendTo(name_td)
                    name_td.appendTo(tr)
                    var uid = $("<input type='hidden' name='row"+key+"_uid' />").val(itemUid).appendTo(name_td)
                    $("<input type='hidden' name='row"+key+"_paid_tickets' />").val(itemPaid).appendTo(name_td)
                    $("<input type='hidden' name='row"+key+"_barter_tickets' />").val(itemBarter).appendTo(name_td)
                    $("<input type='hidden' name='row"+key+"_barter_items_json' />").val(itemBarterJson).appendTo(name_td)
                     var amount = $("<input type='text' name='row"+key+"_amount' />").val(itemTotal).appendTo(td.clone().appendTo(tr))
                     var sub
                     if (itemBarterSummary) {
                         sub = itemBarterSummary
                     } else if (itemSubject == "GUILD BANK DEPOSIT") {
                         sub = "[Guild Bank]"
                     } else {
                         sub = itemSubject
                     }
                     var subject = td.clone().text(sub).appendTo(tr)
                     var time_ = td.clone().text(buildImportTimeLabel(item)).appendTo(tr)
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

            $("#import_close_button").click(function () {
                updateImportGuardrailSummary([])
                updateImportFileSummary(null)
                hideLegacyModal("#import_template")
            })
            $("#import_debug_copy").click(function () {
                var payload = String(window.LAST_IMPORT_DEBUG_REPORT || "")
                if (!payload) {
                    alert("No import debug report is available yet.")
                    return
                }
                navigator.clipboard.writeText(payload).then(function () {
                    alert("Import debug report copied.")
                }).catch(function () {
                    alert("Couldn't copy automatically. Here's the report:\n\n" + payload)
                })
            })
            $("#confirm_close_button").click(function () { hideLegacyModal("#confirm_template") })
            $("#change_password_close_button").click(function () {
                if ($("#change_password_template").data("force-change") === "1") {
                    return
                }
                hideLegacyModal("#change_password_template")
            })
            $("#account_settings_close_button").click(function () { hideLegacyModal("#account_settings_template") })
            $("#manage_access_close_button").click(function () { hideLegacyModal("#manage_access_template") })
            $("#guild_settings_close_button").click(function () { hideLegacyModal("#guild_settings_template") })
            $("#bounty_list_close_button").click(function () { hideLegacyModal("#bounty_list_template") })
            $("#barter_summary_close_button").click(function () { hideLegacyModal("#barter_summary_template") })
            $("#guildSettingsLogoUrl").on("input", function () { updateGuildLogoPreview($(this).val()) })
            $("#guildSettingsFaviconUrl").on("input", function () { updateGuildFaviconPreview($(this).val()) })
            $(document).on("input change", "#guild_settings_template .guild-settings-input, #guild_settings_template .guild-settings-select, #guild_settings_template .guild-color-input, #guild_settings_template .guild-mail-account-input, #guild_settings_template .guild-blacklist-input, #guild_settings_template .guild-sister-checkbox", function () {
                markGuildSettingsDirty()
            })
            $(document).on("input change", "#bounty_list_template .guild-settings-input", function () {
                markBountyListDirty()
            })
            $("#recent_imports_close_button").click(function () { hideLegacyModal("#recent_imports_template") })
            $("#barter_close_button").click(function () { hideLegacyModal("#barter_template") })
            $("#paid_close_button").click(function () { hideLegacyModal("#paid_template") })
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
                                    hideLegacyModal("#import_template")
                                    showLegacyModal("#confirm_template", "confirm")
                                    storeImportBatch("lua", result)
                                    populateConfirmModal(result)
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
          $("#reshow_import").click(function () { hideLegacyModal("#confirm_template")
                                                  showLegacyModal("#import_template", "import") })
          $("#reshow_confirm").click(function () { showLegacyModal("#confirm_template", "confirm")
                                                  hideLegacyModal("#import_template") })
          $("#reshow_recent_imports").click(function () { showRecentImportsModal()
                                                  hideLegacyModal("#confirm_template")
                                                  hideLegacyModal("#import_template") })
          $("#import_barter").click(function () { hideLegacyModal("#confirm_template")
                                                  showLegacyModal("#barter_template", "barter") })
          $("#import_paid").click(function () { hideLegacyModal("#confirm_template")
                                                  showLegacyModal("#paid_template", "paid") })
            $("#barter_import").click(function () {
                if ($("#barter_template").is(":visible")) {
                        $.ajax({
                                type: "POST",
                                url: "json/set/barter_import",
                                data: $("#barter_this").serialize(),
                                success: function (result) {
                                    // refresh everything!
                                    refresher()
                                    hideLegacyModal("#barter_template")
                                    showLegacyModal("#confirm_template", "confirm")
                                    storeImportBatch("barter", result)
                                    populateConfirmModal(result)
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
                                    hideLegacyModal("#paid_template")
                                    showLegacyModal("#confirm_template", "confirm")
                                    storeImportBatch("paid", result)
                                    populateConfirmModal(result)
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
        if (!menu || !trigger) {
                return
        }

        var submenuPairs = [
                {
                        shell: document.getElementById('adminToolsSubmenu'),
                        trigger: document.getElementById('adminToolsSubmenuTrigger')
                },
                {
                        shell: document.getElementById('accountSubmenu'),
                        trigger: document.getElementById('accountSubmenuTrigger')
                }
        ].filter(function (pair) {
                return pair.shell && pair.trigger
        })

        function setMenuOpen(open) {
                menu.classList.toggle('open', open)
                trigger.setAttribute('aria-expanded', open ? 'true' : 'false')
                if (!open) {
                        submenuPairs.forEach(function (pair) {
                                pair.shell.classList.remove('open')
                                pair.trigger.setAttribute('aria-expanded', 'false')
                        })
                }
        }

        function setSubmenuOpen(targetPair, open) {
                submenuPairs.forEach(function (pair) {
                        var isTarget = pair === targetPair
                        pair.shell.classList.toggle('open', isTarget && open)
                        pair.trigger.setAttribute('aria-expanded', (isTarget && open) ? 'true' : 'false')
                })
        }

        submenuPairs.forEach(function (pair) {
                pair.shell.addEventListener('mouseenter', function () {
                        if (menu.classList.contains('open')) {
                                setSubmenuOpen(pair, true)
                        }
                })

                pair.shell.addEventListener('mouseleave', function () {
                        setSubmenuOpen(pair, false)
                })

                pair.trigger.addEventListener('click', function (event) {
                        event.preventDefault()
                        event.stopPropagation()
                        if (!menu.classList.contains('open')) {
                                setMenuOpen(true)
                        }
                        setSubmenuOpen(pair, !pair.shell.classList.contains('open'))
                })
        })

        trigger.addEventListener('click', function (event) {
                event.preventDefault()
                event.stopPropagation()
                setMenuOpen(!menu.classList.contains('open'))
        })

        document.addEventListener('click', function (event) {
                if (!menu.contains(event.target)) {
                        setMenuOpen(false)
                }
        })

        document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                        if ($("#change_password_template").data("force-change") === "1") {
                                return
                        }
                        hideLegacyModal("#import_template")
                        hideLegacyModal("#confirm_template")
                        hideLegacyModal("#change_password_template")
                        hideLegacyModal("#account_settings_template")
                        hideLegacyModal("#manage_access_template")
                        hideLegacyModal("#guild_settings_template")
                        hideLegacyModal("#recent_imports_template")
                        hideLegacyModal("#barter_template")
                        hideLegacyModal("#paid_template")
                        hideNewRaffleModal()
                        setMenuOpen(false)
                        closeToolMenus()
                }
        })

        document.addEventListener('click', function (event) {
                document.querySelectorAll('.tool-menu[open]').forEach(function (details) {
                        if (!details.contains(event.target)) {
                                details.removeAttribute('open')
                        }
                })
        })

% if request.user is not None and getattr(request.user, "must_change_password", False):
        showChangePasswordModal(true)
% endif
})
</script>
</head>
<body class="${'is-staging' if is_staging else ''}">
<div class="page-shell">
% if is_staging:
<div class="stage-banner">${stage_label} ENVIRONMENT</div>
% endif

<div class="admin-topbar">
  <div class="admin-topbar-updated" id="display_raffle_updated"></div>
  <div class="admin-topbar-controls">
    <div class="profile-menu" id="adminProfileMenu">
      <button type="button" class="profile-menu-trigger" id="adminProfileMenuTrigger" aria-expanded="false" aria-haspopup="true">
        <span class="profile-trigger-logo-shell">
          <img class="profile-menu-logo" id="adminProfileLogo" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="Guild logo">
        </span>
        <span class="profile-menu-caret">v</span>
      </button>

      <div class="profile-menu-panel" id="adminProfileMenuPanel">
        <div class="profile-menu-lookup">
          <div class="search-wrap">
            <span>
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <circle cx="11" cy="11" r="6.5"></circle>
                <path d="M16 16l5 5"></path>
              </svg>
            </span>
            <input type="text" id="raffle_lookup" name="raffle_lookup" placeholder="Raffle Lookup" onkeydown="if (event.key === 'Enter') { event.preventDefault(); openRaffleLookup(); }" />
          </div>
        </div>
        <div class="profile-menu-list">
          <div class="profile-menu-section" id="profileGuildLinksSection" style="display:none;">
            <div id="profileGuildLinks"></div>
          </div>

          <div class="profile-menu-section">
            <button type="button" class="profile-menu-item" onclick="document.getElementById('adminProfileMenu').classList.remove('open'); document.getElementById('adminProfileMenuTrigger').setAttribute('aria-expanded', 'false'); copyPrizeCardsToSheets(); return false;">
              <span class="profile-menu-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                  <path d="M8 7h8"></path>
                  <path d="M8 12h8"></path>
                  <path d="M8 17h8"></path>
                  <rect x="5" y="4" width="14" height="16" rx="2"></rect>
                </svg>
              </span>
              <span class="profile-menu-text">Copy Cards to Sheets</span>
            </button>
          </div>

          <div class="profile-menu-section">
            <button type="button" class="profile-menu-item" onclick="document.getElementById('adminProfileMenu').classList.remove('open'); document.getElementById('adminProfileMenuTrigger').setAttribute('aria-expanded', 'false'); showRecentImportsModal(); return false;">
              <span class="profile-menu-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                  <path d="M12 6v6l4 2"></path>
                  <circle cx="12" cy="12" r="9"></circle>
                </svg>
              </span>
              <span class="profile-menu-text">Recent Imports</span>
            </button>
          </div>

          <div class="profile-submenu" id="adminToolsSubmenu">
            <button type="button" class="profile-submenu-trigger" id="adminToolsSubmenuTrigger" aria-expanded="false">
              <span class="profile-menu-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                  <path d="M12 3l2.2 2.1 3-.3.8 2.9 2.6 1.6-1.3 2.7 1.3 2.7-2.6 1.6-.8 2.9-3-.3L12 21l-2.2-2.1-3 .3-.8-2.9-2.6-1.6 1.3-2.7-1.3-2.7 2.6-1.6.8-2.9 3 .3z"></path>
                  <circle cx="12" cy="12" r="3.2"></circle>
                </svg>
              </span>
              <span class="profile-menu-text">Admin</span>
              <span class="profile-submenu-arrow">&lt;</span>
            </button>

            <div class="profile-submenu-panel" id="adminToolsSubmenuPanel">
              <div class="profile-submenu-list">
                <button type="button" class="profile-submenu-item" onclick="document.getElementById('adminProfileMenu').classList.remove('open'); document.getElementById('adminProfileMenuTrigger').setAttribute('aria-expanded', 'false'); showGuildSettingsModal(); return false;">Guild Settings</button>
% if request.user is not None and request.user.has_global_role("superadmin"):
                <button type="button" class="profile-submenu-item" onclick="document.getElementById('adminProfileMenu').classList.remove('open'); document.getElementById('adminProfileMenuTrigger').setAttribute('aria-expanded', 'false'); showManageAccessModal(); return false;">User Access</button>
% endif
                <button type="button" class="profile-submenu-item" onclick="document.getElementById('adminProfileMenu').classList.remove('open'); document.getElementById('adminProfileMenuTrigger').setAttribute('aria-expanded', 'false'); showBountyListModal(); return false;">Barter Bounty List</button>
                <button type="button" class="profile-submenu-item" onclick="document.getElementById('adminProfileMenu').classList.remove('open'); document.getElementById('adminProfileMenuTrigger').setAttribute('aria-expanded', 'false'); showBarterSummaryModal(); return false;">Barter Summary</button>
                <a class="profile-submenu-item is-placeholder" href="#" onclick="return false;">Templates</a>
              </div>
            </div>
          </div>

          <div class="profile-menu-divider"></div>
          <div class="profile-submenu" id="accountSubmenu">
            <button type="button" class="profile-submenu-trigger" id="accountSubmenuTrigger" aria-expanded="false">
              <span class="profile-menu-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                  <circle cx="12" cy="8" r="3"></circle>
                  <path d="M5 20c0-3.2 3-5.5 7-5.5s7 2.3 7 5.5"></path>
                </svg>
              </span>
              <span class="profile-menu-text">${request.user.name if request.user is not None else 'Account'}</span>
              <span class="profile-submenu-arrow">&lt;</span>
            </button>

            <div class="profile-submenu-panel" id="accountSubmenuPanel">
              <div class="profile-submenu-list">
                <button type="button" class="profile-submenu-item" onclick="document.getElementById('adminProfileMenu').classList.remove('open'); document.getElementById('adminProfileMenuTrigger').setAttribute('aria-expanded', 'false'); showAccountSettingsModal(); return false;">Account Settings</button>
                <button type="button" class="profile-submenu-item" onclick="document.getElementById('adminProfileMenu').classList.remove('open'); document.getElementById('adminProfileMenuTrigger').setAttribute('aria-expanded', 'false'); showChangePasswordModal(false); return false;">Change Password</button>
              </div>
            </div>
          </div>

          <div class="profile-menu-section">
            <a class="profile-menu-item is-placeholder" href="#" onclick="return false;">
              <span class="profile-menu-icon">
                  <svg viewBox="0 0 24 24" aria-hidden="true">
                    <circle cx="12" cy="12" r="9"></circle>
                    <path d="M12 8v5"></path>
                  <path d="M12 16h.01"></path>
                </svg>
              </span>
              <span class="profile-menu-text">Help</span>
            </a>
          </div>

          <div class="profile-menu-section">
          <a class="profile-menu-item" href="/${request.matchdict.get('guild')}/auth/logout">
            <span class="profile-menu-icon">
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M10 4H5a1 1 0 0 0-1 1v14a1 1 0 0 0 1 1h5"></path>
                <path d="M14 8l6 4-6 4"></path>
                <path d="M20 12H9"></path>
              </svg>
            </span>
            <span class="profile-menu-text">Logout</span>
          </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<section class="card admin-header">
  <div class="header-left">
    <img id="mainLogo" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="Guild logo">

    <div class="title-block">
      <h1 id="display_guild_header"></h1>
% if is_staging:
      <div class="stage-pill">${stage_label}</div>
% endif
      <div class="sub"><strong id="display_raffle_subheader"></strong><span id="display_raffle_meta_sep"></span><span id="display_raffle_time"></span></div>
    </div>
  </div>

  <div class="header-right">
    <div class="stats-inline">
      <div class="stat"><div class="k">Total Tickets</div><div class="v" id="display_raffle_sold">0</div></div>
      <div class="stat"><div class="k">Participants</div><div class="v" id="display_raffle_participants">0</div></div>
    </div>
  </div>
</section>

<form id="ginfo_form">
<section class="button-bar">
  <div class="button-bar-left">
    <span class="button-bar-label">Admin Tools</span>
    <div class="tool-cluster">
      <button type="button" class="action-btn" onclick="$('#new_raffle_button').click()">Open New Raffle</button>
      <details class="tool-menu tool-menu-edit">
        <summary class="action-btn tool-menu-trigger">Edit Raffle <span class="tool-menu-caret">v</span></summary>
        <div class="tool-menu-panel">
          <div class="tool-panel-title">Raffle Setup</div>
            <div class="tool-form-grid">
              <div class="tool-field">
                <label for="raffle_title">Raffle Name</label>
                <input type="text" id="raffle_title" class="ginfo_change_save tool-input" name="raffle_title"/>
              </div>
            <div class="tool-field">
              <label for="raffle_subheader">Raffle Number</label>
              <input type="text" id="raffle_subheader" class="ginfo_change_save tool-input" name="raffle_guild_num"/>
            </div>
            <div class="tool-field">
              <label for="raffle_time">Drawing Time</label>
              <input type="text" id="raffle_time" class="ginfo_change_save tool-input" name="raffle_time"/>
            </div>
              <div class="tool-field">
                <label for="raffle_cost">Ticket Cost</label>
                <input type="text" id="raffle_cost" class="ginfo_change_save tool-input" name="raffle_ticket_cost"/>
              </div>
              <div class="tool-field is-wide barter-toggle-field">
                <label>Import Rules</label>
                <div class="tool-form-grid">
                  <div class="barter-toggle-shell">
                    <label class="barter-toggle-switch" for="raffleGoldMailEnabledToggle">
                      <input type="checkbox" id="raffleGoldMailEnabledToggle" class="barter-toggle-input" data-mode="current" data-field="raffle_gold_mail_enabled" />
                      <span class="barter-toggle-slider"></span>
                    </label>
                    <div class="barter-toggle-copy">
                      <span class="barter-toggle-label">Gold-Mail</span>
                      <span class="barter-toggle-value">OFF</span>
                    </div>
                  </div>
                  <div class="barter-toggle-shell">
                    <label class="barter-toggle-switch" for="raffleGoldBankEnabledToggle">
                      <input type="checkbox" id="raffleGoldBankEnabledToggle" class="barter-toggle-input" data-mode="current" data-field="raffle_gold_bank_enabled" />
                      <span class="barter-toggle-slider"></span>
                    </label>
                    <div class="barter-toggle-copy">
                      <span class="barter-toggle-label">Gold-Bank</span>
                      <span class="barter-toggle-value">OFF</span>
                    </div>
                  </div>
                  <div class="barter-toggle-shell">
                    <label class="barter-toggle-switch" for="raffleBarterMailEnabledToggle">
                      <input type="checkbox" id="raffleBarterMailEnabledToggle" class="barter-toggle-input" data-mode="current" data-field="raffle_barter_mail_enabled" />
                      <span class="barter-toggle-slider"></span>
                    </label>
                    <div class="barter-toggle-copy">
                      <span class="barter-toggle-label">Barter-Mail</span>
                      <span class="barter-toggle-value">OFF</span>
                    </div>
                  </div>
                  <div class="barter-toggle-shell">
                    <label class="barter-toggle-switch" for="raffleBarterBankEnabledToggle">
                      <input type="checkbox" id="raffleBarterBankEnabledToggle" class="barter-toggle-input" data-mode="current" data-field="raffle_barter_bank_enabled" />
                      <span class="barter-toggle-slider"></span>
                    </label>
                    <div class="barter-toggle-copy">
                      <span class="barter-toggle-label">Barter-Bank</span>
                      <span class="barter-toggle-value">OFF</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </details>
      </div>

    <div class="tool-cluster">
% if request.extended_tickets:
      <details class="tool-menu">
        <summary class="action-btn tool-menu-trigger">Import <span class="tool-menu-caret">v</span></summary>
        <div class="tool-menu-panel">
          <div class="tool-menu-actions">
            <button type="button" class="tool-menu-action" onclick="$('#import_paid').click(); closeToolMenus();">Paid</button>
            <button type="button" class="tool-menu-action" onclick="$('#import_barter').click(); closeToolMenus();">Barter</button>
          </div>
        </div>
      </details>
% endif

      <details class="tool-menu">
        <summary class="action-btn tool-menu-trigger">Re-Show <span class="tool-menu-caret">v</span></summary>
        <div class="tool-menu-panel">
          <div class="tool-menu-actions">
            <button type="button" class="tool-menu-action" onclick="$('#reshow_import').click(); closeToolMenus();">Imports</button>
            <button type="button" class="tool-menu-action" onclick="$('#reshow_confirm').click(); closeToolMenus();">Confirms</button>
            <button type="button" class="tool-menu-action" onclick="showRecentImportsModal(); closeToolMenus();">Recent Imports</button>
          </div>
        </div>
      </details>
    </div>
  </div>

  <div class="button-bar-right">
    <div class="status-tool">
      <div class="status-select-shell">
        <select id="raffle_status" class="ginfo_change_save tool-input status-tool-select" name="raffle_status">
          <option value="LIVE">&#128994; LIVE</option>
          <option value="ROLLING">&#127922; ROLLING</option>
          <option value="COMPLETE">&#128308; COMPLETE</option>
        </select>
      </div>
    </div>
  </div>

  <div class="admin-form-hidden">
    <span id="guild_header" class="legacy-summary-hide"></span>
    <textarea id="raffle_notes" name="raffle_notes" class="hidden-note-field"></textarea>
    <textarea id="raffle_notes_admin" name="raffle_notes_admin" class="hidden-note-field"></textarea>
    <textarea id="raffle_notes_public_2" name="raffle_notes_public_2" class="hidden-note-field"></textarea>
    <span id="raffle_sold" class="legacy-summary-hide"></span>
    <span id="raffle_participants" class="legacy-summary-hide"></span>
    <span id="raffle_updated" class="legacy-summary-hide"></span>
  </div>
</section>
</form>

<div class="admin-form-hidden">
  <input type="button" value="Open new raffle" id="new_raffle_button" class="hidden-original-action" />
  <input type="submit" value="Manually refresh" id="manual_refresh" class="hidden-original-action" />
  <input type="submit" value="Re-Show Import Pane" id="reshow_import" class="hidden-original-action" />
  <input type="submit" value="Re-Show Confirmations Pane" id="reshow_confirm" class="hidden-original-action" />
  <input type="button" value="Re-Show Recent Imports" id="reshow_recent_imports" class="hidden-original-action" />
% if request.extended_tickets:
  <input type="submit" value="Import barter tickets" id="import_barter" class="hidden-original-action" />
  <input type="submit" value="Import paid tickets" id="import_paid" class="hidden-original-action" />
% endif
</div>

<section class="admin-utility-band">
  <div class="utility-panel notes-panel is-read-mode" id="notesPanel">
    <div class="utility-panel-title">
      <div class="notes-header-shell">
        <div class="note-tab-strip">
          <button type="button" class="note-tab active" data-note-key="raffle_notes_admin">ADMIN</button>
          <button type="button" class="note-tab" data-note-key="raffle_notes">PUBLIC 1</button>
          <button type="button" class="note-tab" data-note-key="raffle_notes_public_2">PUBLIC 2</button>
        </div>
        <div class="note-save-group">
          <button type="button" class="note-action-btn note-edit-toggle" id="notesEditorToggle"><span class="note-action-icon" aria-hidden="true"></span><span>Edit Notes</span></button>
          <span class="note-save-status" id="notesSaveStatus">Saved</span>
          <button type="button" class="note-action-btn note-save-btn" id="notesSaveBtn" style="display:none;">Saved</button>
        </div>
      </div>
    </div>
    <div class="utility-panel-body">
      <div class="notes-editor-toolbar">
        <button type="button" class="note-tool" data-cmd="bold" title="Bold">B</button>
        <button type="button" class="note-tool" data-cmd="italic" title="Italic">I</button>
        <button type="button" class="note-tool" data-cmd="underline" title="Underline">U</button>
        <button type="button" class="note-tool" data-cmd="insertUnorderedList" title="Bulleted list">Bullet List</button>
        <button type="button" class="note-tool" data-cmd="insertOrderedList" title="Numbered list">1. List</button>
        <button type="button" class="note-tool note-link" data-cmd="createLink" title="Insert link">Link</button>
        <input type="color" id="notesTextColor" class="note-color" value="#f4f7ff" title="Text color" />
      </div>
      <div
        id="notesEditorSurface"
        class="notes-editor-surface is-empty"
        contenteditable="true"
        data-placeholder="Write notes here, then click Save All."
      ></div>
    </div>
  </div>

  <div class="utility-panel upload-panel">
    <div class="utility-panel-title">Import Tickets</div>
    <div class="utility-panel-body">
      <form action="json/set/tickets_import" class="dropzone" id="dropzone_uploader">
        <div class="dz-message">
          <strong>Drop RaffleManager.lua here</strong>
          <span>or click to choose files</span>
        </div>
      </form>
    </div>
  </div>
</section>

<div id="main">
<table id="main_table" valign="top">
    <tr>
        
        <td id="column_guildinfo">
    <div id="left" class="column admin-form-hidden"></div>
        </td>
        <td id="column_prizeinfo">
    <div id="center" class="column">
        <div id="prize_info">
        </div>
        <div id="add_prize_block">
            <input type="button" value="Add prize" id="add_prize_button" />
        </div>
    </div>
        </td>
        <td id="column_ticketinfo">
    <div id="right" class="column">
        <div class="ticket-tools">
            <button type="button" class="ticket-copy-btn" id="copyNamesTotalsBtn" onclick="copyNamesAndTotals()">Copy Names + Totals</button>
        </div>
        <div id="ticket_info">
        </div>
        <div id="ticket_totals_footer"></div>
    </div>
        </td>
    </tr>
</table>
</div>
</div>

<div id="legacy_modal_backdrop"></div>

<div id="new_raffle_modal">
  <div class="new-raffle-modal-shell">
    <div class="new-raffle-modal-header">
      <div class="new-raffle-modal-title">
        <h2>Open New Raffle</h2>
        <p>Review the next raffle setup in one place. Leave anything alone to carry it forward, clear it, or edit it before creating the new week.</p>
      </div>
      <button type="button" class="new-raffle-modal-close" id="newRaffleModalClose">Close</button>
    </div>

    <div class="new-raffle-modal-body">
      <div class="new-raffle-overview">
        <div class="new-raffle-field">
          <label for="newRaffleNumber">Raffle Number</label>
          <input type="text" id="newRaffleNumber" />
        </div>
        <div class="new-raffle-field">
          <label for="newRaffleTime">Drawing Time</label>
          <input type="text" id="newRaffleTime" />
        </div>
        <div class="new-raffle-field">
          <label for="newRaffleCost">Ticket Cost</label>
          <input type="text" id="newRaffleCost" />
        </div>
        <div class="new-raffle-field">
          <label>Status</label>
          <div class="new-raffle-status-chip">LIVE</div>
        </div>
        <div class="new-raffle-field barter-toggle-field is-wide">
          <label>Import Rules</label>
          <div class="tool-form-grid">
            <div class="barter-toggle-shell">
              <label class="barter-toggle-switch" for="newRaffleGoldMailEnabled">
                <input type="checkbox" id="newRaffleGoldMailEnabled" class="barter-toggle-input" data-mode="new" data-field="raffle_gold_mail_enabled" />
                <span class="barter-toggle-slider"></span>
              </label>
              <div class="barter-toggle-copy">
                <span class="barter-toggle-label">Gold-Mail</span>
                <span class="barter-toggle-value">OFF</span>
              </div>
            </div>
            <div class="barter-toggle-shell">
              <label class="barter-toggle-switch" for="newRaffleGoldBankEnabled">
                <input type="checkbox" id="newRaffleGoldBankEnabled" class="barter-toggle-input" data-mode="new" data-field="raffle_gold_bank_enabled" />
                <span class="barter-toggle-slider"></span>
              </label>
              <div class="barter-toggle-copy">
                <span class="barter-toggle-label">Gold-Bank</span>
                <span class="barter-toggle-value">OFF</span>
              </div>
            </div>
            <div class="barter-toggle-shell">
              <label class="barter-toggle-switch" for="newRaffleBarterMailEnabled">
                <input type="checkbox" id="newRaffleBarterMailEnabled" class="barter-toggle-input" data-mode="new" data-field="raffle_barter_mail_enabled" />
                <span class="barter-toggle-slider"></span>
              </label>
              <div class="barter-toggle-copy">
                <span class="barter-toggle-label">Barter-Mail</span>
                <span class="barter-toggle-value">OFF</span>
              </div>
            </div>
            <div class="barter-toggle-shell">
              <label class="barter-toggle-switch" for="newRaffleBarterBankEnabled">
                <input type="checkbox" id="newRaffleBarterBankEnabled" class="barter-toggle-input" data-mode="new" data-field="raffle_barter_bank_enabled" />
                <span class="barter-toggle-slider"></span>
              </label>
              <div class="barter-toggle-copy">
                <span class="barter-toggle-label">Barter-Bank</span>
                <span class="barter-toggle-value">OFF</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="new-raffle-field">
        <label for="newRaffleTitle">Raffle Name</label>
        <input type="text" id="newRaffleTitle" placeholder="Optional - leave blank to use &quot;Raffle&quot;" />
      </div>

      <div class="new-raffle-options">
        <label class="new-raffle-option" for="newRaffleClonePrizes">
          <input type="checkbox" id="newRaffleClonePrizes" />
          <span class="new-raffle-option-copy">
            <span class="new-raffle-option-title">Clone Prize Cards To New Raffle</span>
            <span class="new-raffle-option-help">Copies all current prize cards into the new week, including their spotlight tier. Winner/ticket lock state is reset for the new raffle.</span>
          </span>
        </label>
      </div>

      <div class="new-raffle-notes-grid">
        <div class="new-raffle-note-card">
          <div class="new-raffle-note-header">
            <h3>Admin Notes</h3>
          </div>
          <div class="new-raffle-toolbar">
            <button type="button" class="note-tool new-raffle-tool" data-cmd="bold" title="Bold">B</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="italic" title="Italic">I</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="underline" title="Underline">U</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="insertUnorderedList" title="Bulleted list">Bullet List</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="insertOrderedList" title="Numbered list">1. List</button>
            <button type="button" class="note-tool note-link new-raffle-tool" data-cmd="createLink" title="Insert link">Link</button>
            <input type="color" class="note-color new-raffle-color" value="#f4f7ff" title="Text color" />
            <button type="button" class="new-raffle-clear">Clear</button>
          </div>
          <div class="new-raffle-editor is-empty" contenteditable="true" data-note-key="raffle_notes_admin" data-placeholder="Admin notes for the new raffle."></div>
        </div>

        <div class="new-raffle-note-card">
          <div class="new-raffle-note-header">
            <h3>Public 1 Notes</h3>
          </div>
          <div class="new-raffle-toolbar">
            <button type="button" class="note-tool new-raffle-tool" data-cmd="bold" title="Bold">B</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="italic" title="Italic">I</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="underline" title="Underline">U</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="insertUnorderedList" title="Bulleted list">Bullet List</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="insertOrderedList" title="Numbered list">1. List</button>
            <button type="button" class="note-tool note-link new-raffle-tool" data-cmd="createLink" title="Insert link">Link</button>
            <input type="color" class="note-color new-raffle-color" value="#f4f7ff" title="Text color" />
            <button type="button" class="new-raffle-clear">Clear</button>
          </div>
          <div class="new-raffle-editor is-empty" contenteditable="true" data-note-key="raffle_notes" data-placeholder="Public 1 notes for the new raffle."></div>
        </div>

        <div class="new-raffle-note-card">
          <div class="new-raffle-note-header">
            <h3>Public 2 Notes</h3>
          </div>
          <div class="new-raffle-toolbar">
            <button type="button" class="note-tool new-raffle-tool" data-cmd="bold" title="Bold">B</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="italic" title="Italic">I</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="underline" title="Underline">U</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="insertUnorderedList" title="Bulleted list">Bullet List</button>
            <button type="button" class="note-tool new-raffle-tool" data-cmd="insertOrderedList" title="Numbered list">1. List</button>
            <button type="button" class="note-tool note-link new-raffle-tool" data-cmd="createLink" title="Insert link">Link</button>
            <input type="color" class="note-color new-raffle-color" value="#f4f7ff" title="Text color" />
            <button type="button" class="new-raffle-clear">Clear</button>
          </div>
          <div class="new-raffle-editor is-empty" contenteditable="true" data-note-key="raffle_notes_public_2" data-placeholder="Public 2 notes for the new raffle."></div>
        </div>
      </div>
    </div>

    <div class="new-raffle-actions">
      <button type="button" class="new-raffle-secondary" id="newRaffleCancel">Cancel</button>
      <button type="button" class="new-raffle-primary" id="newRaffleCreate">Create Raffle</button>
    </div>
  </div>
</div>

<div id="prize_template">
<form id="prize_template_form">
<div class="prize prize-shell">
    <div class="prize-field prize-number-panel">
        <input type="text" class="prize_number" id="prize_number" name="prize_text2" placeholder="#" />
        <div class="prize-style-control">
            <span class="prize-style-label">Spotlight</span>
            <select id="prize_style" class="prize_style" name="prize_style">
                <option value="jackpot">Jackpot</option>
                <option value="grand">Grand Prize</option>
                <option value="featured">Featured</option>
                <option value="standard">Standard</option>
            </select>
        </div>
    </div>
    <div class="prize-main">
        <div class="prize-top-row">
            <div class="prize-field">
                <div class="prize-badge-row">
                    <span id="prize_badge" class="prize-badge"></span>
                </div>
                <input type="text" id="prize_item" class="prize_item" name="prize_text" placeholder="Prize Details Soon" />
            </div>
        </div>
        <div class="prize-middle-row">
            <div class="prize-field">
                <input type="text" id="prize_value" class="prize_value" name="prize_value" placeholder="Prize Value" />
            </div>
        </div>
        <div class="prize-bottom-row">
            <div class="prize-field">
                <input type="text" id="prize_winner" class="prize_winner" name="prize_winner" placeholder="Ticket #" />
            </div>
            <div class="prize-winner-display">
                <span id="prize_winner_name" class="prize_winner_name" data-placeholder="Winner"></span>
            </div>
        </div>
    </div>
    <div class="prize-actions">
        <a href="#" id="prize_finalise" class="prize_finalise prize-action" title="Lock winner">L</a>
        <a href="#" id="prize_roll" class="prize_roll prize-action" title="Roll winner">R</a>
        <a href="#" id="prize_clone" class="prize_clone prize-action" title="Duplicate prize below">C</a>
        <a href="#" id="prize_delete" class="prize_delete prize-action" title="Delete prize">X</a>
    </div>
</div>
<input type="hidden" name="prize_id" value="" class="prize_id" />
</form>
</div>
<div id="import_template">
<div id="import_buttons"><button type="button" id="import_debug_copy" class="import-debug-copy">COPY DEBUG</button> <input type="button" value="Close" id="import_close_button" /> <input type="submit" value="Import Selected" id="import_selected" /></div>
<div id="import_data">
    <div id="import_file_summary" class="import-file-summary" style="display:none;">
        <div class="import-file-summary-row">
            <div id="import_file_summary_text" class="import-file-summary-text"></div>
        </div>
    </div>
    <div id="import_guardrail_summary" class="import-summary-warning" style="display:none;">
        <p id="import_guardrail_summary_text" class="confirm-import-summary-text"></p>
    </div>
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
    <div id="confirm_import_summary">
        <p class="confirm-import-summary-title">Latest Import Summary</p>
        <p id="confirm_import_summary_text" class="confirm-import-summary-text"></p>
    </div>
    <div class="confirm-copy-block">
        <div class="confirm-copy-header">
            <p class="confirm-copy-label">Confirmation string</p>
            <button type="button" class="confirm-copy-btn" onclick="copyTextAreaValue('confirm_string', this)">Copy</button>
        </div>
        <textarea id="confirm_string"></textarea>
    </div>
    <div class="confirm-copy-block">
        <div class="confirm-copy-header">
            <p class="confirm-copy-label">Confirmation names</p>
            <button type="button" class="confirm-copy-btn" onclick="copyTextAreaValue('confirm_names', this)">Copy</button>
        </div>
        <textarea id="confirm_names"></textarea>
    </div>
</div>
</div>

<div id="change_password_template" class="confirm">
<div id="change_password_buttons"><input type="button" value="Close" id="change_password_close_button" /></div>
<div id="change_password_data">
    <div class="manage-access-section">
        <div class="manage-access-card">
            <p class="manage-access-title">Change Password</p>
            <div class="manage-access-password-row is-separated">
                <input type="password" id="changePasswordCurrent" placeholder="Current password" autocomplete="current-password" class="manage-access-full" />
            </div>
            <div class="manage-access-password-row is-pair">
                <input type="password" id="changePasswordNew" placeholder="New password" autocomplete="new-password" />
                <input type="password" id="changePasswordConfirm" placeholder="Confirm new password" autocomplete="new-password" />
            </div>
            <div class="manage-access-password-tools">
                <label class="manage-access-checkbox"><input type="checkbox" id="changePasswordShow" onchange="setPasswordFieldsVisible(['changePasswordCurrent','changePasswordNew','changePasswordConfirm'], this.checked)" /> <span>Show passwords</span></label>
            </div>
            <div class="manage-access-actions">
                <button type="button" class="manage-access-btn" onclick="submitOwnPasswordChange()">Save Password</button>
            </div>
            <p class="manage-access-status" id="changePasswordStatus"></p>
        </div>
    </div>
</div>
</div>

<div id="account_settings_template" class="confirm">
<div id="change_password_buttons"><input type="button" value="Close" id="account_settings_close_button" /></div>
<div id="change_password_data">
    <div class="manage-access-section">
        <div class="manage-access-card">
            <p class="manage-access-title">Account Settings</p>
            <div class="guild-settings-fields">
                <label class="guild-settings-field">
                    <span class="guild-settings-label">Time Zone</span>
                    <select id="accountSettingsTimeZone" class="guild-settings-select"></select>
                    <span class="guild-settings-help is-inline">Admin-only timestamps can follow your own preferred zone without affecting public viewers.</span>
                </label>
                <label class="guild-settings-field">
                    <span class="guild-settings-label">Date / Time Format</span>
                    <select id="accountSettingsDateTimeFormat" class="guild-settings-select"></select>
                    <span class="guild-settings-help is-inline">This changes how times are displayed for you in admin areas like Last Updated and import review.</span>
                </label>
            </div>
            <div class="manage-access-actions account-settings-actions">
                <button type="button" class="manage-access-btn subtle" onclick="hideLegacyModal('#account_settings_template'); showChangePasswordModal(false)">Change Password</button>
                <button type="button" class="manage-access-btn" onclick="saveAccountSettings()">Save Preferences</button>
            </div>
            <p class="manage-access-status" id="accountSettingsStatus"></p>
        </div>
    </div>
</div>
</div>

<div id="manage_access_template" class="confirm">
<div id="manage_access_buttons"><input type="button" value="Close" id="manage_access_close_button" /></div>
<div id="manage_access_data">
    <div class="manage-access-section">
        <div class="manage-access-card">
            <p class="manage-access-title">Create User</p>
            <div class="manage-access-create">
                <input type="text" id="manageAccessUsername" placeholder="Username" autocomplete="off" autocapitalize="off" spellcheck="false" data-lpignore="true" data-1p-ignore="true" />
                <input type="password" id="manageAccessPassword" placeholder="Temporary password" autocomplete="new-password" data-lpignore="true" data-1p-ignore="true" />
                <input type="password" id="manageAccessPasswordConfirm" placeholder="Confirm temporary password" autocomplete="new-password" class="manage-access-full" data-lpignore="true" data-1p-ignore="true" />
                <div class="manage-access-password-tools manage-access-full">
                    <label class="manage-access-checkbox"><input type="checkbox" id="manageAccessShowPassword" onchange="setPasswordFieldsVisible(['manageAccessPassword','manageAccessPasswordConfirm'], this.checked)" /> <span>Show password</span></label>
                </div>
                <label class="manage-access-checkbox manage-access-full"><input type="checkbox" id="manageAccessCreateSuperadmin" /> <span>Superadmin</span></label>
                <div class="manage-access-guilds manage-access-full" id="manageAccessCreateGuilds"></div>
                <div class="manage-access-actions manage-access-full">
                    <button type="button" class="manage-access-btn" onclick="createAccessUser()">Create User</button>
                </div>
            </div>
        </div>
        <div class="manage-access-card">
            <p class="manage-access-title">User Access</p>
            <p class="manage-access-status" id="manageAccessStatus"></p>
            <div class="manage-access-grid" id="manage_access_users"></div>
        </div>
    </div>
</div>
</div>

<div id="guild_settings_template" class="confirm">
  <div id="manage_access_buttons">
      <div class="guild-settings-toolbar">
          <button type="button" class="manage-access-btn" onclick="saveGuildSettings()">Save Settings</button>
          <p class="manage-access-status guild-settings-toolbar-status" id="guildSettingsStatus"></p>
      </div>
      <input type="button" value="Close" id="guild_settings_close_button" />
  </div>
  <div id="manage_access_data">
      <div class="manage-access-section">
          <div class="manage-access-card">
              <p class="manage-access-title">Guild Settings</p>
              <div class="guild-settings-grid">
                  <div class="guild-settings-section">
                      <p class="guild-settings-section-title">Identity</p>
                      <div class="guild-settings-fields">
                          <div class="guild-settings-row">
                              <label class="guild-settings-field">
                                  <span class="guild-settings-label">Guild Name</span>
                                  <input type="text" id="guildSettingsName" class="guild-settings-input" placeholder="Guild display name" />
                              </label>
                              <label class="guild-settings-field">
                                  <span class="guild-settings-label">Guild Shortname / Slug</span>
                                  <input type="text" id="guildSettingsShortname" class="guild-settings-input" placeholder="Guild shortname / slug" />
                                  <span class="guild-settings-help is-inline">Changing this changes the guild URL path. Use lowercase letters, numbers, dashes, or underscores.</span>
                              </label>
                          </div>
                          <div class="guild-settings-row">
                              <label class="guild-settings-field">
                                  <span class="guild-settings-label">ESO Guild ID</span>
                                  <input type="text" id="guildSettingsEsoId" class="guild-settings-input" placeholder="ESO Guild ID" />
                                  <span class="guild-settings-help is-inline">If you do not know this yet, we can learn it from a known-good bank export later.</span>
                              </label>
                              <label class="guild-settings-field">
                                  <span class="guild-settings-label">Guild Logo URL</span>
                                  <input type="text" id="guildSettingsLogoUrl" class="guild-settings-input" placeholder="https://example.com/logo.png" />
                                  <img id="guildSettingsLogoPreview" class="guild-logo-preview" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="Guild logo preview" />
                              </label>
                          </div>
                          <div class="guild-settings-row">
                              <label class="guild-settings-field">
                                  <span class="guild-settings-label">Game Server</span>
                                  <select id="guildSettingsGameServer" class="guild-settings-select">
                                    <option value="PC-NA">PC-NA</option>
                                  </select>
                              </label>
                              <label class="guild-settings-field">
                                  <span class="guild-settings-label">Guild Favicon URL</span>
                                  <input type="text" id="guildSettingsFaviconUrl" class="guild-settings-input" placeholder="https://example.com/favicon.png" />
                                  <img id="guildSettingsFaviconPreview" class="guild-logo-preview" src="/static/favicon-256.png" alt="Guild favicon preview" />
                              </label>
                          </div>
                          <div class="guild-settings-row is-single">
                              <label class="guild-settings-field">
                                  <span class="guild-settings-label">Guild Time Zone</span>
                                  <select id="guildSettingsTimeZone" class="guild-settings-select"></select>
                              </label>
                          </div>
                          <div class="guild-settings-row is-full">
                              <div class="guild-settings-field is-full">
                                  <span class="guild-settings-label">Sitewide Primary Colors</span>
                                  <div class="guild-branding-row">
                                      <label class="guild-color-field">
                                          <input type="color" id="guildSettingsPrimaryColor" class="guild-color-input" value="#284CA6" />
                                          <span class="guild-color-swatch-label">Primary Color</span>
                                      </label>
                                      <label class="guild-color-field">
                                          <input type="color" id="guildSettingsAccentColor" class="guild-color-input" value="#5078D2" />
                                          <span class="guild-color-swatch-label">Accent Color</span>
                                      </label>
                                  </div>
                              </div>
                          </div>
                      </div>
                  </div>
                  <div class="guild-settings-section">
                      <p class="guild-settings-section-title">Import Rules</p>
                      <div class="guild-settings-rule-block">
                          <p class="guild-settings-rule-title">Whitelist</p>
                          <p class="guild-settings-help">Designate which ESO user inbox(es) tickets-by-mail are expected from. The system will warn against imports from inboxes not listed here.</p>
                          <div class="guild-mail-account-list manage-access-full" id="guildSettingsMailAccountsList"></div>
                          <div class="manage-access-actions manage-access-full">
                              <button type="button" class="manage-access-btn subtle" onclick="$('#guildSettingsMailAccountsList').append(buildGuildMailAccountRow('')); markGuildSettingsDirty();">Add Another Mail Account</button>
                          </div>
                      </div>
                      <div class="guild-settings-rule-block">
                          <p class="guild-settings-rule-title">Blacklist</p>
                          <p class="guild-settings-help">Designate which ESO usernames to ignore deposits or mailed gold from.</p>
                          <div class="guild-mail-account-list manage-access-full" id="guildSettingsImportBlacklistList"></div>
                          <div class="manage-access-actions manage-access-full">
                              <button type="button" class="manage-access-btn subtle" onclick="$('#guildSettingsImportBlacklistList').append(buildGuildBlacklistRow('')); markGuildSettingsDirty();">Add Another Ignored Name</button>
                          </div>
                      </div>
                  </div>
                  <div class="guild-settings-section">
                      <p class="guild-settings-section-title">Relationships</p>
                      <div class="guild-sister-list" id="guildSettingsSisterGuilds"></div>
                      <p class="guild-settings-help">Linked sister guilds will appear as quick-switch options in the admin profile menu.</p>
                  </div>
              </div>
          </div>
      </div>
</div>
</div>

<div id="bounty_list_template" class="confirm">
  <div id="manage_access_buttons">
      <div class="guild-settings-toolbar">
          <button type="button" class="manage-access-btn" onclick="saveBountyList()">Save Changes</button>
          <p class="manage-access-status guild-settings-toolbar-status" id="bountyListStatus"></p>
      </div>
      <div class="guild-settings-barter-strip">
          <div class="barter-toggle-shell">
            <label class="barter-toggle-switch" for="bountyListBarterMailEnabledToggle">
              <input type="checkbox" id="bountyListBarterMailEnabledToggle" class="barter-toggle-input" data-mode="current" data-field="raffle_barter_mail_enabled" />
              <span class="barter-toggle-slider"></span>
            </label>
            <div class="barter-toggle-copy">
              <span class="barter-toggle-label">Barter-Mail</span>
              <span class="barter-toggle-value">OFF</span>
            </div>
          </div>
          <div class="barter-toggle-shell">
            <label class="barter-toggle-switch" for="bountyListBarterBankEnabledToggle">
              <input type="checkbox" id="bountyListBarterBankEnabledToggle" class="barter-toggle-input" data-mode="current" data-field="raffle_barter_bank_enabled" />
              <span class="barter-toggle-slider"></span>
            </label>
            <div class="barter-toggle-copy">
              <span class="barter-toggle-label">Barter-Bank</span>
              <span class="barter-toggle-value">OFF</span>
            </div>
          </div>
      </div>
      <input type="button" value="Close" id="bounty_list_close_button" />
  </div>
  <div id="manage_access_data">
      <div class="manage-access-section">
          <div class="manage-access-card">
              <p class="manage-access-title">Barter Bounty List</p>
              <div class="bounty-list-shell">
                  <div class="bounty-list-toolbar">
                      <button type="button" class="manage-access-btn subtle" id="copyBountyListButton" onclick="copyBountyListToSpreadsheet()">Copy to Spreadsheet</button>
                  </div>
                  <p class="guild-settings-help">Barter rate is especially useful for low-value items. Example: if 3 Platinum Dust should equal 1 ticket, set quantity to 3 and barter rate to 1.</p>
                  <div class="bounty-list-grid">
                      <table class="bounty-list-table">
                          <colgroup>
                              <col class="col-name" />
                              <col class="col-code" />
                              <col class="col-qty" />
                              <col class="col-value" />
                              <col class="col-rate" />
                              <col class="col-actions" />
                          </colgroup>
                          <thead>
                              <tr>
                                  <th>Item Name</th>
                                  <th>Item Code</th>
                                  <th>Quantity</th>
                                  <th>Item Value</th>
                                  <th>Barter Rate</th>
                                  <th></th>
                              </tr>
                          </thead>
                          <tbody id="bountyListRows"></tbody>
                      </table>
                      <div class="manage-access-actions">
                          <button type="button" class="manage-access-btn subtle" onclick="$('#bountyListRows').append(buildBountyListRow({})); markBountyListDirty();">Add Item</button>
                      </div>
                  </div>
                  <div class="bounty-list-paste">
                      <p class="guild-settings-help">Paste rows from a spreadsheet in this order: Item Name, Item Code, Quantity, Item Value, Barter Rate.</p>
                      <textarea id="bountyListPasteInput" placeholder="Dreugh Wax&#9;ITEMCODE123&#9;1&#9;15000&#9;15"></textarea>
                      <div class="manage-access-actions">
                          <button type="button" class="manage-access-btn subtle" onclick="applyBountyImportText()">Load Pasted Rows</button>
                      </div>
                  </div>
              </div>
          </div>
      </div>
  </div>
</div>

<div id="recent_imports_template" class="confirm">
<div id="confirm_buttons"><input type="button" value="Close" id="recent_imports_close_button" onclick="hideLegacyModal('#recent_imports_template')" /></div>
<div id="confirm_data">
    <div id="recent_imports_data"></div>
</div>
</div>

<div id="barter_summary_template" class="confirm">
<div id="confirm_buttons"><input type="button" value="Close" id="barter_summary_close_button" onclick="hideLegacyModal('#barter_summary_template')" /></div>
<div id="confirm_data">
    <div id="barter_summary_data"></div>
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



