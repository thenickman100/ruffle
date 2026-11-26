package {
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;

    // Tests the 3D properties of display objects (rotationX/Y/Z, z, scaleZ),
    // `transform.matrix3D`, and how a 2D matrix is decomposed when an object
    // first gets a 3D transform.
    [SWF(width="800", height="480")]
    public class Test extends Sprite {
        private function r(n:Number):String {
            var v:Number = Math.round(n * 1000) / 1000;
            return String(v == 0 ? 0 : v);
        }

        private function raw(m:Matrix3D):String {
            if (m == null) return "null";
            var a:Array = [];
            var v:Vector.<Number> = m.rawData;
            for (var i:int = 0; i < 16; i++) a.push(r(v[i]));
            return a.join(",");
        }

        private function mat(m:Matrix):String {
            if (m == null) return "null";
            return [r(m.a), r(m.b), r(m.c), r(m.d), r(m.tx), r(m.ty)].join(",");
        }

        private function box():Shape {
            var s:Shape = new Shape();
            s.graphics.beginFill(0xFF0000);
            s.graphics.drawRect(0, 0, 100, 100);
            s.graphics.endFill();
            addChild(s);
            return s;
        }

        private function dump(name:String, o:DisplayObject, gx:Number = 150, gy:Number = 100):void {
            trace("== " + name);
            trace("  x=" + r(o.x) + " y=" + r(o.y) + " z=" + r(o.z) + " rx=" + r(o.rotationX) + " ry=" + r(o.rotationY) +
                " rz=" + r(o.rotationZ) + " rot=" + r(o.rotation) + " sx=" + r(o.scaleX) + " sy=" + r(o.scaleY) + " sz=" + r(o.scaleZ));
            trace("  matrix " + mat(o.transform.matrix));
            trace("  matrix3D " + raw(o.transform.matrix3D));
            var g:Point = o.globalToLocal(new Point(gx, gy));
            trace("  globalToLocal(" + gx + "," + gy + ") " + r(g.x) + "," + r(g.y));
        }

        public function Test() {
            var s:Shape;
            s = box(); s.x = 100; s.y = 50; dump("2D", s);
            s = box(); s.x = 100; s.y = 50; s.z = 0; dump("z=0", s);
            s = box(); s.x = 100; s.y = 50; s.z = 200; dump("z=200", s);
            s = box(); s.x = 100; s.y = 50; s.rotationX = 30; dump("rotationX=30", s);
            s = box(); s.x = 100; s.y = 50; s.rotationY = 40; dump("rotationY=40", s);
            s = box(); s.x = 100; s.y = 50; s.rotationZ = 20; dump("rotationZ=20", s);
            s = box(); s.x = 100; s.y = 50; s.rotationX = 30; s.rotationY = 40; s.rotationZ = 20; dump("rotationX/Y/Z", s);
            s = box(); s.x = 100; s.y = 50; s.scaleX = 2; s.scaleY = 3; s.scaleZ = 4;
            s.rotationX = 30; s.rotationY = 40; s.rotationZ = 20; s.z = 50; dump("scaled", s);
            s = box(); s.x = 100; s.y = 50; s.rotationX = 90; s.z = 236; dump("edge-on", s);
            s = box(); s.x = 100; s.y = 50; s.rotationY = 166; s.z = 236; dump("rotationY=166", s);
            s = box(); s.x = 100; s.y = 50; s.rotationX = 20; s.x = 120; s.y = 60; dump("moved after rotationX", s);
            s = box(); s.x = 100; s.y = 50; s.rotationX = 20; s.transform.matrix = new Matrix(1, 0, 0, 1, 10, 20); dump("matrix set after rotationX", s);
            s = box(); s.x = 100; s.y = 50; s.rotationX = 20; s.transform.matrix3D = null; dump("matrix3D=null", s);
            var m3:Matrix3D = new Matrix3D();
            m3.appendRotation(25, Vector3D.Y_AXIS);
            m3.appendTranslation(150, 60, 30);
            s = box(); s.transform.matrix3D = m3; dump("matrix3D set", s);

            // Decomposition of 2D matrices (flips, rotations, skews) into 3D properties.
            var c:Number = Math.cos(Math.PI / 6), sn:Number = Math.sin(Math.PI / 6);
            var mats:Array = [
                ["flipX", new Matrix(-1, 0, 0, 1, 10, 20)],
                ["flipY", new Matrix(1, 0, 0, -1, 10, 20)],
                ["flipXY", new Matrix(-1, 0, 0, -1, 10, 20)],
                ["rotation30", new Matrix(c, sn, -sn, c, 10, 20)],
                ["rotation30 flipX", new Matrix(-c, -sn, -sn, c, 10, 20)],
                ["flipX scale2", new Matrix(-2, 0, 0, 0.5, 10, 20)],
                ["skewX", new Matrix(1, 0, 0.5, 1, 10, 20)],
                ["skewY", new Matrix(1, 0.5, 0, 1, 10, 20)]
            ];
            for each (var e:Array in mats) {
                for each (var setter:Array in [["rotationY", 100], ["rotationX", 30], ["z", 0]]) {
                    s = box();
                    s.transform.matrix = e[1];
                    s[setter[0]] = setter[1];
                    dump(e[0] + " then " + setter[0] + "=" + setter[1], s);
                }
            }
            s = box(); s.scaleX = -1; s.rotationY = 100; dump("scaleX=-1 then rotationY=100", s);
            s = box(); s.rotation = 170; s.scaleY = -2; s.rotationX = 10; dump("rotation=170 scaleY=-2 then rotationX=10", s);

            trace("== getters keep the set value");
            s = box();
            for each (var v:Number in [0, 166, 181, 270, 370, -190, 720.5]) {
                s.rotationX = v; s.rotationY = v; s.rotationZ = v;
                trace("  " + v + " -> " + r(s.rotationX) + " " + r(s.rotationY) + " " + r(s.rotationZ) + " " + r(s.rotation));
            }

            trace("== nested");
            var p:Sprite = new Sprite(); addChild(p); p.x = 300; p.y = 100; p.rotationY = 30;
            s = new Shape(); p.addChild(s); s.x = 20; s.y = 10; s.rotationX = 40; dump("3D in 3D", s);
            var q:Sprite = new Sprite(); addChild(q); q.x = 300; q.y = 100; q.scaleX = 2; q.scaleY = 2;
            s = new Shape(); q.addChild(s); s.x = 20; s.y = 10; s.rotationY = 40; dump("3D in scaled 2D", s);
            var q2:Sprite = new Sprite(); addChild(q2); q2.x = 300; q2.y = 100; q2.rotationY = 30;
            var c2:Sprite = new Sprite(); q2.addChild(c2); c2.x = 47; c2.scaleX = 0.5; c2.rotation = 15;
            s = new Shape(); c2.addChild(s); s.x = 10; dump("2D in 2D in 3D", s, 350, 120);
        }
    }
}
