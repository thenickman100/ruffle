package {
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.text.Font;

    // `MyFont` is linked to its embedded font only in frame 2
    // (see `make_swf.py`), but an instance is created in frame 1.
    public class Test extends MovieClip {
        private var early:Font = new MyFont();

        public function Test() {
            trace("frame 1, created in frame 1: " + describe(early));
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(e:Event):void {
            if (currentFrame != 2) {
                return;
            }
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            stop();
            trace("frame 2, created in frame 1: " + describe(early));
            trace("frame 2, created in frame 2: " + describe(new MyFont()));
        }

        private function describe(font:Font):String {
            return font.fontName + ", " + font.fontStyle + ", " + font.fontType + ", hasGlyphs(a)=" + font.hasGlyphs("a");
        }
    }
}

