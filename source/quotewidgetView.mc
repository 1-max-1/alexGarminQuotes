using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Application.Storage;

class quotewidgetView extends WatchUi.View {
	private var quoteOfTheDay;

	function initialize() {
		View.initialize();
	}

	// Load your resources here
	function onLayout(dc as Dc) as Void {
		setLayout(Rez.Layouts.MainLayout(dc));
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() as Void {
		loadQuoteOfTheDay();
	}

	// Update the view
	function onUpdate(dc as Dc) as Void {
		var view = View.findDrawableById("QuoteLabel") as Text;
		view.setText(self.quoteOfTheDay == null ? "No quotes loaded yet" : self.quoteOfTheDay["quote"]);

		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() as Void {
	}

	public function loadQuoteOfTheDay() {
		self.quoteOfTheDay = Storage.getValue("quoteOfTheDay");
	}
}