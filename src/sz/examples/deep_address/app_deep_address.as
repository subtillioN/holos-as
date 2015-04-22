package sz.examples.deep_address {
	import com.core.mvc.locate;
	import com.core.utils.FBtrace;

	import sz.scratch.utils.genToString;

	import fl.controls.Button;
	import fl.controls.NumericStepper;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import sz.holos.factory.construct.ConstructorListVO;
	import sz.holos.factory.construct.ConstructorVO;
	import sz.scratch.animation.Transitions;
	import sz.holos.config.R;
	import sz.holos.ui.logic.DisplayDataPath;


	/**
	 * MAIN GOAL : To loosely demonstrate and test the DeepAddress system which serves to model, automate and
	 * externalize the management of the hierarchical navigational (incl. deep-linking) structure, logic and data
	 * requirements of a site.
	 *
	 * SUB-GOAL : To demonstrate how this can be used to "flatten" the display list by offloading as much of the site
	 * hierarchical organization to a logical model and out of the "physical" display list where the compounding of
	 * nested coordinate systems (and other baggage) can impact performance.  This serves also to explore the
	 * trade-offs and workarounds in this way of working under computational limitations such as on embedded devices.
	 *
	 * @see DeepAddress, HoloModel and SWFAddressManager
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 2/8/11
	 *
	 */
	public class app_deep_address extends MovieClip {
		public var nextBtn : Button;
		public var prevBtn : Button;
		public var depthStepper : NumericStepper;
		public var address_txt : TextField;
		private var _ctrl : Controller;
		private var _xml : XML;
		private var _displayPath : DisplayDataPath;

		private static const DATA_KEY : String = "deep_address";

		//TODO : Flesh out display logic
		public function app_deep_address() {
			_init();
		}

		private function _init() : void {
			_ctrl = locate(Controller);
			// you can use the onPathUpdate array to switch your sections, or...
			_ctrl.deepAddress.onPathUpdate = _onPathUpdate;
			// ... you can also customize the HoloModel in DeepAddress and populate it with your data objects
			// and use the model.onCursorListDataUpdate callback to update your views or display objects with the
			// data for the current section hierarchy.
			_ctrl.deepAddress.model.onCursorListDataUpdate = _onDataUpdate;

			nextBtn.addEventListener(MouseEvent.CLICK, _onNext);
			prevBtn.addEventListener(MouseEvent.CLICK, _onPrev);

			_setUpDisplay();

			config();
		}

		public function config() : void {
			//no need to set roots on R, since it's all in one root
			R.config("config_deep_address.xml", _onConfig, _onConfigFail);
		}

		private function _onDataUpdate($da : Array) : void {
			_trace('' + this + '$da = ' + $da);

			_displayPath.update($da);

			// update nav buttons
			if(_ctrl.deepAddress.model.hasNextAt(depthStepper.value)) {
				nextBtn.alpha = 1;
				nextBtn.mouseEnabled = true;
			}
			else {
				nextBtn.alpha = .25;
				nextBtn.mouseEnabled = false;
			}
			if(_ctrl.deepAddress.model.hasPrevAt(depthStepper.value)) {
				prevBtn.alpha = 1;
				prevBtn.mouseEnabled = true;
			}
			else {
				prevBtn.alpha = .25;
				prevBtn.mouseEnabled = false;
			}
		}

		private function _onPathUpdate($path : Array) : void {
			_trace(this + '_onPathUpdate ________________________________________________________________________________\r' +
					      '________________________________________________________________________________');
			_trace('' + this + '$sectionList = ' + $path);
			address_txt.text = $path.toString();
			_trace('' + this + '_addressTree.tree.addressNum = ' + _ctrl.deepAddress.model.cursorListAddress);
		}

		private function _onConfig() : void {
			_trace(this + '_onConfig ');
			_xml = R.getXML(DATA_KEY);
			_trace('' + this + '_xml = ' + _xml);
			_ctrl.deepAddress.parseModel(_xml, SectionVO.parse);
			_ctrl.deepAddress.gotoAddress([0,1,2]);
		}


		private function _onConfigFail(...rest) : void {
			_trace(this + '_onConfigFail ');
		}

		private function _setUpDisplay() : void {
			trace(this + '_setUpDisplay ');
			var clist : ConstructorListVO = new ConstructorListVO(
					[new ConstructorVO(SectionA),
					 new ConstructorVO(SectionB),
					 new ConstructorVO(SectionC)
					]);
			_displayPath = new DisplayDataPath(this, clist);
			_displayPath.setTransINList(transitionIN_0, transitionIN_1, transitionIN_2);
			_displayPath.setTransOUTList(transitionOUT_0, transitionOUT_1, transitionOUT_2);
		}


		private function _onNext(event : MouseEvent) : void {
			_ctrl.deepAddress.goNextAt(depthStepper.value);
		}

		private function _onPrev(event : MouseEvent) : void {
			_ctrl.deepAddress.goPrevAt(depthStepper.value);
		}


		// --- DISPLAY LOGIC --- //
		// --- 0 --- //
		private function transitionIN_0($o : DisplayObject) : void {
			Transitions.instance.fadein([$o], .25, null, null, null, true, 0);
			Transitions.instance.tween([$o], 'y', 0, .25, null, null, null, null, 0);
		}

		private function transitionOUT_0($o : DisplayObject) : void {
			Transitions.instance.fadeout([$o], .25);
			Transitions.instance.tween([$o], 'y', 35, .25, null, null, null, null, 0);
		}

		// --- 1 --- //
		private function transitionIN_1($o : DisplayObject) : void {
			transitionIN_0($o);
			Transitions.instance.tween([$o], 'x', 0, .25, null, null, null, null, 0);
		}

		private function transitionOUT_1($o : DisplayObject) : void {
			transitionOUT_0($o);
			Transitions.instance.tween([$o], 'x', 100, .25, null, null, null, null, 0);
		}

		// --- 2 --- //
		private function transitionIN_2($o : DisplayObject) : void {
			transitionIN_1($o);
			Transitions.instance.tween([$o], 'rotationX', 0, .35, null, null, null, null, 0);
			$o.rotationY = -30;
			Transitions.instance.tween([$o], 'rotationY', 0, .35, null, null, null, null, 0);
		}

		private function transitionOUT_2($o : DisplayObject) : void {
			transitionOUT_1($o);
			Transitions.instance.tween([$o], 'rotationX', 30, .10, null, null, null, null, 0);
			Transitions.instance.tween([$o], 'rotationY', 30, .10, null, null, null, null, 0);
		}

		private function _trace(...rest):void{
			FBtrace(rest);
		}


		override public function toString() : String {
			return genToString(this);
		}
	}

}