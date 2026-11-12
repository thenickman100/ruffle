package {
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;

    // Clicks each object in turn and traces where the focus goes.
    // Flash does not focus clicked objects inside a container with
    // tabChildren set to false, except text fields.
    [SWF(width="640", height="480", frameRate="30")]
    public class Test extends Sprite {
        private var pending:String = null;

        public function Test() {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function box(c:uint):Shape {
            var s:Shape = new Shape();
            s.graphics.beginFill(c); s.graphics.drawRect(0, 0, 40, 40);
            return s;
        }

        private function button():SimpleButton {
            return new SimpleButton(box(0x00AA00), box(0x00CC00), box(0x008800), box(0));
        }

        private function sprite():Sprite {
            var s:Sprite = new Sprite(); s.addChild(box(0x0000AA)); return s;
        }

        private function place(i:int, o:DisplayObject, name:String, parent:DisplayObjectContainer = null):void {
            o.name = name;
            var p:DisplayObjectContainer = parent;
            if (p == null) { p = new Sprite(); p.name = name + "_box"; addChild(p); }
            p.x = 20 + (i % 8) * 70; p.y = 100 + int(i / 8) * 70;
            p.addChild(o);
        }

        private function init(e:Event):void {
            place(0, button(), "btn");
            var noTab:Sprite = new Sprite(); noTab.tabChildren = false; noTab.name = "noTab"; addChild(noTab);
            place(1, button(), "btnNoTabParent", noTab);
            var rm:SimpleButton = button();
            place(2, rm, "btnRemovedOnDown");
            rm.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { rm.parent.parent.removeChild(rm.parent); });
            place(3, sprite(), "sprite");
            var bm:Sprite = sprite(); bm.buttonMode = true; place(4, bm, "spriteButtonMode");
            var te:Sprite = sprite(); te.tabEnabled = true; place(5, te, "spriteTabEnabled");
            var tf:TextField = new TextField(); tf.type = TextFieldType.INPUT; tf.border = true; tf.width = 40; tf.height = 40;
            var noTab2:Sprite = new Sprite(); noTab2.tabChildren = false; noTab2.name = "noTab2"; addChild(noTab2);
            place(6, tf, "inputNoTabParent", noTab2);
            var bt:SimpleButton = button(); bt.tabEnabled = false; place(7, bt, "btnTabDisabled");
            var sf:SimpleButton = button(); place(8, sf, "btnSetsFocusOnDown");
            sf.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { stage.focus = te; });
            var rmc:SimpleButton = button(); place(9, rmc, "btnRemovedOnClick");
            rmc.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { rmc.parent.parent.removeChild(rmc.parent); });
            var nt:Sprite = new Sprite(); nt.tabChildren = false; nt.name = "noTab3"; addChild(nt);
            var te2:Sprite = sprite(); te2.tabEnabled = true; place(10, te2, "spriteTabEnabledNoTabParent", nt);
            var outer:Sprite = new Sprite(); outer.tabChildren = false; outer.name = "noTabOuter"; addChild(outer);
            var inner:Sprite = new Sprite(); inner.name = "inner"; outer.addChild(inner);
            place(11, button(), "btnNoTabGrandparent", inner);

            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                trace("mouseDown capture on " + nameOf(e.target) + ", focus " + nameOf(stage.focus));
            }, true);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                trace("mouseDown bubble at stage, focus " + nameOf(stage.focus));
            });
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                trace("mouseUp, focus " + nameOf(stage.focus));
                pending = nameOf(e.target);
            });
            stage.addEventListener(FocusEvent.FOCUS_IN, function(e:FocusEvent):void {
                trace("focusIn " + nameOf(e.target) + " related " + nameOf(e.relatedObject));
            }, true);
            stage.addEventListener(FocusEvent.FOCUS_OUT, function(e:FocusEvent):void {
                trace("focusOut " + nameOf(e.target) + " related " + nameOf(e.relatedObject));
            }, true);
            addEventListener(Event.ENTER_FRAME, function(e:Event):void {
                if (pending == null) return;
                trace("next frame: focus " + nameOf(stage.focus));
                stage.focus = null;
                trace("---");
                pending = null;
            });
        }

        private function nameOf(o:Object):String {
            if (o == null) return "null";
            if (o == stage) return "stage";
            return o.name + (o is DisplayObject && o.stage == null ? " (off stage)" : "");
        }
    }
}
