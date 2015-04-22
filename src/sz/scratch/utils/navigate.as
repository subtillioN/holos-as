package sz.scratch.utils {
	import com.core.utils.FBtrace;

	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public function navigate($url : String, $target : String) {
		var request : URLRequest = new URLRequest($url);
		try {
			navigateToURL(request, $target);
		} catch (e : Error) {
			FBtrace(this + "Error occurred with the following URL: \r" + $url);
		}
	}
}