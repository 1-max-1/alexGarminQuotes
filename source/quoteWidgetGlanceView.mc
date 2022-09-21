using Toybox.Graphics;
using Toybox.WatchUi;

(:glance)
class quoteWidgetGlanceView extends WatchUi.GlanceView {
	function initialize() {
		GlanceView.initialize();
	}

	function onLayout(dc as Dc) {
		setLayout(Rez.Layouts.GlanceViewLayout(dc));
	}
}