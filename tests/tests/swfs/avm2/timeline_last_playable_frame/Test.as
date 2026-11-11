package {
    import flash.display.MovieClip;
    import flash.events.Event;

    public class Test extends MovieClip {
        private var n:int = 0;

        public function Test() {
            trace("totalFrames: " + totalFrames);
            addEventListener(Event.ENTER_FRAME, onFrame);
        }

        private function onFrame(e:Event):void {
            n++;
            if (n == 1) {
                gotoAndPlay(15995);
            } else if (n < 12) {
                trace("playing: " + currentFrame + ", isPlaying " + isPlaying);
            } else if (n == 12) {
                gotoAndPlay(16100);
            } else if (n < 16) {
                trace("playing: " + currentFrame + ", isPlaying " + isPlaying);
            } else {
                removeEventListener(Event.ENTER_FRAME, onFrame);
            }
        }
    }
}
