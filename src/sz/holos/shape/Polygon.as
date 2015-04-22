package sz.holos.shape {
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 *
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/23/11
	 *
	 */
	public class Polygon extends MovieClip{
		public function Polygon() {

			import fl.controls.RadioButtonGroup;

			var vecPoints : Vector.<Sprite> = new Vector.<Sprite>();

			var spBoard : Sprite = new Sprite();
			spBoard.graphics.lineStyle(0, 2);
			spBoard.graphics.beginFill(0xEEEEEE);
			spBoard.graphics.drawRect(-160, -160, 320, 320);
			spBoard.graphics.endFill();
			spBoard.x = 180;
			spBoard.y = 200;
			addChild(spBoard);

			var shLines : Shape = new Shape();
			spBoard.addChild(shLines);

			var spMoving : Sprite;
			var vecWind : Vector.<String> = Vector.<String>(["evenOdd","nonZero"]);

			var rbgWind : RadioButtonGroup = rbEvenOdd.group;

			nsPoints.addEventListener(Event.CHANGE, setupPoints);

			function setupPoints(evt : Event) : void {
				var i : int;
				var n : int = nsPoints.value;
				for(i = 0; i < vecPoints.length; i++) {
					vecPoints[i].removeEventListener(MouseEvent.MOUSE_DOWN, startPointDrag);
					spBoard.removeChild(vecPoints[i]);
				}
				setup(n);
			}

			function setup(np : int) : void {
				var i : int;

				vecPoints = new Vector.<Sprite>(np);

				for(i = 0; i < np; i++) {
					vecPoints[i] = new Sprite();
					vecPoints[i].graphics.lineStyle(1, 0);
					vecPoints[i].graphics.beginFill(0xCC0000);
					vecPoints[i].graphics.drawEllipse(-8, -8, 16, 16);
					vecPoints[i].graphics.endFill();
					spBoard.addChild(vecPoints[i]);
					vecPoints[i].addEventListener(MouseEvent.MOUSE_DOWN, startPointDrag);
					vecPoints[i].x = 130 * Math.cos(2 * Math.PI * i / np);
					vecPoints[i].y = 130 * Math.sin(2 * Math.PI * i / np);
				}
				drawLines();
			}

			function startPointDrag(mevt : MouseEvent) : void {
				spMoving = Sprite(mevt.currentTarget);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, movingPoint);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopPointDrag);
			}

			function movingPoint(mevt : MouseEvent) : void {
				spMoving.x = goodX(spBoard.mouseX);
				spMoving.y = goodY(spBoard.mouseY);
				drawLines();
				mevt.updateAfterEvent();
			}

			function stopPointDrag(mevt : MouseEvent) : void {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingPoint);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stopPointDrag);
			}

			function drawLines() : void {
				var i : int;
				var n : int = vecPoints.length;
				var vecCmds : Vector.<int> = new Vector.<int>();
				var vecCoords : Vector.<Number> = new Vector.<Number>();

				for(i = 0; i < n; i++) {
					vecCmds[i] = 2;
					vecCoords[2 * i] = vecPoints[i].x;
					vecCoords[2 * i + 1] = vecPoints[i].y;
				}
				vecCmds[n] = 2;
				vecCoords[2 * n] = vecPoints[0].x;
				vecCoords[2 * n + 1] = vecPoints[0].y;
				vecCmds[0] = 1;
				shLines.graphics.clear();
				shLines.graphics.lineStyle(1, 0);
				shLines.graphics.beginFill(0xFF0000);
				shLines.graphics.drawPath(vecCmds, vecCoords, vecWind[rbgWind.selectedData]);
				shLines.graphics.endFill();
			}

			rbgWind.addEventListener(Event.CHANGE, windChange);

			function windChange(evt : Event) : void {
				drawLines();
			}

			function goodX(nx : Number) : Number {
				if(nx < -160) {
					return -160;
				}
				if(nx > 160) {
					return 160;
				}
				return nx;
			}

			function goodY(ny : Number) : Number {
				if(ny < -160) {
					return -160;
				}
				if(ny > 160) {
					return 160;
				}
				return ny;
			}

			setup(3);

		}

	}

}