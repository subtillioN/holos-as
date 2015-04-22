package sz.scratch.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * AlphaImage facilitates the use of alpha channels with image types
	 * that do not otherwise support them (namely jpeg).  It takes a
	 * bitmap image and applies the supplied bitmap gray-scale as the alpha
	 * channel.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Feb 3, 2010
	 *
	 */

	public class AlphaImage extends Sprite
	{
		/**
		 * Constructor, runs setImage() if the optional $image parameter is supplied
		 *
		 * @param $image    Bitmap - the main or color image
		 * @param $alpha    Bitmap - the gray-scale image to be applied as alpha
		 */
		public function AlphaImage($image : Bitmap = null, $alpha : Bitmap = null) : void
		{
			if($image) setImage($image, $alpha);
		}

		/**
		 * Applies the $alpha Bitmap as alpha channel to the $image Bitmap
		 * 
		 * @param $image    Bitmap - the main or color image
		 * @param $alpha    Bitmap - the gray-scale image to be applied as alpha
		 */
		public function setImage($image : Bitmap, $alpha : Bitmap = null) : void
		{
			if($alpha)
			{
				var alphaBMD : BitmapData = $alpha.bitmapData;
				var imageBMD : BitmapData = $image.bitmapData;
				var rect : Rectangle = imageBMD.rect;
				var newBMD : BitmapData = new BitmapData(rect.width, rect.height, true, 0x000000);
				newBMD.draw(imageBMD, null, null, null, null, false);
				imageBMD.dispose();
				newBMD.copyChannel(alphaBMD, newBMD.rect, new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
				var bm : Bitmap = new Bitmap(newBMD);
				addChild(bm);
			}
			else addChild($image);
		}

		override public function toString() : String
		{
			return '[AlphaImage]';
		}
	}
}
