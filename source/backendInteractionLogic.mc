using Toybox.Application.Storage;
using Toybox.Math;

// This class contains the code for downloading the quotes from the backend.
// When it is finished, it will call background.exit() if ruunning in the background,
// or will call a callback function if initiaited manually from a button press.

(:background)
class backendInteractionLogic {
	// Number of quotes per response page
	private var PAGE_SIZE = 15;
	private var BACKEND_HOST = "https://backends.onrender.com";

	// Will be set to the page number of the last page of quotes, once the page count has been received
	// This will be equal to   pageCount - 1
	private var lastPage = -1;

	private var syncStartedFromBackground = false;
	// Callback function called when sync completes, if sync initiated from button press
	private var processCallbackFunc;

	private function syncAlreadyHappening() as Boolean {
		var happening = Storage.getValue("syncHappening");
		return happening == null ? false : happening;
	}

	// When the event fires we first get the number of quote pages available to download
	public function initiateSync(fromBackground, callbackFunc) as Void {
		if (syncAlreadyHappening()) {
			return;
		}

		Storage.setValue("syncHappening", true);
		syncStartedFromBackground = fromBackground;
		processCallbackFunc = callbackFunc;

		var url = BACKEND_HOST + "/quotewidget/pagecount";
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
		};
		var cb = method(:receivePageCountRequest);
		Communications.makeWebRequest(url, {}, options, cb);
	}

	// Called when the HTTP request to get the page count completes.
	function receivePageCountRequest(responseCode, data) {
		if (responseCode == 200) {
			lastPage = data.toNumber() - 1;
			// Now that we have the number of pages, we can download each of them,
			// starting with the first page (page 0).
			makeQuoteRequest(0);
		}
		else {
			//System.println("Response error in rpcr: " + responseCode);
			// If a request fails we just ignore then pick a quote from the cached quotes.
			pickRandomQuoteAndExit();
		}
	}

	// Picks a random quote from the downloaded ones, then terminates the background task.
	private function pickRandomQuoteAndExit() {
		var quoteCount = Storage.getValue("quoteCount").toNumber();
		if (quoteCount == null) {
			return;
		}

		var lastQuote = Storage.getValue("quoteOfTheDay");
		var lastQuoteID = lastQuote == null ? "-1" : lastQuote["id"];

		Math.srand(System.getTimer().abs());

		// Keep picking a random quote until we have a different one to yesterday
		var randomIndex = -1;
		while (true) {
			randomIndex = random(0, quoteCount - 1);

			// If we only have one quote then we cannot get a different one each time so just exit.
			// Infinite loops are bad lol.
			if (!Storage.getValue(randomIndex)["id"].equals(lastQuoteID) or quoteCount == 1) {
				break;
			}
		}

		Storage.setValue("quoteOfTheDay", Storage.getValue(randomIndex));
		Storage.setValue("syncHappening", false);
		
		if (syncStartedFromBackground) {
			Background.exit(null);
		}
		else {
			processCallbackFunc.invoke();
		}
	}

	// From https://stackoverflow.com/questions/11758809/what-is-the-optimal-algorithm-for-generating-an-unbiased-random-integer-within-a/11758872#11758872
	// Picks random number with good algorithm
	private function random(min, max) {
		var RAND_MAX = 0x7FFFFFF;
		var n = max - min + 1;
		var remainder = RAND_MAX % n;
		var x;
		var output;

		do {
			x = Math.rand();
			output = x % n;
		}
		while (x >= RAND_MAX - remainder);

		return min + output;
	}

	// Called when quote download HTTP request complets
	function onQuotesReceive(responseCode, data) {
		if (responseCode == 200) {
			var page = data["page"].toNumber();
			var rows = data["rows"];

			// Save the quotes to storage, keys are the indices
			for (var i = 0; i < rows.size(); i++) {
				Storage.setValue(page * PAGE_SIZE + i, rows[i]);
			}

			//System.println("Received page " + page);

			// If this was the last page then we have received all quotes and we can now pick one.
			// Otherwise we move on to the next page of quotes.
			if (page == lastPage) {
				Storage.setValue("quoteCount", PAGE_SIZE * lastPage + rows.size());
				pickRandomQuoteAndExit();
			}
			else {
				makeQuoteRequest(page + 1);
			}
		}
		else {
			//System.println("Response ERROR: " + responseCode);
			// If a request fails we just ignore then pick a quote from the cached quotes.
			pickRandomQuoteAndExit();
		}
	}

	// Downloads the specified page of quotes from the backend
	private function makeQuoteRequest(page) as Void {
		var url = BACKEND_HOST + "/quotewidget/quotes/" + page;
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET,
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};
		var cb = method(:onQuotesReceive);
		Communications.makeWebRequest(url, {}, options, cb);
	}
}