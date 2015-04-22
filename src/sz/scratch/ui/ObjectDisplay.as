package sz.scratch.ui {
	import com.core.events.LoadEvent;
	import com.core.utils.FBtrace;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	/**
	 * Image is a basic image display class encapsulating loading functionality and image alignment,
	 * as well as a loading animation.
	 *
	 * @version 1.0
	 * @since Apr 13, 2010
	 *
	 */
	public class ObjectDisplay extends Sprite {

		private var _objectA:DisplayObject;
		private var _objectB:DisplayObject;
		private var _inObject:DisplayObject;
		private var _outObject:DisplayObject;
		private var _objectToggle:Boolean = true;


		private var _transitionIN:Function;
		private var _transitionOUT:Function;
		private var _parent : DisplayObjectContainer;

		public function ObjectDisplay($parent  : DisplayObjectContainer):void {
			if($parent) _parent = $parent;
			else _parent=this;
			_objectA.visible = _objectB.visible = false;
			_objectA.alpha = _objectB.alpha = 0;
		}

		/**
		 * adds the new object to display
		 */
		public function add($newObject:DisplayObject):void {
			this.visible = true;

			if (_objectToggle) {
				_inObject = _objectA;
				_outObject = _objectB;
			}
			else {
				_inObject = _objectB;
				_outObject = _objectA;
			}
			_objectToggle = !_objectToggle;
			_inObject = $newObject;
			_transitionInObject();
		}

		private function _transitionInObject():void {
			_inObject.visible = true;
			_parent.addChild(_inObject);
			if (_transitionIN != null) {
				_transitionIN(_inObject);
			}
			else {
				_inObject.alpha = 1;
			}
		}

		private function _transitionOutImage():void {
			if (_transitionOUT != null) {
				_transitionOUT(_outObject);
			}
			else {
				_outObject.alpha = 0;
				_outObject.visible = false;
			}
		}


		/**
		 * Handler for the <code>Event.COMPLETE</code> event on the image loader.
		 * Positions the image and adds it to the display list.
		 */
		private function _onLoadComplete($e:Event = null):void {
			_inObject.removeEventListener(Event.COMPLETE, _onLoadComplete);
			_inObject.removeEventListener(LoadEvent.FAIL, _onLoadFail);
			_transitionOutImage();
		}


		private function _onLoadFail($e:LoadEvent = null):void {
			FBtrace(this + '_onLoadBitmapFail : Bitmap failed to load, likely wrong path at ');
			_inObject.removeEventListener(Event.COMPLETE, _onLoadComplete);
			_inObject.removeEventListener(LoadEvent.FAIL, _onLoadFail);
		}

		public function destroy():void {
			_objectA = null;
			_objectB = null;
		}


		public function hide():void {
			this.visible = false;
			this.alpha = 0;
		}

//		public function showObjects() : void {
//			this.visible=true;
//			this.alpha=1;
//			if(_outObject) _outObject.showImage();
//			if(_inObject)   _inObject.showImage();
//		}


		override public function toString():String {
			return "[" + getQualifiedClassName(this) + "] ";
		}

		public function set transitionIN(value:Function):void {
			_transitionIN = value;
		}

		public function set transitionOUT(value:Function):void {
			_transitionOUT = value;
		}
	}
}
