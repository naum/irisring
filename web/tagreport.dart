import 'dart:html';
import 'dart:js';

var tumblrBlog = querySelector('#tumblr_blog');
var tumblrFetch = querySelector('#tumblr_fetch');
var tumblrTagReport = querySelector('#tumblr_tagreport');

main() {
  context['processTumblrData'] = (resp) {
    tumblrTagReport.innerHtml = resp['tumblelog']['description'];
  };
  tumblrFetch.onClick.listen(fetchTagData);
}

fetchTagData(e) {
  tumblrTagReport.innerHtml = 'You entered <em>${tumblrBlog.value}</em>';
  ScriptElement script = new Element.tag('script');
  script.src = 'http://${tumblrBlog.value}/api/read/json/?callback=processTumblrData';
  document.body.children.add(script);
}