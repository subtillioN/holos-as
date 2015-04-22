package sz.scratch.drawing {

	import flash.display.*;

	import sz.holos.shape.drawArcShape;

	import sz.holos.shape.makeArcPoints;

	/**
	 * Draws an outlined or stroked circle shape in the target sprite graphics layer
	 */
	public class CircleOutlined {
		public static function draw($target : Sprite, $sx : Number, $sy : Number, $innerRadius : Number, $outerRadius : Number) : void {
			var outerPoints : Array = [];
			var innerPoints : Array = [];
			outerPoints = makeArcPoints($sx, $sy, $outerRadius, 360);
			innerPoints = makeArcPoints($sx, $sy, $innerRadius, 360, -1);
			drawArcShape($target, outerPoints);
			drawArcShape($target, innerPoints);
		}
	}
}