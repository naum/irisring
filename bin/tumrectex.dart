#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

var HC = new HttpClient();
var TUMBLOG = '';
var TURL = 'http://{TUMBLR_URL}/api/read/json/?type=text&num=50&start={SP}';

main(arg) {
  if (arg.length > 0) {
    TUMBLOG = arg[0];
    var tb = { 'TUMBLR_URL': TUMBLOG, 'SP': '0' };
    var desiredUrl = mold(TURL, tb);
    print('Fetching ${desiredUrl}...');
    grabWebContent(desiredUrl, showRecentTextPosts);
  } else {
    print('Usage: tumrectex.dart url');
  }
}

grabWebContent(u, f) {
  var url = Uri.parse(u);
  HC.getUrl(url)
    .then((HttpClientRequest request) {
      return request.close();
    })
    .then((HttpClientResponse response) {
      response.transform(new Utf8Decoder()).toList().then((data) {
        var body = data.join('');
        f(body);
      });
    });
}

makeTumblrMap(str) {
  var bp = 22;
  var ep = str.length - 2;
  var tjs = str.substring(bp, ep);
  return JSON.decode(tjs);
}

String mold(String t, Map b) {
  var reTS = new RegExp(r'\{(\w+)\}');
  var sout = t.replaceAllMapped(reTS, (m) {
    var s = m.group(1);
    return (b.containsKey(s)) ? b[s] : '';
  });
  return sout;
}

showRecentTextPosts(bc) {
  var tpc = makeTumblrMap(bc);
  for (var p in tpc['posts']) {
    print('<li><a href="${p['url-with-slug']}">${p['regular-title']}</a></li>');
  }
}

