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
  --page-gutter:18px;
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
}
.admin-header::before{
  content:"";
  position:absolute;
  top:50%;
  right:-28px;
  width:768px;
  height:768px;
  background-image:
    radial-gradient(circle at 34% 50%, rgba(7,12,22,0) 0%, rgba(7,12,22,.1) 38%, rgba(7,12,22,.34) 100%),
    url("/static/eso-ouroboros.png");
  background-repeat:no-repeat;
  background-position:center center, center center;
  background-size:100% 100%, auto;
  opacity:.12;
  filter:saturate(.52) brightness(.72);
  pointer-events:none;
  z-index:0;
  transform:translateY(-50%);
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
  border-radius:16px;
  border:1px solid rgba(95,132,212,.34);
  background:linear-gradient(180deg,rgba(22,34,58,.99),rgba(9,17,31,.99));
  box-shadow:var(--shadow);
  display:none;
  z-index:60;
  overflow:hidden;
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
.profile-submenu-trigger{
  gap:12px;
}
.profile-submenu-arrow{
  font-size:.82rem;
  line-height:1;
}
.profile-submenu-panel{
  position:absolute;
  top:-1px;
  right:calc(100% + 8px);
  width:248px;
  padding:0;
  border-radius:16px;
  border:1px solid rgba(95,132,212,.34);
  background:linear-gradient(180deg,rgba(18,29,50,.99),rgba(9,17,31,.99));
  box-shadow:var(--shadow);
  display:none;
  overflow:hidden;
}
.profile-submenu-panel::before{
  content:"";
  position:absolute;
  top:18px;
  right:-8px;
  width:14px;
  height:14px;
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
  border:none;
  border-radius:0;
  background:transparent;
  color:var(--text);
  font-size:.96rem;
  font-weight:800;
  text-align:left;
  cursor:pointer;
  border-top:1px solid rgba(95,132,212,.12);
}
.profile-submenu-item:hover,
.profile-submenu-item:focus{
  background:rgba(80,120,210,.11);
  outline:none;
}
.profile-menu-item.is-placeholder{
  opacity:.7;
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
.action-btn-primary{
  border-color:rgba(109,145,218,.24);
  background:rgba(18,31,53,.92);
  color:#f4f7ff;
  box-shadow:inset 0 1px 0 rgba(173,199,244,.08);
}
.action-btn-primary:hover,
.action-btn-primary:focus{
  background:rgba(25,43,73,.98);
  border-color:rgba(127,160,227,.3);
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
  min-height:42px;
  padding:0 18px;
  display:flex;
  align-items:center;
  color:#f4f7ff;
  font-size:1rem;
  font-weight:850;
  letter-spacing:.02em;
}

.notes-panel .utility-panel-title{
  background:linear-gradient(90deg,#1773c8,#1a4f8d);
}

.upload-panel .utility-panel-title{
  background:linear-gradient(90deg,#c97a1f,#a25e11);
}

.utility-panel-body{
  flex:1;
  padding:16px;
  display:flex;
  min-height:0;
}

.notes-panel .utility-panel-title{
  padding:10px 14px;
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
  grid-template-columns:minmax(0,1fr) minmax(430px, 480px);
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
  width:auto;
  overflow:hidden;
  height:auto !important;
}

#column_ticketinfo{
  display:block;
  vertical-align:top;
  min-width:0;
  width:100%;
  max-width:480px;
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
  overflow:hidden;
  height:auto !important;
}

#ticket_info{
  width:100%;
  height:auto !important;
  overflow:hidden;
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

#ticket_info .handsontable td:first-of-type{
  font-weight:700;
}

#ticket_info .handsontable .currentRow,
#ticket_info .handsontable .currentCol,
#ticket_info .handsontable .area{
  background:inherit !important;
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
  overflow:hidden;
  text-overflow:ellipsis;
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
  border:4px dotted rgba(70,118,208,.6);
  border-radius:20px;
  background:linear-gradient(180deg,rgba(6,14,28,.96),rgba(4,11,23,.96));
  display:flex;
  align-items:center;
  justify-content:center;
  padding:14px;
  box-shadow:inset 0 0 0 1px rgba(22,40,78,.55);
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
  color:#8ea0bf;
  font-size:.92rem;
}

#legacy_modal_backdrop{
  display:none;
  position:fixed;
  inset:0;
  background:rgba(7,11,18,.58);
  z-index:1900;
}

#import_template,
#confirm_template,
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
#barter_data,
#paid_data{
  height:auto !important;
  max-height:calc(100vh - 118px) !important;
  overflow:auto;
  padding:16px !important;
  box-sizing:border-box;
  background:#d8dce1 !important;
}

#import_data_here{
  width:100%;
  border-collapse:separate;
  border-spacing:0;
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

.prize_number{
  width:100%;
  min-height:112px;
  text-align:center;
  font-size:2.2rem !important;
  font-weight:900;
}

.prize_winner,
.prize_item,
.prize_value{
  min-height:42px;
}

.prize-shell{
  display:grid;
  grid-template-columns:94px minmax(0,1fr) 68px;
  gap:14px;
  align-items:stretch;
  width:100%;
  box-sizing:border-box;
  padding:10px;
  border:1px solid rgba(80,120,210,.18);
  border-radius:0;
  background:linear-gradient(180deg,rgba(9,18,35,.96),rgba(8,15,28,.98));
}

.prize-main{
  display:grid;
  grid-template-rows:auto auto auto;
  gap:14px;
  min-width:0;
}

.prize-top-row,
.prize-middle-row,
.prize-bottom-row{
  display:grid;
  gap:14px;
  min-width:0;
}

.prize-top-row,
.prize-middle-row{
  grid-template-columns:minmax(0,1fr);
}

.prize-bottom-row{
  grid-template-columns:110px minmax(0,1fr);
  align-items:center;
}

.prize-field{
  min-width:0;
}

.prize-field input[type="text"]{
  width:100%;
  box-sizing:border-box;
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
  gap:12px;
}

.prize-action{
  min-height:54px;
  border:1px solid rgba(80,120,210,.24);
  border-radius:18px;
  background:rgba(11,20,40,.92);
  color:#7f2ed3;
  font-size:0;
  font-weight:900;
  text-decoration:none;
  display:flex;
  align-items:center;
  justify-content:center;
  position:relative;
}
.prize-action::before{
  font-size:1.35rem;
  line-height:1;
}
.prize_finalise::before{
  content:"\1F512";
}
.prize_roll::before{
  content:"\1F3B2";
}
.prize_delete::before{
  content:"\1F5D1";
}

.prize-action:hover,
.prize-action:focus{
  color:#b15dff;
  outline:none;
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
    grid-template-columns:minmax(0,1fr) minmax(400px, 440px);
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
                return "ROLLING"
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

function syncLegacyModalState() {
        var anyVisible = $("#import_template:visible, #confirm_template:visible, #barter_template:visible, #paid_template:visible").length > 0
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

function loadNoteTab(noteKey) {
        persistActiveNoteDraft()
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

        loadNoteTab(NOTE_EDITOR_STATE.activeKey || "raffle_notes_admin")
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
                url: "json/set/raffle",
                data: $("#ginfo_form").serialize(),
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
        $.getJSON("json/set/prize_add", function (result) {
                if (result) {
                        get_prize_info({ scrollToLast: true })
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
        hideLegacyModal("#import_template")
        hideLegacyModal("#confirm_template")
        hideLegacyModal("#barter_template")
        hideLegacyModal("#paid_template")
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
    raffle_cost: ""
}

function normalizeFieldValue(value) {
    if (value === null || value === undefined) {
        return ""
    }
    return $.trim(String(value))
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
                loadNoteDraftsFromRaffle(result)
                applyAdminStatus(result["raffle_status"])

                CURRENT_RAFFLE_INFO.raffle_subheader = normalizeFieldValue(result["raffle_guild_num"])
                CURRENT_RAFFLE_INFO.raffle_time = normalizeFieldValue(result["raffle_time"])
                CURRENT_RAFFLE_INFO.raffle_cost = normalizeFieldValue(result["raffle_ticket_cost"])

                $("#display_raffle_subheader").text("#" + result["raffle_guild_num"] + " Raffle")
                $("#display_raffle_time").text("Drawing: " + result["raffle_time"])
            })
}
var get_prize_info = function (options) {
        options = options || {}
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
                    $("#prize_item", template).attr({"id": dom_id + "item"}).val(value["prize_text"])
                    var prizeValueField = $("#prize_value", template).attr({"id": dom_id + "value"})[0]
                    formatPrizeValueField(prizeValueField)
                    if (value["prize_finalised"] != 0) {
                        $("#prize_finalise", template).remove()
                        $("#prize_delete", template).remove()
                        $("#prize_roll", template).remove()
                    } else {
                        $("#prize_finalise", template).attr({"id": dom_id + "finalise"})
                        $("#prize_delete", template).attr({"id": dom_id + "delete"})
                        $("#prize_roll", template).attr({"id": dom_id + "roll"})
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

                    $("input[type='text'][name]", template).change(function () {
                            $.ajax({
                                type: "POST",
                                url: "json/set/prize",
                                data: $("#" + dom_id + "form").serialize(),
                                success: function (result) {
                                    get_prize_info()
                                },
                                xhrFields: {
                                    withCredentials: true
                                },
                                })

                            })

                    $("#prize_info").append(template)
                    lastPrizeCard = $("#" + dom_id + "block")
                })

                if (options.scrollToLast && lastPrizeCard && lastPrizeCard.length) {
                    lastPrizeCard[0].scrollIntoView({ behavior: "smooth", block: "nearest" })
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
                        height: "auto",
                        rowHeaders: false,
                        colHeaders: ["#", "Name", "Total", "Paid", "Bar", "Range"],
                        colWidths: [36, 138, 50, 50, 50, 104],
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
                        colWidths: [54, 156, 54, 104],
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
                        if (trackedMap[fieldId]) {
                            CURRENT_RAFFLE_INFO[trackedMap[fieldId]] = normalizeFieldValue($field.val())
                        }
                    },
                    xhrFields: {
                        withCredentials: true
                    }
                })
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
                    var newRaffleNumber = promptForNewRaffleNumber()
                    if (newRaffleNumber === null) { return }

                    var r = confirm("This will close the current raffle, open raffle #" + newRaffleNumber + ", carry forward the drawing time and ticket cost, clear the raffle title, and set status to LIVE. Continue?")
                    if (r == false) { return }

                    $.getJSON("json/set/open_raffle", { raffle_guild_num: newRaffleNumber }, function (result) {
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
                
                showLegacyModal("#import_template", "import")
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

            $("#import_close_button").click(function () { hideLegacyModal("#import_template") })
            $("#confirm_close_button").click(function () { hideLegacyModal("#confirm_template") })
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
          $("#reshow_import").click(function () { hideLegacyModal("#confirm_template")
                                                  showLegacyModal("#import_template", "import") })
          $("#reshow_confirm").click(function () { showLegacyModal("#confirm_template", "confirm")
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
                                    hideLegacyModal("#paid_template")
                                    showLegacyModal("#confirm_template", "confirm")
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
})
</script>
</head>
<body>
<div class="page-shell">

<div class="admin-topbar">
  <div class="admin-topbar-updated" id="display_raffle_updated">Last Updated</div>
  <div class="admin-topbar-controls">
    <div class="profile-menu" id="adminProfileMenu">
      <button type="button" class="profile-menu-trigger" id="adminProfileMenuTrigger" aria-expanded="false" aria-haspopup="true">
        <span class="profile-trigger-logo-shell">
          <img class="profile-menu-logo" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="Guild logo">
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
          <div class="profile-submenu" id="adminTemplateSubmenu">
            <button type="button" class="profile-submenu-trigger" id="adminTemplateSubmenuTrigger" aria-expanded="false">
              <span class="profile-menu-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                  <path d="M12 3v18"></path>
                  <path d="M3 12h18"></path>
                  <path d="M5.5 5.5l13 13"></path>
                  <path d="M18.5 5.5l-13 13"></path>
                </svg>
              </span>
              <span class="profile-menu-text">Templates</span>
              <span class="profile-submenu-arrow">&lt;</span>
            </button>

            <div class="profile-submenu-panel" id="adminTemplateSubmenuPanel">
              <div class="profile-submenu-list">
                <button type="button" class="profile-submenu-item">Christmas</button>
                <button type="button" class="profile-submenu-item">Halloween</button>
                <button type="button" class="profile-submenu-item">Birthday</button>
                <button type="button" class="profile-submenu-item">Default</button>
                <a class="profile-menu-item is-placeholder" href="#" onclick="return false;">
                  <span class="profile-menu-icon">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                      <path d="M4 12h16"></path>
                      <path d="M12 4l8 8-8 8"></path>
                    </svg>
                  </span>
                  <span class="profile-menu-text">Manage Templates</span>
                </a>
              </div>
            </div>
          </div>

          <div class="profile-menu-section">
            <a class="profile-menu-item" href="/bbc1/">
              <span class="profile-menu-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                  <path d="M3 12h18"></path>
                  <path d="M15 5l6 7-6 7"></path>
                </svg>
              </span>
              <span class="profile-menu-text">BBC1</span>
            </a>
            <a class="profile-menu-item" href="/bbc2/">
              <span class="profile-menu-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                  <path d="M3 12h18"></path>
                  <path d="M15 5l6 7-6 7"></path>
                </svg>
              </span>
              <span class="profile-menu-text">BBC2</span>
            </a>
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
    <img id="mainLogo" src="https://www.bbcguild.com/wp-content/uploads/2020/04/cropped-cropped-BBC-LOGO-V2-2.gif" alt="BBC logo">

    <div class="title-block">
      <h1 id="display_guild_header">Guild</h1>
      <div class="sub"><strong id="display_raffle_subheader">Raffle</strong> • <span id="display_raffle_time">Drawing</span></div>
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
      <button type="button" class="action-btn action-btn-primary" onclick="$('#new_raffle_button').click()">Open New Raffle</button>
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
          <option value="COMPLETE">&#128308; CLOSED</option>
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

<div id="prize_template">
<form id="prize_template_form">
<div class="prize prize-shell">
    <div class="prize-field prize-number-panel">
        <input type="text" class="prize_number" id="prize_number" name="prize_text2" placeholder="#" />
    </div>
    <div class="prize-main">
        <div class="prize-top-row">
            <div class="prize-field">
                <input type="text" id="prize_item" class="prize_item" name="prize_text" placeholder="Prize" />
            </div>
        </div>
        <div class="prize-middle-row">
            <div class="prize-field">
                <input type="text" id="prize_value" class="prize_value" placeholder="Prize Value" />
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
        <a href="#" id="prize_finalise" class="prize_finalise prize-action" title="Finalize winner">L</a>
        <a href="#" id="prize_roll" class="prize_roll prize-action" title="Roll winner">R</a>
        <a href="#" id="prize_delete" class="prize_delete prize-action" title="Delete prize">X</a>
    </div>
</div>
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



