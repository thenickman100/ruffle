package {
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    // test.swf links a JPEG (DefineBitsJPEG2) to TestJpeg and TestJpegData.
    // Bitmaps from JPEGs are opaque.
    public class Test extends Sprite {
        public function Test() {
            var jpeg:BitmapData = new TestJpeg().bitmapData;
            trace("TestJpeg transparent: " + jpeg.transparent);
            trace("TestJpegData transparent: " + new TestJpegData(0, 0).transparent);

            // Like Drop Dead 2 and 3: copy a partly transparent image onto a JPEG.
            var source:BitmapData = new BitmapData(2, 1, true, 0);
            source.setPixel32(1, 0, 0xFF0000FF);
            jpeg.copyPixels(source, new Rectangle(0, 0, 2, 1), new Point(0, 0));
            trace("JPEG after copyPixels: " + jpeg.getPixel32(0, 0).toString(16) + " " + jpeg.getPixel32(1, 0).toString(16));
        }
    }
}
