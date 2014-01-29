/**
 * 
 * Generate a Tumblr Tag Report for a Tumblr blog
 * 
 * TODO: add "ABORT" button, enable/disable "FETCH" button in midst of 
 *   processing
 * TODO: retain [tumblrBlog.value] in lieu of inadvertent input field fiddling
 * TODO: scrub [tumblrBlog.value] - remove trailing slash, "http(s)?//" prefix, etc.
 * 
 */

import 'dart:async' show Timer;
import 'dart:html';
import 'dart:js';
import 'dart:math' show min;

class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}

var maxPostFetch;
var tagFreqTable = {};
var tagStatTable = {
  'POST_COUNT': 0,
  'TAG_COUNT': 0,
  'TAGGED': 0,
  'UNTAGGED': 0
};
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
    tumblrInfo.innerHtml = formatTagStatInfo();
    tumblrTagReport.setInnerHtml(
      generateTagReport(resp), 
      treeSanitizer: new NullTreeSanitizer()
    );
  };
  tumblrFetch.onClick.listen(launchTumblrFetch);
}

affixExternalScriptJson(String s) {
  var script = new Element.tag('script');
  script.src = s;
  document.body.children.add(script);
}

int byTally(a, b) {
  return tagFreqTable[b] - tagFreqTable[a];
}

clearStatTable() {
  for (var k in tagStatTable.keys) {
    tagStatTable[k] = 0;
  }
}

fetchTagData() {
  var endPost;
  var tb = tumblrBlog.value;
  if (maxPostFetch == 'ALL') {
    endPost = int.parse(tumblrTotalPosts); 
  } else {
    endPost = min(int.parse(tumblrTotalPosts), int.parse(maxPostFetch)); 
  }
  for (var n = 0; n < endPost; n += 50) {
    var du = new Duration(seconds: (n ~/ 50) * 6);
    new Timer(du, () {
      var src = 'http://${tb}/api/read/json/?num=50&start=${n}&callback=processTumblrData';
      tumblrInfo.innerHtml = 'Fetching posts starting at ${n} of ${tumblrTotalPosts}!';
      affixExternalScriptJson(src);
    });
  }
}

String formatTagStatInfo() {
  var tp = tagStatTable['POST_COUNT'];
  var percentTagged = (100 * tagStatTable['TAGGED'] / tp).toStringAsFixed(1);
  var tagsPerPost = (tagStatTable['TAG_COUNT'] / tp).toStringAsFixed(2);
  return '${tp} TOTAL POSTS, ${percentTagged}% TAGGED, ${tagsPerPost} TAGS PER POST';
}

String formatBlogTagLink(tn, tally) {
  var etn = Uri.encodeQueryComponent(tn);
  return '<a href="http://${tumblrBlog.value}/tagged/${etn}">${tally}</a>';
}

String formatTumblrTagLink(tn) {
  var etn = Uri.encodeQueryComponent(tn);
  return '<a href="http://tumblr.com/tagged/${etn}">${tn}</a>';
}

String generateTagReport(td) {
  var sb = new StringBuffer();
  sb.write('<table>');
  sb.write('<tr class="rowhead"><td class="celtex">TAG<td class="celnum">#</tr>');
  var stl = tagFreqTable.keys.toList();
  stl.sort(byTally);
  for (var tn in stl) {
    var ltn = formatTumblrTagLink(tn);
    var ltt = formatBlogTagLink(tn, tagFreqTable[tn]);
    sb.write('<tr><td class="celtex">${ltn}<td class="celnum">${ltt}</tr>');
  }
  sb.write('</table>');
  return sb.toString();
}

launchTumblrFetch(e) {
  clearStatTable();
  tagFreqTable.clear();
  var tumblrMaxPostFetch = querySelector('#tumblr_max_post_fetch');
  maxPostFetch = tumblrMaxPostFetch.value;
  tumblrConsole.innerHtml = '';
  tumblrInfo.innerHtml = 'Preparing launch...';
  var src = 'http://${tumblrBlog.value}/api/read/json/?callback=primeTumblrPursuit';
  affixExternalScriptJson(src);
}

tallyTags(td) {
  for (var p in td['posts']) {
    tagStatTable['POST_COUNT'] += 1;
    //tumblrConsole.innerHtml += ("${p['id']} ${p['tags']}<br>");
    if (p.hasProperty('tags')) {
      tagStatTable['TAGGED'] += 1;
      for (var t in p['tags']) {
        tagStatTable['TAG_COUNT'] += 1;
        if (tagFreqTable.containsKey(t)) {
          tagFreqTable[t] += 1;
        } else {
          tagFreqTable[t] = 1;
        }
      }
    } else {
      tagStatTable['UNTAGGED'] += 1;
    }
  }
}
