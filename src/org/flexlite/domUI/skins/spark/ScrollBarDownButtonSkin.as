package org.flexlite.domUI.skins.spark
{
	import org.flexlite.domUI.skins.SparkSkin;
	import org.flexlite.domUI.primitives.Path;
	import org.flexlite.domUI.primitives.Rect;
	import org.flexlite.domUI.primitives.graphic.GradientEntry;
	import org.flexlite.domUI.primitives.graphic.LinearGradient;
	import org.flexlite.domUI.primitives.graphic.RadialGradient;
	import org.flexlite.domUI.primitives.graphic.SolidColor;
	import org.flexlite.domUI.primitives.graphic.SolidColorStroke;
	import org.flexlite.domUI.states.SetProperty;
<<<<<<< HEAD
	import org.flexlite.domUI.states.State;
=======
	import org.flexlite.domUI.states.State;
>>>>>>> f78d49f3fecf49af6a0fd0692d66a604051e89be
	
	/**
	 * 滚动条向下滚动按钮默认皮肤
	 * @author DOM
	 */
	public class ScrollBarDownButtonSkin extends SparkSkin
	{
		//==========================================================================
		//                                定义成员变量
		//==========================================================================
		public var __ScrollBarDownButtonSkin_GradientEntry1:GradientEntry;
		
		public var __ScrollBarDownButtonSkin_GradientEntry2:GradientEntry;
		
		public var __ScrollBarDownButtonSkin_SolidColor1:SolidColor;
		
		public var __ScrollBarDownButtonSkin_SolidColor2:SolidColor;
		
		public var arrow:Path;
		
		public var arrowFill1:GradientEntry;
		
		public var arrowFill2:GradientEntry;
		
		
		//==========================================================================
		//                                定义构造函数
		//==========================================================================
		public function ScrollBarDownButtonSkin()
		{
			super();
			
			this.elementsContent = [_ScrollBarDownButtonSkin_Rect1_i(),_ScrollBarDownButtonSkin_Rect2_i(),_ScrollBarDownButtonSkin_Rect3_i(),arrow_i()];
			this.currentState = "up";
			
			states = [
				new State ({name: "up",
					overrides: [
					]
				})
				,
				new State ({name: "over",
					overrides: [
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_GradientEntry1",
							name:"color",
							value:0xBBBBBB
						})
						,
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_GradientEntry2",
							name:"color",
							value:0x9FA0A1
						})
						,
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_SolidColor2",
							name:"alpha",
							value:0.22
						})
					]
				})
				,
				new State ({name: "down",
					overrides: [
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_SolidColor1",
							name:"color",
							value:0xDEEBFF
						})
						,
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_GradientEntry1",
							name:"color",
							value:0xD6D6D6
						})
						,
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_GradientEntry1",
							name:"alpha",
							value:1
						})
						,
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_GradientEntry2",
							name:"color",
							value:0x888888
						})
						,
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_GradientEntry2",
							name:"alpha",
							value:1
						})
						,
						new SetProperty().initializeFromObject({
							target:"__ScrollBarDownButtonSkin_SolidColor2",
							name:"alpha",
							value:0.22
						})
					]
				})
				,
				new State ({name: "disabled",
					overrides: [
					]
				})
			];
		}
		
		
		//==========================================================================
		//                                定义成员方法
		//==========================================================================
		private function _ScrollBarDownButtonSkin_GradientEntry1_i():GradientEntry
		{
			var temp:GradientEntry = new GradientEntry();
			__ScrollBarDownButtonSkin_GradientEntry1 = temp;
			temp.color = 0xFFFFFF;
			temp.alpha = 0.85;
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_GradientEntry2_i():GradientEntry
		{
			var temp:GradientEntry = new GradientEntry();
			__ScrollBarDownButtonSkin_GradientEntry2 = temp;
			temp.color = 0xE7E7E7;
			temp.alpha = 0.85;
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_LinearGradient1_i():LinearGradient
		{
			var temp:LinearGradient = new LinearGradient();
			temp.entries = [_ScrollBarDownButtonSkin_GradientEntry1_i(),_ScrollBarDownButtonSkin_GradientEntry2_i()];
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_RadialGradient1_i():RadialGradient
		{
			var temp:RadialGradient = new RadialGradient();
			temp.rotation = 90;
			temp.focalPointRatio = 1;
			temp.entries = [arrowFill1_i(),arrowFill2_i()];
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_Rect1_i():Rect
		{
			var temp:Rect = new Rect();
			temp.left = 0;
			temp.right = 0;
			temp.minWidth = 14;
			temp.top = 0;
			temp.bottom = 0;
			temp.minHeight = 17;
			temp.stroke = _ScrollBarDownButtonSkin_SolidColorStroke1_i();
			temp.fill = _ScrollBarDownButtonSkin_SolidColor1_i();
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_Rect2_i():Rect
		{
			var temp:Rect = new Rect();
			temp.left = 1;
			temp.right = 1;
			temp.top = 1;
			temp.bottom = 1;
			temp.fill = _ScrollBarDownButtonSkin_LinearGradient1_i();
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_Rect3_i():Rect
		{
			var temp:Rect = new Rect();
			temp.left = 1;
			temp.top = 1;
			temp.bottom = 1;
			temp.width = 6;
			temp.fill = _ScrollBarDownButtonSkin_SolidColor2_i();
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_SolidColor1_i():SolidColor
		{
			var temp:SolidColor = new SolidColor();
			__ScrollBarDownButtonSkin_SolidColor1 = temp;
			temp.color = 0xF9F9F9;
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_SolidColor2_i():SolidColor
		{
			var temp:SolidColor = new SolidColor();
			__ScrollBarDownButtonSkin_SolidColor2 = temp;
			temp.color = 0xFFFFFF;
			temp.alpha = 0.75;
			return temp;
		}
		
		private function _ScrollBarDownButtonSkin_SolidColorStroke1_i():SolidColorStroke
		{
			var temp:SolidColorStroke = new SolidColorStroke();
			temp.color = 0x686868;
			temp.weight = 1;
			return temp;
		}
		
		private function arrowFill1_i():GradientEntry
		{
			var temp:GradientEntry = new GradientEntry();
			arrowFill1 = temp;
			temp.color = 0;
			temp.alpha = 0.6;
			return temp;
		}
		
		private function arrowFill2_i():GradientEntry
		{
			var temp:GradientEntry = new GradientEntry();
			arrowFill2 = temp;
			temp.color = 0;
			temp.alpha = 0.8;
			return temp;
		}
		
		private function arrow_i():Path
		{
			var temp:Path = new Path();
			arrow = temp;
			temp.horizontalCenter = 0;
			temp.verticalCenter = 0;
			temp.data = "M 3.5 7.0 L 0.0 0.0 L 7.0 0.0 L 3.5 7.0";
			temp.fill = _ScrollBarDownButtonSkin_RadialGradient1_i();
			return temp;
		}
		
	}
}