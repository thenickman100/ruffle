package {
    import flash.display.Sprite;
    import flash.events.EventDispatcher;
    import flash.text.engine.*;

    public class Test extends Sprite {
        public function Test() {
            var mirror:EventDispatcher = new EventDispatcher();

            var text:TextElement = new TextElement("hello", null, mirror, TextRotation.ROTATE_90);
            trace("TextElement eventMirror set: " + (text.eventMirror === mirror));
            trace("TextElement textRotation: " + text.textRotation);

            var elements:Vector.<ContentElement> = new Vector.<ContentElement>();
            elements.push(new TextElement("a"));
            var group:GroupElement = new GroupElement(elements, null, mirror, TextRotation.ROTATE_180);
            trace("GroupElement eventMirror set: " + (group.eventMirror === mirror));
            trace("GroupElement textRotation: " + group.textRotation);

            var plain:TextElement = new TextElement("plain");
            trace("default eventMirror: " + plain.eventMirror);
            trace("default textRotation: " + plain.textRotation);
        }
    }
}
