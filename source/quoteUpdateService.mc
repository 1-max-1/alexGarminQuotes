using Toybox.System;

(:background)
class quoteUpdateService extends System.ServiceDelegate {
	function initialize() {
		System.ServiceDelegate.initialize();
	}

	public function onTemporalEvent() as Void {
		var backendHandler = new backendInteractionLogic();
		backendHandler.initiateSync(true, null);
	}
}