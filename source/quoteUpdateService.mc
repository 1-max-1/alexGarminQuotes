using Toybox.Background;
using Toybox.System;
using Toybox.Application.Storage;
using Toybox.Math;

(:background)
class quoteUpdateService extends System.ServiceDelegate {
	function initialize() {
		System.ServiceDelegate.initialize();
	}

	public function onTemporalEvent() as Void {
		if (!System.getDeviceSettings().phoneConnected) {
			pickRandomQuote();
			Background.exit(null);
		}
		else {
			makeRequest();
		}
	}

	private function pickRandomQuote() {
		var quotes = Storage.getValue("quotes");
		if (quotes == null) {
			return;
		}

		var lastQuote = Storage.getValue("quoteOfTheDay");
		var lastQuoteID = lastQuote == null ? "-1" : lastQuote["id"];

		Math.srand(System.getTimer().abs());

		// Keep picking a random quote until we have a different one to yesterday
		var randomIndex = -1;
		while (true) {
			randomIndex = random(0, quotes.size() - 1);

			// If we only have one quote then we cannot get a different one each time so just exit.
			// Infinite loops are bad lol.
			if (!quotes[randomIndex]["id"].equals(lastQuoteID) or quotes.size() == 1) {
				break;
			}
		}

		Storage.setValue("quoteOfTheDay", quotes[randomIndex]);
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

	// Called when quote HTTP request suceeds
	function onReceive(responseCode, data) {
		if (responseCode == 200) {
			Storage.setValue("quotes", data);
		}
		// else {
		// 	System.println("Response ERROR: " + responseCode);
		// }

		pickRandomQuote();
		Background.exit(null);
	}

	private function makeRequest() as Void {
		//var url = "https://data.mongodb-api.com/app/data-drlya/endpoint/data/v1/action/find";
		var url = "https://thingproxy.freeboard.io/fetch/http://externalrequests.yaboichips.ga/GarminQuotes/getallquotes.php";

		// var params = {
		// 	"dataSource" => "Cluster0",
		// 	"database" => "quotes",
		// 	"collection" => "quotes",
		// 	"filter" => {},
		// 	"projection" => {"quote"=> 1}
		// };

		var params = {
			"auth" => "jhgAKYSDGkjgasui"
		};

		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_POST,
			:headers => {
				"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
				//"api-key" => "AzRGWlFDiRMdENnEnZ3o465xdl7igkztHoITXKHbI5gxnPwWpwxBtUgjqbNIvYS7"
			},
			:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};

		var cb = method(:onReceive);
		Communications.makeWebRequest(url, params, options, cb);
	}
}