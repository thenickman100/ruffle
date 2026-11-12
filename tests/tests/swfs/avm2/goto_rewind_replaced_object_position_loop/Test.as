package {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.utils.Dictionary;

    // Like goto_rewind_replaced_object_position, for clips that loop by themselves.
    // test.swf has timeline symbols added by make_timelines.py (see it for their frames).
    // Shapes are told apart by width: A, B, C, D are 10, 20, 30 and 40 px wide, and
    // "#n" tells instances apart. AS3 children (y, z, x) are added at the given
    // indices (-1: on top) on frame 1, then the clip goes to the given frames.
    public class Test extends Sprite {
        private var ids:Dictionary = new Dictionary();
        private var nextId:int = 1;

        private var clips:Array = [];
        private var ticks:int = 0;

        public function Test() {
            // Clips that loop by themselves (2 frames, playing).
            add(new ReplaceFirstOf3(), [[1, "y"]]);
            add(new ReplaceFirstOf3(), [[1, "y"], [3, "z"]]);
            add(new ReplaceSecondOf3(), [[2, "y"]]);
            add(new Replace1Removed3(), [[1, "y"]]);
            add(new Replace1And3(), [[1, "y"]]);
            addEventListener("enterFrame", onFrame);
        }

        private function add(clip:MovieClip, children:Array):void {
            for each (var c:Array in children) {
                var s:Sprite = new Sprite();
                s.name = c[1];
                if (c[0] < 0) clip.addChild(s); else clip.addChildAt(s, c[0]);
            }
            addChild(clip);
            clips.push(clip);
        }

        private function onFrame(e:*):void {
            ticks++;
            // Only frame 2: on frame 1 the looped objects aren't constructed yet.
            if (MovieClip(clips[0]).currentFrame != 2) return;
            var line:String = "tick " + ticks + ":";
            for each (var c:MovieClip in clips) line += " " + c.currentFrame + describe(c);
            trace(line);
            if (ticks == 8) removeEventListener("enterFrame", onFrame);
        }

        private function run(name:String, clip:MovieClip, children:Array, frames:Array):void {
            for each (var c:Array in children) {
                var s:Sprite = new Sprite();
                s.name = c[1];
                if (c[0] < 0) clip.addChild(s); else clip.addChildAt(s, c[0]);
            }
            var line:String = name + ": " + describe(clip);
            for each (var f:int in frames) {
                clip.gotoAndStop(f);
                line += " -> " + describe(clip);
            }
            trace(line);
        }

        private function describe(clip:MovieClip):String {
            var names:Array = [];
            for (var i:int = 0; i < clip.numChildren; i++) {
                var c:DisplayObject = clip.getChildAt(i);
                if (c is Shape) {
                    if (ids[c] == undefined) ids[c] = nextId++;
                    names.push(["?", "A", "B", "C", "D"][int(c.width / 10)] + "#" + ids[c]);
                } else {
                    names.push(c.name);
                }
            }
            return "[" + names.join(" ") + "]";
        }
    }
}
