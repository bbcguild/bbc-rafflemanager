<%inherit file="base.mako"/>

<%block name="content">

<style>
.bottom-row {
  display: grid;
  grid-template-columns: 1.3fr 0.7fr;
  gap: 16px;
  align-items: start;
}

/* LEFT PANEL (FIXED FEEL) */
.prizes-panel {
  display: block;
}

.prizes {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* RIGHT PANEL */
.entrants-panel {
  display: flex;
  flex-direction: column;
  height: fit-content;
}

.entrants-body {
  display: flex;
  flex-direction: column;
}

.entrants-scroll {
  max-height: 600px;
  overflow-y: auto;
}
</style>

<div class="bottom-row">

  <!-- LEFT -->
  <div class="prizes-panel">
    <div id="prize_info" class="prizes"></div>
  </div>

  <!-- RIGHT -->
  <div class="entrants-panel">
    <div class="table-headline" id="entrants_headline"></div>
    <div class="table-sub">Tickets Lookup</div>

    <div class="entrants-body">
      <div class="thead">
        <div class="idx">#</div>
        <div>Name</div>
        <div class="total">Total</div>
      </div>

      <div class="entrants-scroll">
        <div id="recentEntrants"></div>
        <div id="allEntrants" style="display:none;"></div>
      </div>
    </div>
  </div>

</div>

</%block>