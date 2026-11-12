package {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.utils.Dictionary;

    // test.swf has timeline symbols added by make_timelines.py (see it for their frames).
    // Shapes are told apart by width: A, B, C, D are 10, 20, 30 and 40 px wide, and
    // "#n" tells instances apart. AS3 children (y, z, x) are added at the given
    // indices (-1: on top) on frame 1, then the clip goes to the given frames.
    public class Test extends Sprite {
        private var ids:Dictionary = new Dictionary();
        private var nextId:int = 1;

        public function Test() {
            run("Replace1 y top", new Replace1(), [[-1, "y"]], [2, 1]);
            run("Replace1 y@0", new Replace1(), [[0, "y"]], [2, 1]);
            run("Replace3 y top", new Replace3(), [[-1, "y"]], [2, 1]);
            run("Replace3 y@1", new Replace3(), [[1, "y"]], [2, 1]);
            run("Replace1And3 y@1", new Replace1And3(), [[1, "y"]], [2, 1]);
            run("Replace1And3 y@2", new Replace1And3(), [[2, "y"]], [2, 1]);
            run("Replace1And3 y@0", new Replace1And3(), [[0, "y"]], [2, 1]);
            run("ReplaceMiddle y@2", new ReplaceMiddle(), [[2, "y"]], [2, 1]);
            run("ReplaceMiddle y@1", new ReplaceMiddle(), [[1, "y"]], [2, 1]);
            run("ReplaceMiddle x@1 y@3", new ReplaceMiddle(), [[1, "x"], [3, "y"]], [2, 1]);
            run("ReplaceFirstOf3 y@0", new ReplaceFirstOf3(), [[0, "y"]], [2, 1]);
            run("ReplaceFirstOf3 y@1", new ReplaceFirstOf3(), [[1, "y"]], [2, 1]);
            run("ReplaceFirstOf3 y@2", new ReplaceFirstOf3(), [[2, "y"]], [2, 1]);
            run("ReplaceFirstOf3 y@3", new ReplaceFirstOf3(), [[3, "y"]], [2, 1]);
            run("ReplaceFirstOf3 y@1 z@3", new ReplaceFirstOf3(), [[1, "y"], [3, "z"]], [2, 1]);
            run("ReplaceFirstOf3 y@0 z@2", new ReplaceFirstOf3(), [[0, "y"], [2, "z"]], [2, 1]);
            run("ReplaceSecondOf3 y@0", new ReplaceSecondOf3(), [[0, "y"]], [2, 1]);
            run("ReplaceSecondOf3 y@1", new ReplaceSecondOf3(), [[1, "y"]], [2, 1]);
            run("ReplaceSecondOf3 y@2", new ReplaceSecondOf3(), [[2, "y"]], [2, 1]);
            run("ReplaceSecondOf3 y@3", new ReplaceSecondOf3(), [[3, "y"]], [2, 1]);
            run("ReplaceSecondOf3 y@1 z@3", new ReplaceSecondOf3(), [[1, "y"], [3, "z"]], [2, 1]);
            run("ReplaceSecondOf3 y@0 z@2", new ReplaceSecondOf3(), [[0, "y"], [2, "z"]], [2, 1]);
            run("ReplaceLastOf3 y@0", new ReplaceLastOf3(), [[0, "y"]], [2, 1]);
            run("ReplaceLastOf3 y@1", new ReplaceLastOf3(), [[1, "y"]], [2, 1]);
            run("ReplaceLastOf3 y@2", new ReplaceLastOf3(), [[2, "y"]], [2, 1]);
            run("ReplaceLastOf3 y@3", new ReplaceLastOf3(), [[3, "y"]], [2, 1]);
            run("ReplaceLastOf3 y@1 z@3", new ReplaceLastOf3(), [[1, "y"], [3, "z"]], [2, 1]);
            run("ReplaceLastOf3 y@0 z@2", new ReplaceLastOf3(), [[0, "y"], [2, "z"]], [2, 1]);
            run("ReplaceFirstAndLast y@0", new ReplaceFirstAndLast(), [[0, "y"]], [2, 1]);
            run("ReplaceFirstAndLast y@1", new ReplaceFirstAndLast(), [[1, "y"]], [2, 1]);
            run("ReplaceFirstAndLast y@2", new ReplaceFirstAndLast(), [[2, "y"]], [2, 1]);
            run("ReplaceFirstAndLast y@3", new ReplaceFirstAndLast(), [[3, "y"]], [2, 1]);
            run("ReplaceFirstAndLast y@1 z@3", new ReplaceFirstAndLast(), [[1, "y"], [3, "z"]], [2, 1]);
            run("ReplaceFirstAndLast y@0 z@2", new ReplaceFirstAndLast(), [[0, "y"], [2, "z"]], [2, 1]);
            run("ReplaceFirstOf4 y@0", new ReplaceFirstOf4(), [[0, "y"]], [2, 1]);
            run("ReplaceFirstOf4 y@1", new ReplaceFirstOf4(), [[1, "y"]], [2, 1]);
            run("ReplaceFirstOf4 y@2", new ReplaceFirstOf4(), [[2, "y"]], [2, 1]);
            run("ReplaceFirstOf4 y@3", new ReplaceFirstOf4(), [[3, "y"]], [2, 1]);
            run("ReplaceFirstOf4 y@1 z@3", new ReplaceFirstOf4(), [[1, "y"], [3, "z"]], [2, 1]);
            run("ReplaceFirstOf4 y@0 z@2", new ReplaceFirstOf4(), [[0, "y"], [2, "z"]], [2, 1]);
            run("TagsOutOfOrder y@0", new TagsOutOfOrder(), [[0, "y"]], [2, 1]);
            run("TagsOutOfOrder y@1", new TagsOutOfOrder(), [[1, "y"]], [2, 1]);
            run("TagsOutOfOrder y@2", new TagsOutOfOrder(), [[2, "y"]], [2, 1]);
            run("TagsOutOfOrder y@3", new TagsOutOfOrder(), [[3, "y"]], [2, 1]);
            run("TagsOutOfOrder y@1 z@3", new TagsOutOfOrder(), [[1, "y"], [3, "z"]], [2, 1]);
            run("TagsOutOfOrder y@0 z@2", new TagsOutOfOrder(), [[0, "y"], [2, "z"]], [2, 1]);
            run("TagsOutOfOrder2 y@0", new TagsOutOfOrder2(), [[0, "y"]], [2, 1]);
            run("TagsOutOfOrder2 y@1", new TagsOutOfOrder2(), [[1, "y"]], [2, 1]);
            run("TagsOutOfOrder2 y@2", new TagsOutOfOrder2(), [[2, "y"]], [2, 1]);
            run("TagsOutOfOrder2 y@3", new TagsOutOfOrder2(), [[3, "y"]], [2, 1]);
            run("TagsOutOfOrder2 y@1 z@3", new TagsOutOfOrder2(), [[1, "y"], [3, "z"]], [2, 1]);
            run("TagsOutOfOrder2 y@0 z@2", new TagsOutOfOrder2(), [[0, "y"], [2, "z"]], [2, 1]);
            run("Unchanged y@0", new Unchanged(), [[0, "y"]], [2, 1]);
            run("Unchanged y@1", new Unchanged(), [[1, "y"]], [2, 1]);
            run("Unchanged y@2", new Unchanged(), [[2, "y"]], [2, 1]);
            run("Unchanged y@3", new Unchanged(), [[3, "y"]], [2, 1]);
            run("Unchanged y@1 z@3", new Unchanged(), [[1, "y"], [3, "z"]], [2, 1]);
            run("Unchanged y@0 z@2", new Unchanged(), [[0, "y"], [2, "z"]], [2, 1]);
            run("Removed3 y@0", new Removed3(), [[0, "y"]], [2, 1]);
            run("Removed3 y@1", new Removed3(), [[1, "y"]], [2, 1]);
            run("Removed3 y@2", new Removed3(), [[2, "y"]], [2, 1]);
            run("Removed3 y@3", new Removed3(), [[3, "y"]], [2, 1]);
            run("Removed3 y@1 z@3", new Removed3(), [[1, "y"], [3, "z"]], [2, 1]);
            run("Removed3 y@0 z@2", new Removed3(), [[0, "y"], [2, "z"]], [2, 1]);
            run("Replace1Removed3 y@0", new Replace1Removed3(), [[0, "y"]], [2, 1]);
            run("Replace1Removed3 y@1", new Replace1Removed3(), [[1, "y"]], [2, 1]);
            run("Replace1Removed3 y@2", new Replace1Removed3(), [[2, "y"]], [2, 1]);
            run("Replace1Removed3 y@3", new Replace1Removed3(), [[3, "y"]], [2, 1]);
            run("Replace1Removed3 y@1 z@3", new Replace1Removed3(), [[1, "y"], [3, "z"]], [2, 1]);
            run("Replace1Removed3 y@0 z@2", new Replace1Removed3(), [[0, "y"], [2, "z"]], [2, 1]);
            run("Added4 y@0", new Added4(), [[0, "y"]], [2, 1]);
            run("Added4 y@1", new Added4(), [[1, "y"]], [2, 1]);
            run("Added4 y@2", new Added4(), [[2, "y"]], [2, 1]);
            run("Added4 y@3", new Added4(), [[3, "y"]], [2, 1]);
            run("Added4 y@1 z@3", new Added4(), [[1, "y"], [3, "z"]], [2, 1]);
            run("Added4 y@0 z@2", new Added4(), [[0, "y"], [2, "z"]], [2, 1]);
            run("ReplaceTwice y@1 z top", new ReplaceTwice(), [[1, "y"], [-1, "z"]], [3, 1]);
            run("ReplaceTwice y@1", new ReplaceTwice(), [[1, "y"]], [3, 1]);
            run("ReplaceTwice y@1", new ReplaceTwice(), [[1, "y"]], [3, 2]);
            run("Replace1Added5 y@0", new Replace1Added5(), [[0, "y"]], [2, 1]);
            run("Replace1Added5 y@1", new Replace1Added5(), [[1, "y"]], [2, 1]);
            run("Replace1Added5 y@2", new Replace1Added5(), [[2, "y"]], [2, 1]);
            // Added3: an AS3 child is added after the object placed on frame 2.
            var added3:MovieClip = new Added3();
            added3.gotoAndStop(2);
            run("Added3 y@2 (on frame 2)", added3, [[2, "y"]], [1]);
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
