import 'package:mustache/mustache.dart';
import 'package:redstone/server.dart' as app;
import 'dart:io' as io;
import 'package:shelf/shelf.dart' as shelf;
import 'package:redstone/query_map.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_mongo/manager.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:path/path.dart' as path;
import 'package:cookies/cookies.dart' as ck;
import 'package:redstone_mvc/redstone_mvc.dart' as mvc;
import 'garesco_email_server.dart';
import 'package:di/di.dart';
import 'package:redstone_utilities/redstone_utilities.dart';
import 'package:garesco_email/garesco_email.dart';

main() async {
  //var dbManager = new MongoDbManager('mongodb://192.168.59.103:8095/garesco_email', poolSize: 3);

  app.addPlugin(getMapperPlugin());
  app.addPlugin(mvc.mvcPluggin);

  app.addModule(new Module()
    ..bind(MongoConnection));

  app.setupConsoleLog();
  app.start(port: 9090);
}

@mvc.GroupController('/email', root: '/lib/views')
class TestEmail {
  @mvc.ViewController('/render', methods: const [app.POST])
  Email render(@Decode() Email email) => email;

  @mvc.DataController('/json', methods: const [app.POST])
  json(@Decode() Email email) => email;

  @mvc.DataController('/form', methods: const [app.POST], allowMultipartRequest: true)
  testForm(@Decode(from: const [app.FORM]) Email m) {
    print(m.urlBanner);
    return m;
  }
}

@mvc.ViewController ('/allTags', template: '''
{{#.}}
<p>
VNode {{.}} ({Object key, String type, Map<String, String> attrs, Map<String, String>
style, List<String> classes, List<VNode> children, bool content: false})
  => new VNode.element('{{.}}', key: key, type: type, attrs: attrs, style: style, classes: classes,
                              children: children, content: content);
</p>
{{/.}}
''')
allTags () => '''a, abbr, address, area, article, aside, audio, b, base, bdi, bdo, big, blockquote, body, br,
button, canvas, caption, cite, code, col, colgroup, data, datalist, dd, del, details, dfn, dialog,
div, dl, dt, em, embed, fieldset, figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6,
head, header, hr, html, i, iframe, img, input, ins, kbd, keygen, label, legend, li, link, main,
map, mark, menu, menuitem, meta, meter, nav, noscript, object, ol, optgroup, option, output,
p, param, picture, pre, progress, q, rp, rt, ruby, s, samp, script, section, select, small, source,
span, strong, style, sub, summary, sup, table, tbody, td, textarea, tfoot, th, thead, time,
title, tr, track, u, ul, variable, video, wbr'''
  .split(',')
  .map((s) => s.trim());

@mvc.ViewController ('/allSvg', template: '''
{{#tags}}
<p>
VNode {{.}} ({Object key, String type, Map<String, String> attrs, Map<String, String> style,
List<String> classes, List<VNode> children, bool content: false})
 => new VNode.svgElement('{{.}}', key: key, type: type, attrs: attrs, style: style, classes: classes, children: children, content: content);
</p>
{{/tags}}
''')
allSvg () => {'tags': '''circle, defs, ellipse, g, line, linearGradient, mask, path, pattern, polygon, polyline,
radialGradient, rect, stop, svg, text, tspan'''
.replaceAllMapped(' ', (_) => '')
.split(',')
};


