import 'dart:html';

var tumblrBlog = querySelector('#tumblr_blog');
var tumblrFetch = querySelector('#tumblr_fetch');
var tumblrTagReport = querySelector('#tumblr_tagreport');

main() {
  tumblrFetch.onClick.listen((e) {
    tumblrTagReport.innerHtml = 'You entered <em>${tumblrBlog.value}</em>';
  });
}