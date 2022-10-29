import Toybox.WatchUi;

// Handles user input
class quoteInputDelegate extends WatchUi.InputDelegate {
	private var backendHandler;
	private var callbackFunc;

	public function initialize(cb) {
		InputDelegate.initialize();
		backendHandler = new backendInteractionLogic();
		callbackFunc = cb;
	}

	function onKey(keyEvent) {
		// Top right button
		if (keyEvent.getKey() == 4) {
			backendHandler.initiateSync(false, callbackFunc);
			return true;
		}
		else {
			return false;
		}
	}
}