<%
import json
from mako.runtime import Undefined

ga4_measurement_id = (request.registry.settings.get("ga4_measurement_id") or "").strip()

def ga4_safe(value):
    if isinstance(value, Undefined):
        return ""
    if value is None:
        return ""
    return str(value)

ga4_context_payload = {
    "site_area": ga4_safe(ga4_site_area),
    "raffle_view": ga4_safe(ga4_raffle_view),
    "raffle_number": ga4_safe(ga4_raffle_number),
    "guild_slug": ga4_safe(ga4_guild_slug),
    "host_name": ga4_safe(request.host.split(":")[0] if request.host else ""),
}
%>
% if ga4_measurement_id:
<script async src="https://www.googletagmanager.com/gtag/js?id=${ga4_measurement_id}"></script>
<script>
window.dataLayer = window.dataLayer || [];
function gtag(){ dataLayer.push(arguments); }

var GA4_MEASUREMENT_ID = ${json.dumps(ga4_measurement_id) | n};
var GA4_CONTEXT = ${json.dumps(ga4_context_payload) | n};

gtag('js', new Date());
gtag('config', GA4_MEASUREMENT_ID, {
  send_page_view: false
});

gtag('event', 'page_view', Object.assign({
  page_title: document.title,
  page_location: window.location.href,
  page_path: window.location.pathname + window.location.search
}, GA4_CONTEXT));

document.addEventListener('click', function(event) {
  var link = event.target && event.target.closest ? event.target.closest('a[href]') : null;
  if (!link) return;

  var href = link.getAttribute('href') || '';
  if (!href || href.charAt(0) === '#') return;

  var url;
  try {
    url = new URL(href, window.location.href);
  } catch (err) {
    return;
  }

  if (!/docs\.google\.com$/i.test(url.hostname) || !/^\/spreadsheets\//i.test(url.pathname)) {
    return;
  }

  gtag('event', 'select_content', Object.assign({
    content_type: 'google_sheet_link',
    link_url: url.href,
    link_text: (link.textContent || '').trim().slice(0, 100),
    outbound: true
  }, GA4_CONTEXT));
});
</script>
% endif
