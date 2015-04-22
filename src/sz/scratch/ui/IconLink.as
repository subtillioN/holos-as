package com.mazda.mazda5.main.ui
{
	import com.xcore.ui.Image;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * DownloadButton DESCRIPTION
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Jun 18, 2010
	 *
	 */
	public class IconLink extends Link
	{
		private var _icon : Image ;
		private var _bkg : Sprite ;
		public static const ICON_LOADED : String = Image.LOADING_COMPLETE;
		public function IconLink()
		{
			_icon = new Image();
			_icon.addEventListener(Image.LOADING_COMPLETE, _onIconLoaded);
			visible = false;
			_bkg = new Sprite();
			addChild(_icon);
		}

		private function _onIconLoaded(...rest) : void
		{
			dispatchEvent(new Event(ICON_LOADED));
		}

		public function set icon($icon : String):void
		{
			_icon.load($icon);
		}
	}
}