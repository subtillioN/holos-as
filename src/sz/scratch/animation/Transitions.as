package sz.scratch.animation {
	import com.core.easing.None;
	import com.core.easing.Regular;
	import com.core.easing.Strong;
	import com.core.effects.BlurFilterTween;
	import com.core.effects.ColorTween;
	import com.core.effects.Tween;
	import com.core.events.TweenEvent;

	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * Transitions is a rough attempt to centralize, facilitate, and coordinate the use of ICAS3 tweens such that it
	 * can be integrated into global framework for managing animation resources, such as global frame-rate for power
	 * management (e.g. for mobile).  As such, it really needs to be broken down into modular components, e.g. the
	 * management core, and the transition interface and plugable types.
	 *
	 * It acts as a tween manager in the sense that it keeps track of and makes sure each tween on the corresponding
	 * property on each object stops before a new tween on the same property on that object can begin.
	 * <code>Dictionaries</code> for each tweened property are filed in the <code>_tweenIndexes Dictionary</code> using
	 * the tween property <code>String</code> as key.<br><br>  It includes the methods: fadein, fadeout, crossfade, blur
	 * (and blur fades), tint, move (which accepts params for both x and y, as well as relative and absolute
	 * coordinates), and scaleRect which takes a Rectangle as the scaleX, scaleY, and optional x and y targets.<br>
	 * <p>
	 * <p>
	 * 4.7.2010 Added integration of FramerateManager for centralizing and optimizing application frame rates (and power
	 * management for mobile devices) by routing all animations through Transitions.  See FramerateManager for managing
	 * framerate optimization outside of the Transitions class.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 9.3.2009
	 *
	 */
	public class Transitions extends EventDispatcher {
		// --- durationS --- //
		public static const SPEED_MEDIUM : Number = .5;
		public static const SPEED_SLOW : Number = 1;
		public static const SPEED_FAST : Number = .25;
		public static const SPEED_SPEEDY : Number = .15;

		// --- COMMON EASING FUNCTIONS --- //
		public static const F_REGULAR : Function = Regular.easeOut;
		public static const F_STRONG : Function = Strong.easeOut;
		public static const F_NONE : Function = None.easeOut;

		// --- TWEEN TYPES --- //
		public static const ALPHA : String = "alpha";
		public static const TINT : String = "tint";
		public static const BLUR : String = "blur";

		// --- TWEEN INDEX --- //
		/**
		 * used to get access to tweens, in order to stop them before starting another of the same type on the same object.
		 * Stores the indexes of tweens, based on property strings.  Each property index uses the tweened objects for keys.
		 */
		private var _tweenIndexes : Dictionary;

		// --- DEFAULTS --- //
		public var useSeconds : Boolean;
		public var defaultDuration : Number;
		public var defaultDelay : Number;
		public var defaultEasing : Function;
		public var defaultCallback : Function;
		public var manageFramerate : Boolean = false;

		private static var __instance : Transitions;
		private static const SINGLETON_EXCEPTION : String = "SINGLETON EXCEPTION: Transitions was instantiated outside Singleton context";


		// --- DEFAULTS --- //

		private function _initializeDefaults() : void {
			defaultDuration = SPEED_MEDIUM;
			defaultEasing = F_REGULAR;
			useSeconds = true;
			defaultDelay = 0;
		}

		/**
		 *
		 * <code>setDefaults</code> sets the defaults of the singlton instance to be used in the tweens when specific exceptions are not passed in.<br>
		 *
		 * @param	$useSeconds A value of true will use seconds for the tweens, and false will use frames.<br>
		 * @param	$defaultDuration Determines the default duration to use in the tweens.<br>
		 * @param	$defaultEasing Determines the default easing function to use in the tweens.<br>
		 * @param	$defaultCallback Adds a callback to be called by default if no callback is specified in the tweening methods.<br>
		 */
		public function setDefaults($useSeconds : Boolean, $defaultDuration : Number = NaN, $defaultEasing : Function = null, $defaultCallback : Function = null) : void {
			useSeconds = $useSeconds;
			if($defaultDuration || $defaultDuration == 0) defaultDuration = $defaultDuration;
			if($defaultEasing != null) defaultEasing = $defaultEasing;
			if($defaultCallback != null) defaultCallback = $defaultCallback;
		}

		/**
		 * Initializes the FramerateManager, setting the basic parameters for its function.
		 * @param $stage            Stage   - A reference to the stage
		 * @param $activeFramerate  Number  - Default:30 - The framerate to use for animations or tweens
		 * @param $restFramerate    Number  - Default:5 - The framerate to use when animations or tweens are occurring: defaults to 5
		 *                                  (setting it below 5 can cause lags in motion, when it switches back to active mode)
		 * @param $mouseLeaveMode   Boolean - Default:true - Determines whether to set the framerate to rest when the mouse leaves the stage
		 * @param $rest             Boolean - Default:true - Determines whether to begin framerate at rest
		 */
		public function initFramerateManagement($stage : Stage, $activeFramerate : Number = NaN, $restFramerate : Number = NaN, $delay : Number = .1, $mouseLeaveMode : Boolean = true, $rest : Boolean = true) : void {
			FramerateManager.init($stage, $activeFramerate, $restFramerate, $mouseLeaveMode, $rest);
			FramerateManager.delay = defaultDelay = $delay;
			manageFramerate = true;
		}

		// --- TRANSITIONS --- //

		/**
		 * <code>tween</code> takes an array of objects and will tween their <code>$prop</code> values to the value of the <code>$value</code> param.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to apply the fades upon<br>
		 * @param $prop The property to tween<br>
		 * @param $value The value to tween the property to<br>
		 * @param $duration The duration of the fade.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $completeCallback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $changeCallback A handler function for the <code>TweenEvent.MOTION_CHANGE</code> event
		 * If nothing is passed in, it does not handle the event.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function tween($objects : Array, $prop : String, $value : Number, $duration : Number = NaN, $easing : Function = null, $completeCallback : Function = null, $changeCallback : Function = null, $useSeconds : * = null, $delay : Number = NaN) : Tween {
			var i : int = 0;
			for each (var o : Object in $objects) {
				i++;
				var tween : Tween = newTween(o, $prop, NaN, $value, $duration, $easing, $useSeconds, $delay);
				if(i == 1)_addCallbacks(tween, $completeCallback, $changeCallback);
			}
			return tween;
		}


		/**
		 * <code>fadein</code> takes an array of objects and will tween their alpha values in.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to apply the fades upon<br>
		 * @param $duration The duration of the fade.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function fadein($objects : Array, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $setVisibility : Boolean = true, $delay : Number = NaN) : Tween {
			var i : int = 0;
			for each (var o : Object in $objects) {
				i++;
				if($setVisibility) o.visible = true;
				var tween : Tween = newFadeTween(o, $duration, $easing, false, $useSeconds, $delay);
				if(i == 1)_addCallbacks(tween, $callback);
			}
			return tween;
		}

		/**
		 * <code>fadeout</code> takes an array of objects and will tween their alpha values out.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to apply the fades upon<br>
		 * @param $duration The duration of the fade.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function fadeout($objects : Array, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $delay : Number = NaN) : Tween {
			var i : int = 0;
			for each (var o : Object in $objects) {
				i++;
				var tween : Tween = newFadeTween(o, $duration, $easing, true, $useSeconds, $delay);
				if(i == 1)_addCallbacks(tween, $callback);
			}
			return tween;
		}

		/**
		 * <code>fadeto</code> takes an array of objects and will tween their alpha values to the value of the <code>$to</code> param.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to apply the fades upon<br>
		 * @param $to The value to fade to.<br>
		 * @param $duration The duration of the fade.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function fadeto($objects : Array, $to : Number, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $delay : Number = NaN) : Tween {
			var i : int = 0;
			for each (var o : Object in $objects) {
				i++;
				var tween : Tween = newTween(o, ALPHA, NaN, $to, $duration, $easing, $useSeconds, $delay);
				if(i == 1)_addCallbacks(tween, $callback);
			}
			return tween;
		}

		/**
		 * <code>crossfade</code> takes two arrays of objects, <code>$in</code> and <code>$out</code>, and will tween the <code>$in</code>
		 * alpha values in, and the <code>$out</code> alpha values out.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $in An array of objects to fade in<br>
		 * @param $out An array of objects to fade out<br>
		 * @param $duration The duration of the crossfade.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default</code>.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function crossfade($in : Array, $out : Array, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $delayIn : Number = NaN, $delayOut : Number = NaN) : void {
			if($in && $out) {
				fadein($in, $duration, $easing, $callback, $useSeconds, true, $delayIn);
				fadeout($out, $duration, $easing, null, $useSeconds, $delayOut);
			}
		}

		/**
		 * <code>blurFadein</code> combines a <code>blur</code> with a <code>fadein</code>.  It takes an array of objects
		 * and runs a <code>BlurFilterTween</code> and an alpha <code>Tween</code> in simultaneously.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to fade and blur in<br>
		 * @param $blurBegin A <code>BlurFilter</code> to begin the <code>BlurFilterTween</code><br>
		 * @param $blurEnd A <code>BlurFilter</code> to end the <code>BlurFilterTween</code><br>
		 * @param $duration The duration of the blurFadein.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function blurFadein($objects : Array, $blurBegin : BlurFilter, $blurEnd : BlurFilter, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $delay : Number = NaN) : void {
			blur($objects, $blurBegin, $blurEnd, $duration, $easing, $callback, $useSeconds, $delay);
			fadein($objects, $duration, $easing, null, $useSeconds, true, $delay);
		}

		/**
		 * <code>blurFadeout</code> combines a <code>blur</code> with a <code>fadeout</code>.  It takes an array of objects
		 * and runs a <code>BlurFilterTween</code> and an alpha <code>Tween</code> out simultaneously.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to fade and blur out<br>
		 * @param $blurBegin A <code>BlurFilter</code> to begin the <code>BlurFilterTween</code><br>
		 * @param $blurEnd A <code>BlurFilter</code> to end the <code>BlurFilterTween</code><br>
		 * @param $duration The duration of the blurFadeout.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function blurFadeout($objects : Array, $blurBegin : BlurFilter, $blurEnd : BlurFilter, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $delay : Number = NaN) : void {
			blur($objects, $blurBegin, $blurEnd, $duration, $easing, $callback, $useSeconds, $delay);
			fadeout($objects, $duration, $easing, null, $useSeconds, $delay);
		}

		/**
		 * <code>blurFadeto</code> combines a <code>blur</code> with a <code>fadeto</code>.  It takes an array of objects
		 * and simultaneously runs a <code>BlurFilterTween</code> and an alpha <code>Tween</code> to a designated value.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to fade and blur<br>
		 * @param $blurBegin A <code>BlurFilter</code> to begin the <code>BlurFilterTween</code><br>
		 * @param $blurEnd A <code>BlurFilter</code> to end the <code>BlurFilterTween</code><br>
		 * @param $duration The duration of the tween.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function blurFadeto($objects : Array, $to : Number, $blurBegin : BlurFilter, $blurEnd : BlurFilter, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $delay : Number = NaN) : void {
			blur($objects, $blurBegin, $blurEnd, $duration, $easing, $callback, $useSeconds, $delay);
			fadeto($objects, $to, $duration, $easing, null, $useSeconds, $delay);
		}

		/**
		 * <code>blur</code> takes an array of objects runs a <code>BlurFilterTween</code>between the <code>$blurBegin</code>
		 *  and <code>$blurEnd</code> values.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to blur<br>
		 * @param $blurBegin A <code>BlurFilter</code> to begin the <code>BlurFilterTween</code><br>
		 * @param $blurEnd A <code>BlurFilter</code> to end the <code>BlurFilterTween</code><br>
		 * @param $duration The duration of the tween.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code>
		 *
		 */
		public function blur($objects : Array, $blurBegin : BlurFilter, $blurEnd : BlurFilter, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $delay : Number = NaN) : void {
			var i : int = 0;
			for each (var o : Object in $objects) {
				i++;
				var tween : BlurFilterTween = newBlurTween(o, $blurBegin, $blurEnd, $duration, $easing, $useSeconds, $delay);
				if(i == 1)_addCallbacks(tween, $callback);
			}
		}

		/**
		 * <code>tintto</code> takes an array of objects and runs a <code>ColorPercentTween</code> on the <code>ColorPercentTween.HEX</code> property,
		 * tinting it to a specified color, and to a specified value or degree of tint.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to tine<br>
		 * @param $color the hex color value to tween to<br>
		 * @param $to the tint value or degree to tween to<br>
		 * @param $duration The duration of the tween.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code><br>
		 *
		 */
		public function tintto($objects : Array, $color : Number, $to : Number, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null) : void {
			var i : int = 0;
			for each (var o : Object in $objects) {
				i++;
				var tween : ColorPercentTween = newColorTween(o, ColorTween.HEX, $color, $to, $duration, $easing, $useSeconds);
				if(i == 1)_addCallbacks(tween, $callback);
			}
		}

		/**
		 * <code>tintout</code> takes an array of objects and runs a <code>ColorPercentTween</code> on the <code>ColorPercentTween.TINT_MULTIPLIER</code> property,
		 * tinting it out to a zero degree of tint.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to tint<br>
		 * @param $duration The duration of the tween.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code><br>
		 *
		 */
		public function tintout($objects : Array, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null) : void {
			var i : int = 0;
			for each (var o : Object in $objects) {
				i++;
				var tween : ColorPercentTween = newColorTween(o, ColorPercentTween.TINT_MULTIPLIER, NaN, 0, $duration, $easing, $useSeconds);
				if(i == 1)_addCallbacks(tween, $callback);
			}
		}

		/**
		 * <code>tint</code> takes an array of objects and runs a <code>ColorPercentTween</code> on the <code>ColorPercentTween.HEX</code> property,
		 * tinting it %100 to a specified color.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to tint<br>
		 * @param $color the hex color value to tween to<br>
		 * @param $duration The duration of the tween.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code><br>
		 *
		 */
		public function tint($objects : Array, $color : Number, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null) : void {
			tintto($objects, $color, 1, $duration, $easing, $callback, $useSeconds);
		}

		/**
		 * <code>move</code> takes an array of objects and tweens both the x and y values, in either relative or absolute coordinates.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to move<br>
		 * @param $x the x value to tween to<br>
		 * @param $y the y value to tween to<br>
		 * @param $duration The duration of the tween.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code><br>
		 * @param $relative a boolean value, if true will use the $x and $y values to offset the current x and y,
		 * and if false will use absolute values
		 *
		 */
		public function move($objects : Array, $x : Number = NaN, $y : Number = NaN, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null, $delay : Number = NaN, $relative : Boolean = false) : void {
			var tweenX : Tween;
			var tweenY : Tween;
			var i : int = 0;
			for each (var o : Object in $objects) {
				i++;
				o.visible = true;
				if($x) tweenX = newTween(o, 'x', NaN, ($relative) ? o.x + $x : $x, $duration, $easing, $useSeconds, $delay);
				if($y) tweenY = newTween(o, 'y', NaN, ($relative) ? o.y + $y : $y, $duration, $easing, $useSeconds, $delay);
				if(i == 1 && tweenX)_addCallbacks(tweenX, $callback);
				else if(i == 1 && tweenY)_addCallbacks(tweenY, $callback);
			}
		}

		/**
		 * <code>scaleRect</code> takes an array of objects and tweens both the scaleX and scaleY values, along with the optional x and y values.
		 * If no other parameters are passed in, it will use the default settings for the easing function and duration.
		 * These can be set globally on the singleton instance through the <code>setDefaults</code> function.<br>
		 *
		 * @param $objects An array of objects to move<br>
		 * @param $rect The <code>Rectangle</code> which provides the <code>width</code>, <code>height</code>, and optional
		 * <code>x</code> and <code>y</code> values<br> to tween to.
		 * @param $position Boolean determining if the position values are to be used.
		 * @param $duration The duration of the tween.  If nothing is passed in, it uses the default,
		 * which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $easing The easing function to use in the tweens.  If nothing is passed in,
		 * it uses the default, which can be set for the singleton instance through <code>setDefaults</code>.<br>
		 * @param $callback A handler function for the <code>TweenEvent.MOTION_FINISH</code> event,
		 * applied to the first tween.  If nothing is passed in, it uses the default.<br>
		 * @param $useSeconds Overrides the default <code>useSeconds</code><br>
		 *
		 */
		public function scaleRect($objects : Array, $rect : Rectangle, $position : Boolean, $duration : Number = NaN, $easing : Function = null, $callback : Function = null, $useSeconds : * = null) : void {
			var tween : Tween;
			if($rect) {
				var i : int = 0;
				for each (var doc : DisplayObjectContainer in $objects) {
					i++;
					tween = newTween(doc, "width", NaN, $rect.width, $duration, $easing, $useSeconds);
					newTween(doc, "height", NaN, $rect.height, $duration, $easing, $useSeconds);
					if($position) newTween(doc, "x", NaN, $rect.x, $duration, $easing, $useSeconds);
					if($position) newTween(doc, "y", NaN, $rect.y, $duration, $easing, $useSeconds);
					if(i == 1)_addCallbacks(tween, $callback);
				}
			}
			else
			// reset
			{
				var j : int = 0;
				for each (var doc2 : DisplayObjectContainer in $objects) {
					j++;
					tween = newTween(doc2, "scaleY", NaN, 1, $duration, $easing, $useSeconds);
					newTween(doc2, "scaleX", NaN, 1, $duration, $easing, $useSeconds);
					newTween(doc2, "x", NaN, 0, $duration, $easing, $useSeconds);
					newTween(doc2, "y", NaN, 0, $duration, $easing, $useSeconds);
					if(j == 1)_addCallbacks(tween, $callback);
				}
			}
		}

		/**
		 * Sets the scale of an Array of objects based on either a Rectangle object, or a single number (treated as both
		 * dimensions of a square), and optionally sets the position as well (default).  If null is passed in, it will
		 * reset the scale (X and Y) for the objects to 1 or %100.
		 *
		 * @param $objects  Array - the objects to set the scale of.
		 * @param $rect     Untyped - can be either a Rectangle or a number defining both dimensions of a square.  If
		 *                      'null' is passed, it will reset the scale (X and Y) for the objects to 1 or %100.
		 * @param $position Boolean - true, default, sets the position as well (if the value of $rect is aRectangle).
		 */
		public function setRect($objects : Array, $rect : *, $position : Boolean = true) : void {
			if($rect) {
				if($rect is Rectangle) {
					for each (var o : Object in $objects) {
						o.width = $rect.width;
						o.height = $rect.height;
						if($position)o.x = $rect.x;
						if($position)o.y = $rect.y;
					}
				}
				else if($rect is Number) {
					for each (var o2 : Object in $objects) {
						o2.width = o2.width * $rect;
						o2.height = o2.height * $rect;
					}
				}
			}
			else
			// reset
			{
				for each (var o3 : Object in $objects) {
					o3.scaleX = 1;
					o3.scaleY = 1;
					if($position) o3.x = 0;
					if($position) o3.y = 0;
				}
			}
		}

		/**
		 * Takes an array of objects and sets their visibility to false.
		 *
		 * @param rest  Array - the objects to hide
		 */
		public function hide(...rest) : void {
			for each (var o : Object in rest) {
				o.visible = false;
			}
		}

		/**
		 * Takes an array of objects and sets their visibility to true.  Optionally sets the alpha value as well.
		 *
		 * @param $objects   Array - the objects to hide
		 * @param $alpha     Number - optional - the alpha value to set on the objects
		 */
		public function show($objects : Array, $alpha : Number = 1) : void {
			for each (var o : Object in $objects) {
				o.visible = true;
				if($alpha) o.alpha = $alpha;
			}
		}


		// --- HELPER METHODS --- //

		/**
		 * Adds the callbacks for MOTION_CHANGE and MOTION_FINISH
		 *
		 * @param $tween                    Tween - the tween to add the callbacks for
		 * @param $motionFinishCallback     Function - the MOTION_FINISH callback to add to the Tween
		 * @param $motionChangeCallback     Function - the MOTION_CHANGE callback to add to the Tween
		 */
		private function _addCallbacks($tween : Tween, $motionFinishCallback : Function = null, $motionChangeCallback : Function = null) : void {
			if($tween) {
				$tween.addEventListener(TweenEvent.MOTION_FINISH, ($motionFinishCallback != null) ? $motionFinishCallback : _onTweenComplete, false, 0, true);
				if(manageFramerate) {
					$tween.addEventListener(TweenEvent.MOTION_FINISH, _manageFrameRate_onTweenStop, false, 0, true);
					$tween.addEventListener(TweenEvent.MOTION_START, _manageFrameRate_onTweenStart, false, 0, true);
					$tween.addEventListener(TweenEvent.MOTION_STOP, _manageFrameRate_onTweenStop, false, 0, true);
				}
				if($motionChangeCallback != null) $tween.addEventListener(TweenEvent.MOTION_CHANGE, $motionChangeCallback);
			}
		}

		/**
		 * Handler used for setting the framerate to rest when all the tweens are complete.
		 */
		private function _manageFrameRate_onTweenStop(event : TweenEvent) : void {
			//trace(this+'_manageFrameRate_onTweenComplete');
			Tween(event.target).removeEventListener(TweenEvent.MOTION_FINISH, _manageFrameRate_onTweenStop);
			Tween(event.target).removeEventListener(TweenEvent.MOTION_STOP, _manageFrameRate_onTweenStop);
			FramerateManager.rest();
		}

		/**
		 * Handler used for setting the framerate to rest when all the tweens are complete.
		 */
		private function _manageFrameRate_onTweenStart(event : TweenEvent) : void {
			//trace(this+'_manageFrameRate_onTweenBegin');
			Tween(event.target).removeEventListener(TweenEvent.MOTION_START, _manageFrameRate_onTweenStart);
			FramerateManager.active();
		}

		/**
		 * Called if a default callback has been specified for the MOTION_FINISH TweenEvent, and not over-ridden in
		 * the initial setting up of the tween.
		 * @param $e TweenEvent
		 */
		private function _onTweenComplete($e : TweenEvent = null) : void {
			if(defaultCallback != null) defaultCallback();
		}

		/**
		 * Used for stopping the tweens on the array of objects per each property before beginning a new tween on the
		 * same properties of the objects.
		 *
		 * @param $objects  Array - the objects to stop the tweens of based on the properties in the $props Array
		 * @param $props    Array - the properties whose for which the tweens must be stopped
		 */
		public function stopTweens($objects : Array, $props : Array) : void {
			var tween : Tween;
			for each (var prop : String in $props) {
				for each (var o : Object in $objects) {
					tween = getTween(o, prop);
					if(tween) {
						tween.stop();
					}
				}
			}
		}

		/**
		 * Returns a Tween registered per object and property in the tweens registry system, otherwise, if not
		 * registered, returns a null Tween.
		 *
		 * @param $object   Object - the object key to check in the property registry (accessed via the $prop key) for
		 *                      the Tween as value
		 * @param $prop     String - the key to access the property tween registry wherin the object is used as key to
		 *                      reference its tween
		 * @return          Tween - the Tween for the $object and $property
		 */
		public function getTween($object : Object, $prop : String) : Tween {
			var tween : Tween;
			var propTweensIndex : Dictionary;
			propTweensIndex = _getPropTweensIndex($prop);
			if(propTweensIndex[$object]) tween = propTweensIndex[$object];
			return tween;
		}

		/**
		 * Registers the Tween ($tween) based on the Object ($object) as key in the property Dictionary.
		 *
		 * @param $object   Object - the object key to register the tween with in the property Dictionary
		 * @param $prop     String - the property for which the Tween Dictionary is retrieved and in which the Tween is
		 *                      registered with the Object ($object) as key
		 * @param $tween    Tween - the Tween to be registered
		 */
		private function _registerTween($object : Object, $prop : String, $tween : Tween) : void {
			var tweensByPropIndex : Dictionary = _getPropTweensIndex($prop);
			tweensByPropIndex[$object] = $tween;
		}


		/**
		 * Returns the Dictionary of Tweens per the property value ($prop), which uses the Object tweened as key for
		 * registering/accessing the Tween
		 *
		 * @param $prop     String - the key for accessing the Dictionary of Tweens for that property
		 * @return          Dictionary - Returns the Dictionary of Tweens per the property value ($prop), which uses the Object tweened as key for
		 *                      registering/accessing the Tween
		 */
		private function _getPropTweensIndex($prop : String) : Dictionary {
			if(!_tweenIndexes)_tweenIndexes = new Dictionary();
			var propIndexTemp : Dictionary;
			if(!_tweenIndexes[$prop]) {
				propIndexTemp = new Dictionary();
				_tweenIndexes[$prop] = propIndexTemp;
			}
			else propIndexTemp = _tweenIndexes[$prop];
			return propIndexTemp;
		}

		/**
		 * Registers and returns a new Tween.
		 *
		 * @param $object       Object - the object which will be tweened, and which serves as key in the Dictionary of
		 *                          tweens per property wherein the Tween is registered for stopping (and other access)
		 *                          by the system.
		 * @param $prop         String - the property to be tweened, which also serves as the key in the main Dictionary
		 *                          which holds the Dictionaries of Tweens, one per each property.
		 * @param $beginValue   Number - the value to begin the Tween.  NaN uses the current value of the property to
		 *                          begin with.
		 * @param $endValue     Number - the end value for the Tween
		 * @param $duration     Number - the duration for the Tween
		 * @param $easing       Function - the easing function to use for the Tween
		 * @param $useSeconds   Untyped - this is untyped and defaults to 'null' which takes on the static default
		 *                          Boolean property, 'useSeconds'.  Otherwise enter the desired Boolean value to
		 *                          over-ride the default
		 * @param $delay        Number - the amount of time (units set by $useSeconds) by which to delay the start of
		 *                          the Tween
		 * @return              Tween - returns the new Tween
		 */
		public function newTween($object : Object, $prop : String, $beginValue : Number = NaN, $endValue : Number = NaN, $duration : Number = NaN, $easing : Function = null, $useSeconds : * = null, $delay : Number = NaN) : Tween {
			if(!$object) {
				trace('Transitions: ERROR object does not exist to tween...');
				return null;
			}
			if(isNaN($duration))$duration = defaultDuration;
			if(isNaN($delay))$delay = defaultDelay;
			if($easing == null)$easing = defaultEasing;
			if($useSeconds == null)$useSeconds = useSeconds;
			stopTweens([$object], [$prop]);
			var tween : Tween = new Tween($object, $prop, $easing, $beginValue, $endValue, $duration, $useSeconds, $delay);
			_registerTween($object, $prop, tween);
			return tween;
		}

		/**
		 * Returns a new Tween for the 'alpha' property of the specified object.  Uses newTween().
		 *
		 * @param $object       Object - the object which will be tweened, and which serves as key in the Dictionary of
		 *                          tweens per property wherein the Tween is registered for stopping (and other access)
		 *                          by the system.
		 * @param $duration     Number - the duration for the Tween
		 * @param $easing       Function - the easing function to use for the Tween
		 * @param $out          Boolean - true returns a Tween for fading out, false returns a Tween for fading in
		 * @param $useSeconds   Untyped - this is untyped and defaults to 'null' which takes on the static default
		 *                          Boolean property, 'useSeconds'.  Otherwise enter the desired Boolean value to
		 *                          over-ride the default
		 * @param $delay        Number - the amount of time (units set by $useSeconds) by which to delay the start of
		 *                          the Tween
		 * @return              Tween - Returns the new alpha Tween
		 */
		public function newFadeTween($object : Object, $duration : Number = NaN, $easing : Function = null, $out : Boolean = true, $useSeconds : * = null, $delay : Number = NaN) : Tween {
			if(!$duration && $duration != 0)$duration = defaultDuration;
			if(isNaN($delay))$delay = defaultDelay;
			if($easing == null)$easing = defaultEasing;
			if($useSeconds == null)$useSeconds = useSeconds;
			return newTween($object, ALPHA, NaN, ($out) ? 0 : 1, $duration, $easing, $useSeconds, $delay);
		}

		/**
		 *
		 * @param $object       Object - the object which will be tweened, and which serves as key in the Dictionary of
		 *                          tweens per property wherein the Tween is registered for stopping (and other access)
		 *                          by the system.
		 * @param $prop         String - the property to be tweened, which also serves as the key in the main Dictionary
		 *                          which holds the Dictionaries of Tweens, one per each property.
		 * @param $color        Number - the color to tint in or whatever
		 * @param $percent      Number - the amount (0 to 1) to tint the color to
		 * @param $duration     Number - the duration for the Tween
		 * @param $easing       Function - the easing function to use for the Tween
		 * @param $useSeconds   Untyped - this is untyped and defaults to 'null' which takes on the static default
		 *                          Boolean property, 'useSeconds'.  Otherwise enter the desired Boolean value to
		 *                          over-ride the default
		 * @param $delay        Number - the amount of time (units set by $useSeconds) by which to delay the start of
		 *                          the Tween
		 * @return              sz.scratch.animation.ColorPercentTween - Returns the new ColorPercentTween
		 */
		public function newColorTween($object : Object, $prop : String, $color : Number, $percent : Number, $duration : Number = NaN, $easing : Function = null, $useSeconds : * = null, $delay : Number = NaN) : ColorPercentTween {
			if(!$duration && $duration != 0)$duration = defaultDuration;
			if(isNaN($delay))$delay = defaultDelay;
			if($easing == null)$easing = defaultEasing;
			if($useSeconds == null)$useSeconds = useSeconds;
			stopTweens([$object], [$prop]);
			var tween : ColorPercentTween = new ColorPercentTween($object, $prop, $easing, NaN, $color, $duration, $useSeconds, 0, $delay, true, $percent);
			_registerTween($object, $prop, tween);
			return tween;
		}

		/**
		 *
		 * @param $object       Object - the object which will be tweened, and which serves as key in the Dictionary of
		 *                          tweens per property wherein the Tween is registered for stopping (and other access)
		 *                          by the system.
		 * @param $blurBegin    BlurFilter - the BlurFilter to begin the BlurFilterTween with
		 * @param $blurEnd      BlurFilter - the BlurFilter to end the BlurFilterTween with
		 * @param $duration     Number - the duration for the BlurFilterTween
		 * @param $easing       Function - the easing function to use for the BlurFilterTween
		 * @param $useSeconds   Untyped - this is untyped and defaults to 'null' which takes on the static default
		 *                          Boolean property, 'useSeconds'.  Otherwise enter the desired Boolean value to
		 *                          over-ride the default
		 * @param $delay        Number - the amount of time (units set by $useSeconds) by which to delay the start of
		 *                          the BlurFilterTween
		 * @return              BlurFilterTween - returns the tween created
		 */
		public function newBlurTween($object : Object, $blurBegin : BlurFilter, $blurEnd : BlurFilter, $duration : Number = NaN, $easing : Function = null, $useSeconds : * = null, $delay : Number = NaN) : BlurFilterTween {
			if(!$duration && $duration != 0)$duration = defaultDuration;
			if(isNaN($delay))$delay = defaultDelay;
			if($easing == null)$easing = defaultEasing;
			if($useSeconds == null)$useSeconds = useSeconds;
			stopTweens([$object], [BLUR]);
			var tween : BlurFilterTween = new BlurFilterTween($object, $easing, $blurBegin, $blurEnd, $duration, $useSeconds, $delay);
			_registerTween($object, BLUR, tween);
			return tween;
		}


		// --- SINGLETON METHODS --- //

		/**
		 *
		 * Instantiates the Transitions primary class
		 */
		public function Transitions() {
			// Should never be called externally, Transitions is a Singleton
			if(__instance)throw new Error(SINGLETON_EXCEPTION);
			_initializeDefaults();
		}

		/**
		 *
		 * explicitly request the singleton instance of the Transitions class
		 */
		public static function getInstance() : Transitions {
			if(__instance)return __instance;
			__instance = new Transitions();
			return __instance;
		}

		/**
		 *
		 * implicitly request the singleton instance of the Transitions class
		 */
		public static function get instance() : Transitions {
			if(__instance)return __instance;
			__instance = new Transitions();
			return __instance;
		}
	}
}
