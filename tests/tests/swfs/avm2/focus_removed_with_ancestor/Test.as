package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    // When a container is removed from the stage, a focused object inside it
    // loses the focus, and key events go to the stage again.
    public class Test extends Sprite {
        private var container:Sprite;
        private var child:Sprite;

        public function Test() {
            container = new Sprite();
            container.name = "container";
            child = new Sprite();
            child.name = "child";
            container.addChild(child);
            addChild(container);
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event):void {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
                trace("stage got keyDown " + e.keyCode + ", target " + e.target.name);
            });
            child.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
                trace("child got keyDown " + e.keyCode);
            });
            stage.focus = child;
            trace("focus: " + nameOf(stage.focus));
            removeChild(container);
            trace("after removing the container, focus: " + nameOf(stage.focus));
        }

        private function nameOf(o:Object):String {
            return o == null ? "null" : o.name;
        }
    }
}
