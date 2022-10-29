using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Background;
using Toybox.Time;

(:background, :glance)
class quotewidgetApp extends Application.AppBase {
	function initialize() {
		AppBase.initialize();
		Background.registerForTemporalEvent(new Time.Duration(24 * 60 * 60));
	}

	// onStart() is called on application start up
	function onStart(state as Dictionary?) as Void {
	}

	// onStop() is called when your application is exiting
	function onStop(state as Dictionary?) as Void {
	}

	// Return the initial view of your application here
	function getInitialView() as Array<Views or InputDelegates>? {
		var v = new quotewidgetView();
		var inputDelegate = new quoteInputDelegate(method(:onQuoteSyncComplete));
		return [ v, inputDelegate ] as Array<Views or InputDelegates>;
	}

	public function getServiceDelegate() {
		return [ new quoteUpdateService(method(:onQuoteSyncComplete)) ];
	}

	public function onStorageChanged() {
		WatchUi.requestUpdate();
	}

	public function onQuoteSyncComplete() {
		WatchUi.requestUpdate();
	}

	function getGlanceView() {
		return [ new quoteWidgetGlanceView() ];
	}
}

function getApp() as quotewidgetApp {
	return Application.getApp() as quotewidgetApp;
}