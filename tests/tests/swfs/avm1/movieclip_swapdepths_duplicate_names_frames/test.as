// Like Clear Vision 4: two clips named "fade" swap themselves to depths 10000
// and 10001 every frame. Frames 2-6 of test.swf are added by a script (see
// test.toml): A = "fade" (3 frames, swapDepths(10000)), B = "fade" (1 frame,
// placed twice on the way to the "success" label, the second time with
// swapDepths(10001)).
var n = 0;
stop();
onEnterFrame = function() {
    n++;
    var s = "tick " + n + ", frame " + _currentframe + ":";
    for (var d = 9999; d <= 10002; d++) {
        var o = getInstanceAtDepth(d);
        if (o != undefined) s += " " + d + "=" + (o._totalframes == 3 ? "A" : "B");
    }
    var o2 = getInstanceAtDepth(239);
    if (o2 != undefined) s += " 239=" + (o2._totalframes == 3 ? "A" : "B");
    trace(s);
    if (n == 3) gotoAndPlay(2);
    if (n == 6) gotoAndPlay("success");
    if (n == 12) delete onEnterFrame;
};
