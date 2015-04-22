package sz.examples.load_progress {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.utils.setTimeout;

	import sz.scratch.animation.Transitions;
	import sz.scratch.test.load.AMockLoader;
	import sz.scratch.test.load.MockLoaderBytes;
	import sz.scratch.test.load.MockLoaderPercent;
	import sz.scratch.ui.CircleProgressDisplay;
	import sz.scratch.utils.Random;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/3/11
	 *
	 */
	public class app_LoaderProgressGroup extends MovieClip {
		private var _circleProgressDisplay : CircleProgressDisplay;
		private var _loaderObjects : Array;
		private const NUM_LOADER_OBJECTS : Number = 12;

		public function app_LoaderProgressGroup() {
			// style and setup circle progress animation
			_circleProgressDisplay = new CircleProgressDisplay(40, 3, 0x00FF00, 1, 0x99FF99, .3);
			_circleProgressDisplay.x = _circleProgressDisplay.y = stage.stageWidth * .5;
			_circleProgressDisplay.mouseEnabled = false;
			_circleProgressDisplay.anim.bkgThicknessOffset = 5;
			_circleProgressDisplay.anim.progressAnimation.filters = [new BlurFilter(2, 2), new GlowFilter(0x00FF00, 1, 15, 15, 1, 1, false, false)];
			_circleProgressDisplay.anim.bkg.filters = [new BlurFilter()];
			addChild(_circleProgressDisplay);
			_circleProgressDisplay.anim.hideTransition = _animHideHandler;
			_circleProgressDisplay.anim.indeterminate = true;

			// set up mock loader array
			_loaderObjects=[];
			AMockLoader.SPEED = 2.2134;
			for(var i : int = 0; i < NUM_LOADER_OBJECTS; i++) {
				if(Random.bool()) _loaderObjects.push(new MockLoaderBytes());
				else _loaderObjects.push(new MockLoaderPercent());
			}

			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			_circleProgressDisplay.logic.indeterminate = true;
			setTimeout(_startLoading, 2000);
		}

		private function _startLoading() : void {
			for each (var ml : AMockLoader in _loaderObjects){
				ml.load();
			}
			_circleProgressDisplay.logic.loadObject = _loaderObjects;
		}

		private function _onMouseMove(event : MouseEvent) : void {
			_circleProgressDisplay.anim.thickness = Math.max(3, Math.abs(this.mouseX - stage.stageWidth));
			_circleProgressDisplay.anim.radius = Math.min(50, Math.max(30, Math.abs(this.mouseY - stage.stageHeight)));
		}

		private function _animHideHandler() : void {
			Transitions.instance.fadeout([_circleProgressDisplay]);
		}
	}
}
