// Text field font sizes are limited to 1-127 before SWF 13.
var sizes = [0, -5, 12, 127, 128, 800];
for (var i = 0; i < sizes.length; i++) {
    var s = sizes[i];
    var f = new TextFormat("Arial", s);
    _root.createTextField("a" + i, i * 3, 0, 0, 100, 20);
    var t = _root["a" + i];
    t.text = "ab";
    t.setTextFormat(f);
    trace("setTextFormat " + s + ": " + t.getTextFormat().size);
    _root.createTextField("b" + i, i * 3 + 1, 0, 0, 100, 20);
    var u = _root["b" + i];
    u.setNewTextFormat(f);
    u.text = "ab";
    trace("setNewTextFormat " + s + ": " + u.getTextFormat().size);
    _root.createTextField("c" + i, i * 3 + 2, 0, 0, 100, 20);
    var h = _root["c" + i];
    h.html = true;
    h.htmlText = '<font size="' + s + '">ab</font>';
    trace("htmlText " + s + ": " + h.getTextFormat().size);
}
var g = new TextFormat("Arial", 800);
trace("TextFormat(800).size: " + g.size);
