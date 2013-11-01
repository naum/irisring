#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

var HC = new HttpClient();
var RE_SP = new RegExp('\{SP\}');
var MAXPOSTNUM = 300;
var STARTPOSTNUM = 0;
var TUMTAGTAB = {};
var TURL = 'http://azspot.net/api/read/json/?num=50&start={SP}';

main() {
  for (var n = 0; n < MAXPOSTNUM; n += 50) {
    var du = new Duration(seconds: ((n ~/ 50) * 10));
    new Timer(du, () { 
        var tu = TURL.replaceAll(RE_SP, '${n}');
        grabWebContent(tu, showPageContent);
    });
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

showPageContent(bc) {
  var tpc = makeTumblrMap(bc);
  for (var p in tpc['posts']) {
    if (p.containsKey('tags')) {
      print("${p['id']} ${p['tags']}");
    }
  }
}


