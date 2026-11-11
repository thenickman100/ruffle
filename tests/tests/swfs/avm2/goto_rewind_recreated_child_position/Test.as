package {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;

    // test.swf has these symbols (shapes are told apart by their width):
    //   Slot1: frame 1 places shape A (10 px) at depth 1; frame 2 replaces it with B (20 px)
    //   Slot2: frame 1 places A at depth 1 and C (30 px) at depth 3; frame 2 replaces C with B
    //   Slot3: frame 1 is empty; frame 2 places C at depth 5
    //   Slot4: frame 1 places C at depth 5; frame 2 places A at depth 1
    // When a backward goto recreates a shape, the new shape takes the place of
    // the old one, even when a child added with addChild is above it.
    public class Test extends Sprite {
        public function Test() {
            // Backward jumps that recreate a timeline shape.
            run("Slot1, child added on top, 2 then 1", new Slot1(), -1, [2, 1]);
            run("Slot1, child added at index 0, 2 then 1", new Slot1(), 0, [2, 1]);
            run("Slot2, child added on top, 2 then 1", new Slot2(), -1, [2, 1]);
            run("Slot2, child added at index 1, 2 then 1", new Slot2(), 1, [2, 1]);
            // Forward jumps that place a new timeline shape.
            run("Slot3, child added on top, 2", new Slot3(), -1, [2]);
            run("Slot4, child added on top, 2", new Slot4(), -1, [2]);
            run("Slot4, child added at index 0, 2", new Slot4(), 0, [2]);
        }

        private function run(name:String, clip:MovieClip, index:int, frames:Array):void {
            var child:Sprite = new Sprite();
            child.name = "child";
            if (index < 0) {
                clip.addChild(child);
            } else {
                clip.addChildAt(child, index);
            }
            var line:String = name + ": " + describe(clip);
            for each (var frame:int in frames) {
                clip.gotoAndStop(frame);
                line += " -> " + describe(clip);
            }
            trace(line);
        }

        private function describe(clip:MovieClip):String {
            var names:Array = [];
            for (var i:int = 0; i < clip.numChildren; i++) {
                var c:DisplayObject = clip.getChildAt(i);
                names.push(c is Shape ? String(c.width) : c.name);
            }
            return "[" + names.join(" ") + "]";
        }
    }
}
