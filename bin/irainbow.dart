#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

var HC = new HttpClient();
var MAXPOSTNUM = 1000;
var STARTPOSTNUM = 0;
var TAGCLOUDMAX = 150;
var TUMBLOG = '';
var TUMTAGTAB = {};
var TURL = 'http://{TUMBLR_URL}/api/read/json/?num=50&start={SP}';

main(arg) {
  var maxpost = MAXPOSTNUM;
  if (arg.length > 0) {
    TUMBLOG = arg[0];
    if (arg.length > 1) {
      maxpost = int.parse(arg[1]);
    }
    for (var n = 0; n < maxpost; n += 50) {
      var du = new Duration(seconds: ((n ~/ 50) * 5));
      new Timer(du, () { 
          var tb = { 'TUMBLR_URL': TUMBLOG, 'SP': n };
          var desiredUrl = mold(TURL, tb);
          print('Fetching ${desiredUrl}...');
          grabWebContent(desiredUrl, showPageContent);
      });
    }
    new Timer(
      new Duration(seconds: (maxpost ~/ 50) * 5),
      showTagTab
    );
  } else {
    print('Usage: irisring.dart url');
  }
}

byTagTally(a, b) {
  return TUMTAGTAB[b] - TUMTAGTAB[a];
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

showPageContent(bc) {
  var tpc = makeTumblrMap(bc);
  for (var p in tpc['posts']) {
    if (p.containsKey('tags')) {
      print("${p['id']} ${p['tags']}");
      tallyTags(p['tags']);
    }
  }
}

showTagTab() {
  print('----');
  print(TUMTAGTAB);
  print('----');
  var stl = TUMTAGTAB.keys.toList();
  stl.sort(byTagTally);
  for (var t in stl) {
    print('$t: ${TUMTAGTAB[t]}');
  }
  print('----');
  if (stl.length > TAGCLOUDMAX) {
    stl = stl.sublist(0, TAGCLOUDMAX);
  }
  stl.sort();
  for (var t in stl) {
    var enct = Uri.encodeQueryComponent(t);
    print('<li><a href="http://${TUMBLOG}/tagged/${enct}">$t</a></li>');
  }
}

tallyTags(List tl) {
  for (var t in tl) {
    if (TUMTAGTAB.containsKey(t)) {
      TUMTAGTAB[t] += 1;
    } else {
      TUMTAGTAB[t] = 1;
    }
  }
}


