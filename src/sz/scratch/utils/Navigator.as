package sz.scratch.utils {
	import com.core.utils.FBtrace;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.sendToURL;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * Navigator centralizes url navigation for the purpose of additional global control.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Dec 2, 2009
	 *
	 */

	public class Navigator {
		private static var __instance : Navigator;
		private static const SINGLETON_EXCEPTION : String = "SINGLETON EXCEPTION: Navigator was instantiated outside Singleton context";

		var _delay : Number;
		private var _url : String;
		private var _target : String;
		private var _js : String;
		private var _tagID : String;
		private var _tagArgs : Array;
		private var _URLIndex : Dictionary;
		private static const TAG : String = "_tag";
		private static const JS : String = "_js";
		private var _queryString : String;
		private var _sendOnly : Boolean = false;
		private var _doPrependRoot : Boolean = false;
		private var _rootDir : String;
		private const PREPEND_ROOT : String = "_prepend_root";
		private var _absoluteRoot : String;
		private var _downloadURL : String;

		public function setURLIndex($x : XMLList, $rootDir : String = null) : void {
			rootDir = $rootDir;
			_URLIndex = new Dictionary(true);
			for each (var url : XML in $x) {
				_trace(this + 'url.attribute("prependRoot") = ' + url.attribute("prependRoot"));
				if(url.attribute("prependRoot") != undefined) {
					_trace(this + 'ADDING ROOT FOR ' + url);
					_URLIndex[url.@id + PREPEND_ROOT] = (url.@prependRoot + '' == "true");
				}
				_URLIndex[url.@id + ''] = url + '';
				if(url.attribute("tag") != undefined) _URLIndex[url.@id + TAG] = url.@tag + '';
				if(url.attribute("js") != undefined) _URLIndex[url.@id + JS] = url.@js + '';
			}
		}

		/**
		 *
		 * @param $url      String - the url to navigate to
		 * @param $target   String - optional - the window to open the url in
		 * @param $tagID    String - ID used for the analytics adapter, if present a analytics call wil be sent, otherwise not.
		 * @param $tagArgs  Array - additional arguments for the analytics call, dependent on the presence of the $tagID
		 */
		public function go($url : String, $target : String = "_blank", $tagID : String = null, $tagArgs : Array = null, $js : String = null, $queryObject : Object = null, $sendOnly : Boolean = false, $doPrependRoot : Boolean = false) : void {
			_url = getURLFromID($url, $doPrependRoot);
			_tagID = _URLIndex[$url + TAG];
			if(!_tagID)_tagID = $tagID;
			_js = _URLIndex[$url + JS];
			if(!_js)_js = $js;
			_sendOnly = $sendOnly;
			_target = $target;
			_tagArgs = $tagArgs;

			formatQueryString($queryObject);

			if(_url) {
				if(!_js) {
//					if(_tagID)Controller(ControllerLocator.getInstance().locate(Controller)).sendAnalytics(_tagID, $tagArgs);
					if(_target == "_blank")_delay = setTimeout(_go, 500);
					else _go();
				}
				else {
					_trace(this + 'function called: ' + _js, _url);
					ExternalInterface.call(_js, _url);
				}
			}
		}

		public function send($url : String, $tagID : String = null, $tagArgs : Array = null, $js : String = null, $queryObject : Object = null) : void {
			_trace(this + 'send ');
			go($url, "_blank", $tagID, $tagArgs, $js, $queryObject, true);
		}

		public function formatQueryString($queryObject : Object = null) : String {
			_trace(this + '_formatQueryString ');
			_queryString = '';
			if(!$queryObject)return _queryString;
			var i : int = 0;
			for(var key : Object in $queryObject) {
				// iterates through each object key
				// e.g. /MusaWeb/Mazda5_CA_emailVehicle.action?lang=en&email=john@test.com&trim=gs&transmission=5-speed
				if($queryObject[key] != '') _queryString += (i > 0 ? '&' : '?') + key + '=' + $queryObject[key];
				i++;
			}
			return _queryString;
		}

		/**
		 * separated out for the function of adding a delay to the sending of the url request
		 * so as not to interfere with the analytics functions.
		 */
		private function _go() : void {
			clearTimeout(_delay);
			var request : URLRequest = new URLRequest(_url + _queryString);
			try {
				if(!_sendOnly) {
					_trace(this + 'request = ' + request);
					navigateToURL(request, _target);
				}
				else {
					sendToURL(request);
					_trace(this + 'SENT GET URL REQUEST : ' + request.url);
				}
			} catch (e : Error) {
				FBtrace(this + "Error occurred with the following URL: \r" + _url);
			}
		}

		public function download($url : String, $fileName : String = null, $doPrependRoot : Boolean = false) : void {
			_downloadURL = getURLFromID($url);
			if($doPrependRoot) _downloadURL = _absoluteRoot + _downloadURL;
			_trace(this + '$url = ' + _downloadURL);
			var file : FileReference = new FileReference();
			var request : URLRequest = new URLRequest(_downloadURL);
			file.addEventListener(Event.CANCEL, cancelHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			file.addEventListener(Event.OPEN, openHandler);
			file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			file.addEventListener(Event.SELECT, selectHandler);
			try {
				//TODO: DOUBLE CHECK THAT THIS WORKS ON THE SERVER, AS IT GENERATES ERRORS LOCALLY
				file.download(request, $fileName);
			}
			catch (error : Error) {
				FBtrace("Unable to download file, " + _downloadURL + ".  ERROR : " + error.message);
				go(_downloadURL);
			}
		}

		private function cancelHandler(event : Event) : void {
			_trace("cancelHandler: " + event);
		}

		private function completeHandler(event : Event) : void {
			_trace("completeHandler: " + event);
		}

		private function ioErrorHandler(event : IOErrorEvent) : void {
			_trace("ioErrorHandler: " + event);
			go(_downloadURL);
		}

		private function openHandler(event : Event) : void {
			_trace("openHandler: " + event);
		}

		private function progressHandler(event : ProgressEvent) : void {
			var file : FileReference = FileReference(event.target);
			_trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}

		private function securityErrorHandler(event : SecurityErrorEvent) : void {
			_trace("securityErrorHandler: " + event);
			go(_downloadURL);
		}

		private function selectHandler(event : Event) : void {
			var file : FileReference = FileReference(event.target);
			_trace("selectHandler: name=" + file.name + " URL=" + _downloadURL);
		}


		/**
		 *
		 * Instantiates the Navigator primary class
		 */
		public function Navigator() {
			// Should never be called externally, Navigator is a Singleton
			if(__instance)throw new Error(SINGLETON_EXCEPTION);
		}

		/**
		 *
		 * explicitly request the singleton instance of the Navigator class
		 */
		public static function getInstance() : Navigator {
			if(__instance)return __instance;
			__instance = new Navigator();
			return __instance;
		}

		/**
		 *
		 * implicitly request the singleton instance of the Navigator class
		 */
		public static function get instance() : Navigator {
			if(__instance)return __instance;
			__instance = new Navigator();
			return __instance;
		}

		public function get rootDir() : String {
			return _rootDir;
		}

		public function getURLFromID($id : String, $doPrependRoot : Boolean = false) : String {
			var u : String = _URLIndex[$id] ? _URLIndex[$id] : $id;
			_doPrependRoot = _URLIndex[$id + PREPEND_ROOT];
			if(!_doPrependRoot)_doPrependRoot = $doPrependRoot;
			if(_doPrependRoot && _URLIndex[$id + PREPEND_ROOT]) {
				if(_rootDir != null) {
					u = _rootDir + u;
				}
				else _trace(this + ' ERROR : rootDir has not been set for ' + u);
			}
			return u;
		}

		public function set rootDir(value : String) : void {
			_rootDir = value;
			_trace(this + '_rootDir = ' + _rootDir);
		}

		public function set absoluteRoot($root : String) : void {
			_absoluteRoot = $root;
			_trace(this + '_absoluteRoot = ' + _absoluteRoot);
		}

		private function _trace(...rest) : void {
			//FBtrace(rest);
		}
	}
}
