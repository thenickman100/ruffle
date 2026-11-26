// A (depth 10) and B (depth 20) share the name "dup". Like Flash, swapDepths on B
// moves the clip found by the name: the one with the lowest depth (A).
function setup() {
    var a = this.createEmptyMovieClip("dup", 10);
    a.tag = "A";
    var b = this.createEmptyMovieClip("dup", 20);
    b.tag = "B";
    return [a, b];
}
function show(label, a, b) {
    trace(label + ": A depth " + a.getDepth() + ", B depth " + b.getDepth());
}
function clear() {
    for (var d = 0; d < 100; d++) {
        var o = this.getInstanceAtDepth(d);
        if (o != undefined) o.removeMovieClip();
    }
}
var r = setup();
r[1].swapDepths(30);
show("B.swapDepths(30)", r[0], r[1]);
r[1].swapDepths(5);
show("then B.swapDepths(5)", r[0], r[1]);
r[0].swapDepths(40);
show("then A.swapDepths(40)", r[0], r[1]);
clear();
r = setup();
var c = this.createEmptyMovieClip("other", 15);
r[1].swapDepths(c);
show("B.swapDepths(other clip at 15)", r[0], r[1]);
trace("other depth " + c.getDepth());
clear();
r = setup();
r[0].swapDepths(30);
show("A.swapDepths(30)", r[0], r[1]);
