/**
 * MAIN GOAL : To automate and externalize the management and wiring of the hierarchical navigational (deep-linking)
 * structure and logic of a site.  This aids in removing human error and tedium in ad hoc wiring this structure by hand,
 * and speeds up production by placing the development work in the XML model, with its ready and easy hierarchical
 * structure.
 *
 * GENERAL
 * DeepAddress combines SWFAddressManager---to integrate deep-linking---with the URI or path tree/space modeling
 * in HoloModel to provide an automated, option-space or navigation model for the hierarchical URL path (and data)
 * structural requirements of a site.
 *
 * SETUP
 * Once the XML model is defined and loaded, it just needs to be passed into the HoloModel parser to generate
 * the hierarchical (holarchical) navigation-logic and data structure.  The data in the data XML nodes will be dumped
 * into the generic-typed 'data:*' property instance of the specific node (Holon).  You can inject your own parser (or
 * type-adapter) into the parsing process to translate the 'data' XML into your required objects, which can be of any
 * and varied object type throughout the system, depending only on the logic of the parsing adapter. See HoloModel and
 * Holon for XML schema and setup details.
 *
 * MODEL
 * To retrieve the current position (cursor) in the option-space located in the navigation process (e.g. targeting a
 * specific URL), you can either use the various cursorList getters on HoloModel(e.g. cursorListString, or
 * cursorListData), or you can register callbacks for their values (Arrays) upon change of the cursor list.
 * Note that many of these more esoteric calls and callbacks must be placed on the composed and exposed HoloModel,
 * 'model' property directly.
 *
 * API
 * The navigational API consists of 2-D navigational 'go*' calls such as 'goNextAt({depth})', 'goPrevAt({depth})',
 * 'gotoAddress({address array})', etc.  In general, 'address' refers to the 'physical' or Vector.<int> address,
 * such as 3,1,7.  And 'path' refers to the human readable IDs representing the units in the address, such as the URI,
 * section3/page7/item1.  This is useful, because from anywhere in the system, it's a simple call to iterate through
 * the space at any level with access to the model.
 *
 * @see HoloModel and SWFAddressManager
 *
 * @author Joel Morrison
 * @version 1.0
 * @since 2/8/11
 *
 */
package sz.holos.site {
	import sz.holos.collections.HoloModel;
	import sz.holos.type.utils.arrayToVector;
	import sz.holos.func.runAll;

	public class DeepAddress {
		public var sa : SWFAddressManager;
		public var model : HoloModel;
		private var _onPathUpdate : Vector.<Function>;
		private var _updateFromModel : Boolean = false;

		public function DeepAddress() {
			_init();
		}

		/**
		 * Setup sync logic between SWFAddressManager and HoloModel tree space
		 * init model and sa manager
		 */
		private function _init() : void {
			model = new HoloModel();
			sa = new SWFAddressManager();
			model.delimiter = "/";
			model.onCursorUpdate = _onModelUpdate;
			sa.onInit = _onSAInit;
			sa.onUpdate = _onSAUpdate;
		}

		public function parseModel($x : XML, $dataParser : Function = null) : void {
			model.parse($x);
			if($dataParser != null)model.parseData($dataParser);
			sa.init();
		}

		// ------ CALL LOGIC ----------------------------------------------------------------------------- //

		public function call() : void {
			runAll(_onPathUpdate, model.cursorPathArray);
			_updateFromModel = false;
		}

		// ------ UPDATE LOGIC ----------------------------------------------------------------------------- //

		private function _onModelUpdate(...rest) : void {
			if(_updateFromModel)sa.setPath(model.cursorPathArray);
		}

		private function _onSAUpdate($path : Vector.<String>) : void {
			if(!_updateFromModel)model.setAddressFromPath(sa.path);
			call();
		}


		// ------ HANDLERS ----------------------------------------------------------------------------- //
		private function _onSAInit($path : Vector.<String>) : void {
		}


		// ------ NAVIGATION ----------------------------------------------------------------------------- //

		public function goNextAt($depth : int = 0) : void {
			_updateFromModel = true;
			model.nextAt($depth);
		}

		public function goPrevAt($depth : int = 0) : void {
			_updateFromModel = true;
			model.prevAt($depth);
		}

		public function gotoAddress($address : Array) : void {
			_updateFromModel = true;
			model.getPathArrayFromAddress($address);
		}

		public function gotoPath($path : Array) : void {
			//TODO:  test this method, decide whether it's worth it to recude to Arrays at the API interface, or to force Vectors
			_updateFromModel = true;
			model.setAddressFromPath(arrayToVector($path, new Vector.<String>()));
		}


// ------ GETTERS AND SETTERS ----------------------------------------------------------------------------- //


		public function set onPathUpdate($f : Function) : void {
			if(!_onPathUpdate)_onPathUpdate = new Vector.<Function>();
			_onPathUpdate.push($f);
		}

		public function toString() : String {return "[DeepAddress]";}
	}
}
