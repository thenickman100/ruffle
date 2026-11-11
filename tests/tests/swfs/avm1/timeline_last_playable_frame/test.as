if (!_global.started) {
    _global.started = true;
    var n = 0;
    trace("_totalframes: " + _totalframes);
    this.onEnterFrame = function() {
        n++;
        if (n == 1) {
            gotoAndPlay(15995);
        } else if (n < 12) {
            trace("playing: " + _currentframe);
        } else if (n == 12) {
            gotoAndPlay(16050);
            trace("after gotoAndPlay(16050): " + _currentframe);
        } else if (n < 16) {
            trace("playing: " + _currentframe);
        } else if (n == 16) {
            gotoAndStop(16099);
            trace("after gotoAndStop(16099): " + _currentframe);
            nextFrame();
            trace("after nextFrame: " + _currentframe);
            gotoAndStop(16000);
            nextFrame();
            trace("16000, then nextFrame: " + _currentframe);
            nextFrame();
            trace("then nextFrame: " + _currentframe);
            gotoAndStop(16100);
            trace("after gotoAndStop(16100): " + _currentframe);
            play();
        } else if (n < 20) {
            trace("playing: " + _currentframe);
        }
    };
}
