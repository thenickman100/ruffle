package {
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.geom.Matrix;

    // Walls turned nearly side-on, long enough to reach behind the viewer.
    [SWF(width="800", height="480", backgroundColor="#E8E4DE")]
    public class Test extends Sprite {
        private function wall(color:uint, len:Number):Sprite {
            var w:Sprite = new Sprite();
            var bd:BitmapData = new BitmapData(16, 16, true, 0);
            for (var y:int = 0; y < 16; y++) for (var x:int = 0; x < 16; x++) bd.setPixel32(x, y, ((x + y) % 2 ? 0xFF000000 : 0) | color);
            var m:Matrix = new Matrix(); m.scale(40, 40);
            w.graphics.beginBitmapFill(bd, m, true, true); w.graphics.drawRect(0, 0, len, 400); w.graphics.endFill();
            return w;
        }
        public function Test() {
            var room:Sprite = new Sprite(); addChild(room);
            var right:Sprite = wall(0xCC8844, 3000); right.x = 620; right.y = 40; right.rotationY = 88; room.addChild(right);
            var left:Sprite = wall(0x4488CC, 3000); left.x = 180; left.y = 40; left.rotationY = 92; left.z = 0; room.addChild(left);
            var floor:Sprite = wall(0x44AA66, 2000); floor.x = 150; floor.y = 440; floor.rotationX = -95; room.addChild(floor);
        }
    }
}
