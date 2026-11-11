package {
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Vector3D;

    [SWF(width="550", height="400")]
    public class Test extends Sprite {
        public function Test() {
            var flat:Sprite = new Sprite();
            flat.x = 100;
            flat.y = 50;
            addChild(flat);
            check("2D object", flat);

            var zero:Sprite = new Sprite();
            zero.x = 100;
            zero.y = 50;
            zero.z = 0;
            addChild(zero);
            check("3D object, z = 0", zero);

            var deep:Sprite = new Sprite();
            deep.x = 100;
            deep.y = 50;
            deep.z = 200;
            deep.rotationX = -90;
            addChild(deep);
            check("3D object, z = 200, rotationX = -90", deep);

            var scaled:Sprite = new Sprite();
            scaled.x = 50;
            scaled.y = 50;
            scaled.scaleX = 2;
            scaled.scaleY = 2;
            addChild(scaled);
            var inner:Sprite = new Sprite();
            inner.x = 10;
            inner.y = 10;
            scaled.addChild(inner);
            check("2D object in a scaled parent", inner);

            var turned:Sprite = new Sprite();
            turned.x = 200;
            turned.y = 100;
            turned.rotationY = 30;
            addChild(turned);
            var child:Sprite = new Sprite();
            child.x = 10;
            child.y = 10;
            turned.addChild(child);
            check("2D object in a parent with rotationY = 30", child);

            var offstage:Sprite = new Sprite();
            offstage.x = 100;
            offstage.y = 50;
            check("Object not on the stage", offstage);

            var offstage3d:Sprite = new Sprite();
            offstage3d.x = 100;
            offstage3d.y = 50;
            offstage3d.z = 100;
            check("3D object not on the stage", offstage3d);

            root.transform.perspectiveProjection.fieldOfView = 70;
            root.transform.perspectiveProjection.projectionCenter = new Point(275, 200);
            check("2D object, root projection changed", flat);
        }

        private function check(name:String, obj:Sprite):void {
            trace("// " + name);
            var points:Array = [[0, 0, 0], [10, 20, 0], [10, 20, 300], [10, 20, -200],
                [-50, 80, 1000], [10, 20, -800]];
            for each (var p:Array in points) {
                var global:Point = obj.local3DToGlobal(new Vector3D(p[0], p[1], p[2]));
                trace("(" + p.join(", ") + ") -> " + round(global.x) + ", " + round(global.y));
            }
            trace("");
        }

        private function round(value:Number):Number {
            return Math.round(value * 100) / 100;
        }
    }
}
