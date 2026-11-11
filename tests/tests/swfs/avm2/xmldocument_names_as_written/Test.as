package {
    import flash.display.Sprite;
    import flash.xml.XMLDocument;
    import flash.xml.XMLNode;

    // XMLDocument keeps element and attribute names as written, even when the
    // same namespace URI has more than one prefix.
    public class Test extends Sprite {
        public function Test() {
            show('<svg xmlns:svg="u" xmlns="u"><g a="1"><rect/></g></svg>');
            show('<svg xmlns="u" xmlns:svg="u"><svg:g><rect/></svg:g></svg>');
            show('<a:root xmlns:a="u" xmlns:b="u"><b:child/><a:child/><child/></a:root>');
            show('<r xmlns:p="u" xmlns:q="u" p:x="1" q:y="2" z="3"/>');
            show('<plain><child k="v"/></plain>');
        }

        private function show(text:String):void {
            var doc:XMLDocument = new XMLDocument();
            doc.parseXML(text);
            trace("// " + text);
            for (var n:XMLNode = doc.firstChild; n != null; n = n.nextSibling) {
                print(n, "");
            }
        }

        private function print(node:XMLNode, indent:String):void {
            var names:Array = [];
            for (var key:String in node.attributes) {
                names.push(key);
            }
            names.sort();
            trace(indent + node.nodeName + " [" + names.join(", ") + "]");
            for (var child:XMLNode = node.firstChild; child != null; child = child.nextSibling) {
                print(child, indent + "  ");
            }
        }
    }
}
