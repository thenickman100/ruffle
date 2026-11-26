package {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;

    // Text field font sizes are limited to 1-127 before SWF 13, and to at
    // least 1 after. TextFormat objects keep any size.
    public class Test extends Sprite {
        public function Test() {
            trace("new TextFormat(null, 800).size: " + new TextFormat(null, 800).size);
            for each (var size:int in [0, -5, 12, 127, 128, 800]) {
                check("setTextFormat", size);
                check("defaultTextFormat", size);
                check("htmlText", size);
            }
        }

        private function check(how:String, size:int):void {
            var tf:TextField = new TextField();
            var format:TextFormat = new TextFormat(null, size);
            if (how == "setTextFormat") {
                tf.text = "ab";
                tf.setTextFormat(format);
            } else if (how == "defaultTextFormat") {
                tf.defaultTextFormat = format;
                tf.text = "ab";
            } else {
                tf.htmlText = '<font size="' + size + '">ab</font>';
            }
            trace(how + " " + size + ": " + tf.getTextFormat().size);
        }
    }
}
