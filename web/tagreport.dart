import 'dart:html';
import 'dart:js';

var tumblrBlog = querySelector('#tumblr_blog');
var tumblrFetch = querySelector('#tumblr_fetch');
var tumblrTagReport = querySelector('#tumblr_tagreport');

main() {
  context['primeTumblrPursuit'] = (resp) {
    tumblrTagReport.innerHtml = resp['tumblelog']['description'];
    fetchTagData();
  };
  context['processTumblrData'] = (resp) {
    tumblrTagReport.innerHtml = generateTagReport(resp);
  };
  tumblrFetch.onClick.listen(launchTumblrFetch);
}

fetchTagData() {
  tumblrTagReport.innerHtml = 'Fetching <em>${tumblrBlog.value}</em> tag data...';
  ScriptElement script = new Element.tag('script');
  script.src = 'http://${tumblrBlog.value}/api/read/json/?num=50&callback=processTumblrData';
  document.body.children.add(script);
}

String generateTagReport(td) {
  var sb = new StringBuffer();
  for (var p in td['posts']) {
    if (p.hasProperty('tags')) {
      sb.write("${p['id']} ${p['tags']}<br>");
    }
  }
  return sb.toString();
}

launchTumblrFetch(e) {
  tumblrTagReport.innerHtml = 'Preparing launch...';
  ScriptElement script = new Element.tag('script');
  script.src = 'http://${tumblrBlog.value}/api/read/json/?callback=primeTumblrPursuit';
  document.body.children.add(script);
}
