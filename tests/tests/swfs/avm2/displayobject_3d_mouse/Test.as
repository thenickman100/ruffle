package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    // Mouse picking through a perspective projection: a 3D-rotated "wall" containing
    // a 2D "item", and a wall rotated around the x axis. Traces what mouse clicks hit,
    // and the mouse position seen by each object.
    [SWF(width="800", height="480", frameRate="30")]
    public class Test extends Sprite {
        private var wall:Sprite, item:Sprite, wall2:Sprite;
        private function r(n:Number):String { var v:Number = Math.round(n * 100) / 100; return String(v == 0 ? 0 : v); }
        public function Test() {
            wall = new Sprite(); wall.name = "wall";
            wall.graphics.beginFill(0x888888); wall.graphics.drawRect(0, 0, 300, 200); wall.graphics.endFill();
            wall.x = 200; wall.y = 100; wall.z = 100; wall.rotationY = 40;
            addChild(wall);
            item = new Sprite(); item.name = "item";
            item.graphics.beginFill(0x0000FF); item.graphics.drawRect(0, 0, 100, 100); item.graphics.endFill();
            item.x = 150; item.y = 50;
            wall.addChild(item);
            wall2 = new Sprite(); wall2.name = "wall2";
            wall2.graphics.beginFill(0x00AA00); wall2.graphics.drawRect(0, 0, 200, 150); wall2.graphics.endFill();
            wall2.x = 450; wall2.y = 250; wall2.rotationX = 60; wall2.z = 50;
            addChild(wall2);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }
        private function onDown(e:MouseEvent):void {
            trace("down stage=(" + r(e.stageX) + "," + r(e.stageY) + ") target=" + e.target.name +
                " wall.mouse=(" + r(wall.mouseX) + "," + r(wall.mouseY) + ") item.mouse=(" + r(item.mouseX) + "," + r(item.mouseY) + ")" +
                " wall2.mouse=(" + r(wall2.mouseX) + "," + r(wall2.mouseY) + ")" +
                " hitItem=" + item.hitTestPoint(e.stageX, e.stageY, true) + " hitWall=" + wall.hitTestPoint(e.stageX, e.stageY, true));
        }
    }
}
