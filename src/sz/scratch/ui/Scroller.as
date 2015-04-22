package sz.scratch.ui {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import sz.scratch.utils.tint;

	/**
	 * Scroller handles the interaction between the Flash ScrollBar component and the scroll content.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 12.1.2009
	 *
	 */
	public class Scroller extends MovieClip {
		private var _scrollBar : ScrollBar;
		public var btnUp : SimpleButton;
		public var btnDown : SimpleButton;
		public var scrollTrack : MovieClip;
		public var scrollBtn : Sprite;
		private var _contentMain : Sprite;
		private var _color : uint;
		private var _scrollTimer : Timer;
		private var _p : Number;
		private var _dif : Number;
		private var _speed : Number = 0.10;

		/**
		 * Constructor, initializes key variables and sets up events
		 */
		public function Scroller() : void {
		}

		public function setup($contentMain : Sprite, $maskedView : Sprite) {
			_contentMain = $contentMain;
			_scrollBar = new ScrollBar(scrollBtn, btnUp, btnDown, scrollTrack, $contentMain, $maskedView);
			$maskedView.mouseEnabled = $maskedView.mouseChildren = false;
			_scrollBar.registerCustomContentScroll(_onScroll);
			_scrollTimer = new Timer(1);
			_scrollTimer.addEventListener(TimerEvent.TIMER, _updatePosition);
			addChild(scrollTrack);
			addChild(scrollBtn);
			addChild(btnUp);
			addChild(btnDown);
			refresh();
			addEventListener(Event.ADDED_TO_STAGE, _onStage);
			addEventListener(Event.REMOVED_FROM_STAGE, _offStage);
		}

		private function _updatePosition(event : TimerEvent) : void {
			_dif = (_p - _contentMain.y) * _speed;
			_contentMain.y = _contentMain.y + _dif;
			if(Math.abs(_dif) < 0.05 || _contentMain.y == _p) {
				_scrollTimer.stop();
				_contentMain.y = _p;
			}
		}

		private function _onScroll($p : Number) : void {
			_p = $p;
			_scrollTimer.start();
		}

		public function refresh() : void {
			if(_scrollBar)_scrollBar.updateHeight();
			tint(_color, scrollTrack);
			tint(_color, scrollBtn);
			tint(_color, btnUp);
			tint(_color, btnDown);
		}

		/**
		 * Resets the scroll position to zero
		 */
		public function reset() : void {
			_scrollBar.setScrollPercent(0);
		}

//
		/**
		 * Handler for the Event.REMOVED_FROM_STAGE Event, removes the MouseEvent.MOUSE_WHEEL listener from the Stage
		 * @param event not used
		 */
		private function _offStage(event : Event) : void {
			_contentMain.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}

		/**
		 * Handler for the Event.ADDED_TO_STAGE Event, adds the MouseEvent.MOUSE_WHEEL listener to the stage
		 * @param event  not used
		 */
		private function _onStage(event : Event) : void {
			_contentMain.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}

//
		/**
		 * Handler for the MouseEvent.MOUSE_WHEEL Event, sets the scroll position on changes from the mouse wheel
		 * @param event used for grabbing changes (delta) to the mouse wheel
		 */
		function _onMouseWheel(event : MouseEvent) : void {
			var delta : Number = 0 - event.delta * 0.1;
			_scrollBar.offsetScrollPercent(delta);
		}


		public function set color($color : uint) : void {
			_color = $color;
			refresh();
		}
	}
}
