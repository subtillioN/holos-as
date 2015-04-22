package sz.scratch.animation {
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * FramerateManager is a static class with the goal of optimizing application framerate
	 * and thereby reducing the computational resources of the Flash application.  This
	 * saves on overall power consumption, and for mobile devices, saves on battery life.
	 * FramerateManager centralizes the management of framerate across an application,
	 * thereby helping to manage hardware resources intelligently and effectively, turning
	 * down the framerate when the application is idle (i.e. not running any animations,
	 * such as tweens), and turning it back on when animation is needed.
	 * <p>
	 * <p>
	 * Note: Video framerate is independent of global application framerate, so even
	 * when a video is running, application framerate can be reduced, saving on overall
	 * computational resources, etc.
	 * <p>
	 * <p>
	 * USAGE IN CODE:
	 * 1. Run FramerateManager.init() in the root or document class to initialize the settings.
	 * 2. Before beginning any animations or tweens, call FramerateManager.active().
	 * 3. Delay the onset of the tween by the amount FramerateManager.delay (defaults to .1 seconds).
	 * 4. When the tween finishes, call FramerateManager.rest().
	 *
	 * If using the Transitions class for your animations, you just tell Transitions to manage the
	 * timeline optimization for you, and it keeps track of how many tweens are active and when to
	 * trigger active and rest modes.
	 *
	 * TIMELINE USAGE:
	 * For timeline usage just follow the code usage, except that communication with FramerateManager
	 * can take place through dispatching the appropriate events from the stage, e.g. on a frame script:
	 *
	 * import flash.events.*;
	 * stage.dispatchEvent(new Event("framerateRestAbsolute"));
	 *
	 * In general, using the Transitions class to keep track of framerate management is far more
	 * integrated and precise, because it's all automated for you.  You just run your tweens
	 * and it takes care of everything. Barring that, your animation counts can easily come out
	 * of line, so when appropriate, just pass true to the rest() parameter, to tell it to reset
	 * the count at zero (when not in the middle of some animation).
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Apr 7, 2010
	 *
	 */
	public class FramerateManager {
		private static var _delay : Number = .1;
		private static var _animationsRunning : Number = 0;
		private static var _manageFramerate : Boolean = false;
		private static var _mouseLeaveMode : Boolean = false;
		private static var _activeFramerate : Number = 30;
		private static var _restFramerate : Number = 5;
		private static var _previousFramerate : Number;
		private static var _stage : Stage;

		public static const FRAMERATE_ACTIVE : String = "framerateActive";
		public static const FRAMERATE_REST : String = "framerateRest";
		public static const FRAMERATE_REST_ABSOLUTE : String = "framerateRestAbsolute";

		/**
		 * Constructor, throws an IllegalOperationError because this is a static class
		 */
		public function FramerateManager() {
			throw new IllegalOperationError("Illegal instantiation attempted on class, 'FramerateManager', of static type.");
		}

		/**
		 * Initializes the FramerateManager, setting the basic parameters for its function.
		 * @param $stage            Stage   - A reference to the stage
		 * @param $activeFramerate  Number  - Default:30 - The framerate to use for animations or tweens
		 * @param $restFramerate    Number  - Default:5 - The framerate to use when animations or tweens are occurring
		 *                                      (setting it below 5 can cause lags in motion, when it switches back to active mode)
		 * @param $restDelayGlobal  Number  - Default:0 - Sets the global delay to use when setting the framerate to rest,
		 *                                      such that the class can be used as an activity monitor of sorts.
		 * @param $mouseLeaveMode   Boolean - Default:true - Determines whether to set the framerate to rest when the mouse leaves the stage
		 * @param $rest             Boolean - Default:true - Determines whether to begin framerate at rest
		 */
		public static function init($stage : Stage, $activeFramerate : Number = NaN, $restFramerate : Number = NaN, $mouseLeaveMode : Boolean = true, $rest : Boolean = true, $restDelayGlobal : Number = 0) : void {
			_stage = $stage;
			if(!isNaN($activeFramerate)) _activeFramerate = $activeFramerate;
			if(!isNaN($restFramerate)) _restFramerate = $restFramerate;
			_mouseLeaveMode = $mouseLeaveMode;
			if($rest) rest();
			manageFramerate = true;

			_stage.addEventListener(FRAMERATE_ACTIVE, _onFramerateActive);
			_stage.addEventListener(FRAMERATE_REST, _onFramerateRest);
			_stage.addEventListener(FRAMERATE_REST_ABSOLUTE, _onFramerateRestAbsolute);
		}


		//--------------------------------------------------------------------------
		//
		//   EVENT INTERFACE FOR USE IN FRAME SCRIPTS AND TIMELINE CODING
		//
		//--------------------------------------------------------------------------
		private static function _onFramerateRestAbsolute(...rest) : void {
			_trace('             _onFramerateRestAbsolute ');
			FramerateManager.rest(true);
		}

		private static function _onFramerateRest(...rest) : void {
			_trace('            _onFramerateRest');
			FramerateManager.rest();
		}

		private static function _onFramerateActive(...rest) : void {
			_trace('            _onFramerateActive');
			FramerateManager.active();
		}

		// --- END EVENT INTERFACE --- //


		//--------------------------------------------------------------------------
		//
		//    DIRECT INTERFACE
		//
		//--------------------------------------------------------------------------

		/**
		 * sets the framerate to the _activeFramerate
		 */
		public static function active() : void {
			if(!_stage) {
				_stageError();
				return;
			}
			_stage.frameRate = _activeFramerate;
			_animationsRunning++;
			_trace('active');
			_trace('         frameRate = ' + _stage.frameRate);
			_trace('         animationsRunning = ' + _animationsRunning + "\r");
		}

		public static function rest($absolute : Boolean = false, $restDelay : Number = 0) : void {
			if(!_stage) {
				_stageError();
				return;
			}
			_animationsRunning--;
			if(_animationsRunning < 0 || $absolute)_animationsRunning = 0;
			if(!_animationsRunning)_stage.frameRate = _restFramerate;

			_trace('rest');
			_trace('         frameRate = ' + _stage.frameRate);
			_trace('         animationsRunning = ' + _animationsRunning + "\r");
		}

		/**
		 * public implicit setter for _manageFramerate, which determines whether or not framerate management occurs.
		 */
		public static function set manageFramerate($manageFramerate : Boolean) : void {
			_manageFramerate = $manageFramerate;
			if(_stage && _mouseLeaveMode) {
				_stage.addEventListener(Event.MOUSE_LEAVE, _onMouseLeave);
			}
		}

		private static function _onMouseLeave(event : Event) : void {
			_previousFramerate = _stage.frameRate;
			rest();
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseReturn);
		}

		private static function _onMouseReturn(event : MouseEvent) : void {
			_stage.frameRate = _previousFramerate;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseReturn);
		}

		public static function get delay() : Number {
			return _delay;
		}

		public static function set delay(value : Number) : void {
			_delay = value;
		}

		public static function get activeFramerate() : Number {
			return _activeFramerate;
		}

		public static function set activeFramerate(value : Number) : void {
			_activeFramerate = value;
		}

		public static function get restFramerate() : Number {
			return _restFramerate;
		}

		public static function set restFramerate(value : Number) : void {
			_restFramerate = value;
		}

		private static function _stageError() : void {
			_trace("FramerateManager does not have access to Stage");
		}

		public static function get animationsRunning() : Number {
			return _animationsRunning;
		}

		public static function set animationsRunning(value : Number) : void {
			_animationsRunning = value;
		}

		private static function _trace(...rest) : void {
			//trace(rest);
		}
	}
}