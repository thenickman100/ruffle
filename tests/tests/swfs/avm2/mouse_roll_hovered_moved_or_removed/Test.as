package {
    import flash.display.*;
    import flash.events.*;
    [SWF(width="400", height="300", backgroundColor="#ffffff", frameRate="24")]
    public class Test extends Sprite {
        public function Test() {
            // 1: an item that shows a highlight child while hovered. Moving onto the
            // highlight fires mouseOut on the item, which removes the highlight.
            var menu1:Sprite = add(this, "menu1", 0, 0);
            var item1:Sprite = add(menu1, "item1", 20, 20, 100, 40);
            var hl1:Sprite = add(null, "hl1", 20, 20, 100, 40);
            var shown1:Boolean = false;
            item1.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                if (!shown1) { shown1 = true; item1.addChild(hl1); }
            });
            item1.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                if (hl1.parent) { trace("removing hl1"); item1.removeChild(hl1); trace("removed hl1"); }
            });

            // 2: a hovered object that removes itself.
            var panel2:Sprite = add(this, "panel2", 0, 0);
            var a2:Sprite = add(panel2, "a2", 150, 20, 60, 40);
            add(panel2, "b2", 210, 20, 60, 40);
            a2.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                if (a2.parent) { trace("removing a2"); panel2.removeChild(a2); trace("removed a2"); }
            });

            // 3: an ancestor of the hovered object is removed.
            var panel3:Sprite = add(this, "panel3", 0, 0);
            var inner3:Sprite = add(panel3, "inner3", 0, 0);
            var c3:Sprite = add(inner3, "c3", 20, 120, 60, 40);
            add(panel3, "d3", 80, 120, 60, 40);
            c3.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                if (inner3.parent) { trace("removing inner3"); panel3.removeChild(inner3); trace("removed inner3"); }
            });

            // 4: a hovered object is moved to another parent, still under the mouse.
            var panel4:Sprite = add(this, "panel4", 0, 0);
            var other4:Sprite = add(this, "other4", 0, 0);
            var e4:Sprite = add(panel4, "e4", 20, 220, 60, 40);
            e4.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                if (e4.parent == panel4) { trace("moving e4"); other4.addChild(e4); trace("moved e4"); }
            });

            // 5: a hovered object removed later, from an enterFrame handler.
            var panel5:Sprite = add(this, "panel5", 0, 0);
            var f5:Sprite = add(panel5, "f5", 150, 220, 60, 40);
            var frames5:int = -1;
            f5.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                if (frames5 < 0) frames5 = 0;
            });
            addEventListener(Event.ENTER_FRAME, function(e:Event):void {
                if (frames5 >= 0 && ++frames5 == 3 && f5.parent) {
                    trace("removing f5");
                    panel5.removeChild(f5);
                    trace("removed f5");
                }
            });
        }

        private function add(parent:Sprite, name:String, x:Number, y:Number, w:Number = 0, h:Number = 0):Sprite {
            var s:Sprite = new Sprite();
            s.name = name;
            if (w > 0) {
                s.graphics.beginFill(0x3366ff);
                s.graphics.drawRect(x, y, w, h);
            }
            for each (var type:String in [MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT, MouseEvent.ROLL_OVER, MouseEvent.ROLL_OUT]) {
                s.addEventListener(type, log);
            }
            if (parent) parent.addChild(s);
            return s;
        }

        private function log(e:MouseEvent):void {
            if (e.eventPhase != EventPhase.AT_TARGET) return;
            var r:DisplayObject = e.relatedObject;
            trace(e.type + " " + DisplayObject(e.target).name + " related=" + (r == null ? "null" : r is Stage ? "stage" : r.name + (r.stage ? "" : "(off stage)")));
        }
    }
}
