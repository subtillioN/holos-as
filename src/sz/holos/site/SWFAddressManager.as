package sz.holos.site {
	import com.core.utils.SWFAddress;
	import com.core.utils.SWFAddressEvent;

	/**
	 * SWFAddressManager handles the setting and receiving of deep-address integrated global state in a simple linear
	 * fashion, by translating the url to an Array to be handled and used in global state management.
	 *
	 * @see DeepAddress for more automated modeling and management of the site hierarchy tree structure,
	 * such as multidimensional navigation via simple next, previous, goto, etc commands, with control over
	 * the depth of the tree at which the navigation takes place etc.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 2/8/11
	 *
	 */
	public class SWFAddressManager {
		private var _saHead : String = "/";
		private var _delimiter : String = "/";
		private var _path : Vector.<String>;
		private var _onUpdate : Function;
		private var _onInit : Function;

		public function SWFAddressManager() {
		}

		public function init() : void {
			_path = new Vector.<String>();
			SWFAddress.onInit = _onSAInit;
			SWFAddress.onChange = _onSAUpdate;
		}


		/**
		 *  Handler for SWFAddress.onInit, sets _SAInit to true if the current value corresponds to Sections.HOME
		 */
		private function _onSAInit() : void {
			_parseSWFA(SWFAddress.getValue());
			if(_onInit != null)_onInit(_path);
		}


		/**
		 * Handler for the SWFAddress.onChange event.  Runs _checkSection if the SWFAddress has been initialized (i.e. if _SAInit == true)
		 * @param e
		 */
		private function _onSAUpdate(e : SWFAddressEvent = null) : void {
			_parseSWFA(SWFAddress.getValue());
		}


		/**
		 * Strips the SWFAddress url into section and subsection IDs, and returns the section ID as a String Vector list
		 * @param $swfa
		 * @return String
		 */
		private function _parseSWFA($swfa : String) : Vector.<String> {
			//cut off the string header
			var section : String = $swfa.substr(_saHead.length);
			//split off subsection
			_path.length = 0;
			var i : int = 0;
			for each (var s : String in section.split(_delimiter)) {
				_setListElement(i, s);
				i++;
			}
			if(_onUpdate != null)_onUpdate(_path);
			return _path;
		}

		private function _setListElement($depth : int, $id : String) : void {
			_path[$depth] = $id;
		}

		public function setPath($list : Array) : void {
			var address : String = '';
			var len : int = $list.length;
			var i : int = 0;
			for each (var s : String in $list) {
				address += s;
				_setListElement(i, s);
				i++;
				if(i < len)address += '/';
			}
			SWFAddress.setValue(address);
		}

		// ________________________________________________________________________________ //

		public function set onUpdate($f : Function) : void {
			_onUpdate = $f;
		}

		public function set onInit($f : Function) : void {
			_onInit = $f;
		}

		public function get path() : Vector.<String> {
			return _path;
		}

		public function get pathArray() : Array {
			return _path.join(",").split(",");
		}

		public function toString() : String {
			return "[sz.utils.SWFAddressManager] ";
		}
	}
}