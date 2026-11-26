package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;

    // Renders display objects with 3D transforms through Flash's default perspective
    // projection: shapes, gradients, bitmaps, mirrored objects, nested 3D objects,
    // 2D objects inside 3D ones, and filtered/cached objects drawn in their own plane.
    [SWF(width="800", height="480", backgroundColor="#FFFFFF")]
    public class Test extends Sprite {
        private function rect(color:uint, w:Number, h:Number):Shape {
            var s:Shape = new Shape();
            s.graphics.beginFill(color);
            s.graphics.drawRect(0, 0, w, h);
            s.graphics.endFill();
            return s;
        }

        public function Test() {
            // A gradient square seen at an angle.
            var g:Shape = new Shape();
            var gm:Matrix = new Matrix();
            gm.createGradientBox(120, 120);
            g.graphics.beginGradientFill(GradientType.LINEAR, [0xFF0000, 0x0000FF], [1, 1], [0, 255], gm);
            g.graphics.drawRect(0, 0, 120, 120);
            g.graphics.endFill();
            g.x = 30; g.y = 30; g.rotationY = 50;
            addChild(g);

            // A checkerboard bitmap tilted backwards.
            var bd:BitmapData = new BitmapData(16, 16, false, 0xFFFFFF);
            for (var i:int = 0; i < 16; i++) for (var j:int = 0; j < 16; j++) if ((i + j) % 2 == 0) bd.setPixel(i, j, 0x000000);
            var b:Bitmap = new Bitmap(bd);
            b.scaleX = b.scaleY = 8;
            b.x = 200; b.y = 40; b.rotationX = 40;
            addChild(b);

            // A mirrored shape, then rotated around the y axis.
            var m:Sprite = new Sprite();
            m.addChild(rect(0x00AA00, 100, 60));
            var dot:Shape = rect(0xFFFF00, 20, 20);
            dot.x = 10; dot.y = 10;
            m.addChild(dot);
            m.x = 560; m.y = 40; m.scaleX = -1; m.rotationY = 60;
            addChild(m);

            // A 3D wall holding a 2D child, and a 3D child (nested 3D).
            var wall:Sprite = new Sprite();
            wall.addChild(rect(0x888888, 200, 120));
            var item:Shape = rect(0x0000FF, 60, 60);
            item.x = 20; item.y = 30;
            wall.addChild(item);
            var flap:Shape = rect(0xFF8800, 60, 60);
            flap.x = 120; flap.y = 30; flap.rotationX = 50;
            wall.addChild(flap);
            wall.x = 600; wall.y = 200; wall.z = 80; wall.rotationY = -35;
            addChild(wall);

            // A blurred object drawn in its own plane.
            var blurred:Sprite = new Sprite();
            blurred.addChild(rect(0x9900CC, 100, 100));
            blurred.filters = [new BlurFilter(8, 8, 1)];
            blurred.x = 60; blurred.y = 260; blurred.rotationY = 35;
            addChild(blurred);

            // A cached 2D child inside a 3D parent.
            var holder:Sprite = new Sprite();
            var cached:Sprite = new Sprite();
            cached.addChild(rect(0x00CCCC, 100, 80));
            cached.cacheAsBitmap = true;
            holder.addChild(cached);
            holder.x = 260; holder.y = 280; holder.rotationX = -30;
            addChild(holder);

            // Moved away along the z axis only.
            var far:Shape = rect(0xCC0000, 100, 100);
            far.x = 420; far.y = 300; far.z = 300;
            addChild(far);
        }
    }
}
