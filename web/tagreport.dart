import 'dart:html';
import 'dart:js';

var tagFreqTable = {};
var tumblrBlog = querySelector('#tumblr_blog');
var tumblrConsole = querySelector('#tumblr_console');
var tumblrInfo = querySelector('#tumblr_info');
var tumblrFetch = querySelector('#tumblr_fetch');
var tumblrTagReport = querySelector('#tumblr_tagreport');
var tumblrTotalPosts = 0;

main() {
  context['primeTumblrPursuit'] = (resp) {
    tumblrTotalPosts = resp['posts-total'];
    tumblrTagReport.innerHtml = resp['tumblelog']['description'];
    tumblrInfo.innerHtml = '${tumblrTotalPosts}';
    fetchTagData();
  };
  context['processTumblrData'] = (resp) {
    tallyTags(resp);
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
  sb.write('<table>');
  tagFreqTable.forEach((tn, tt) {
    sb.write('<tr><td class="celtex">${tn}<td class="celnum">${tt}</tr>');
  });
  sb.write('</table>');
  return sb.toString();
}

launchTumblrFetch(e) {
  tagFreqTable.clear();
  tumblrConsole.innerHtml = '';
  tumblrTagReport.innerHtml = 'Preparing launch...';
  ScriptElement script = new Element.tag('script');
  script.src = 'http://${tumblrBlog.value}/api/read/json/?callback=primeTumblrPursuit';
  document.body.children.add(script);
}

tallyTags(td) {
  for (var p in td['posts']) {
    tumblrConsole.innerHtml += ("${p['id']} ${p['tags']}<br>");
    if (p.hasProperty('tags')) {
      for (var t in p['tags']) {
        if (tagFreqTable.containsKey(t)) {
          tagFreqTable[t] += 1;
        } else {
          tagFreqTable[t] = 1;
        }
      }
    }
  }
}