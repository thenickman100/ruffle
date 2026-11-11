// test.swf also has a clip "box" (added by a script, see test.toml) holding an
// input text field "field" with the variable "text". The clip stops on frame 1;
// frame 2 is labelled "text_changed" and traces the text.
var n = 0;
onEnterFrame = function() {
    n++;
    if (n == 150) {
        trace("box frame after typing: " + box._currentframe);
        box.text = "variable";
        trace("set the variable, box frame: " + box._currentframe);
        box.field.text = "field";
        trace("set field.text, box frame: " + box._currentframe);
        box.field.replaceSel("!");
        trace("replaceSel, box frame: " + box._currentframe);
        delete onEnterFrame;
    }
};
