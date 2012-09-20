package org.flexlite.domUI.utils
{
	
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	public final class MatrixUtil
	{
		
		private static const RADIANS_PER_DEGREES:Number = Math.PI / 180;
		public static var SOLUTION_TOLERANCE:Number = 0.1;
		public static var MIN_MAX_TOLERANCE:Number = 0.1;
		
		private static var staticPoint:Point = new Point();
		private static var fakeDollarParent:QName;
		private static var uiComponentClass:Class;
		private static var uiMovieClipClass:Class;
		private static var usesMarshalling:Object;
		private static var lastModuleFactory:Object;
		private static var computedMatrixProperty:QName;
		private static var $transformProperty:QName;
		public static function clampRotation(value:Number):Number
		{
			
			if (value > 180 || value < -180)
			{
				value = value % 360;
				
				if (value > 180)
					value = value - 360;
				else if (value < -180)
					value = value + 360;
			}
			return value;
		}
		public static function transformPoint(x:Number, y:Number, m:Matrix):Point
		{
			if (!m)
			{
				staticPoint.x = x;
				staticPoint.y = y;
				return staticPoint;
			}
			
			staticPoint.x = m.a * x + m.c * y + m.tx;
			staticPoint.y = m.b * x + m.d * y + m.ty;
			return staticPoint;
		}
		
		public static function composeMatrix(x:Number = 0,
											 y:Number = 0,
											 scaleX:Number = 1,
											 scaleY:Number = 1,
											 rotation:Number = 0,
											 transformX:Number = 0,
											 transformY:Number = 0):Matrix
		{
			var m:Matrix = new Matrix();
			m.translate(-transformX, -transformY);
			m.scale(scaleX, scaleY);
			if (rotation != 0) 
				m.rotate(rotation / 180 * Math.PI);
			m.translate(transformX + x, transformY + y);
			return m;
		}
		public static function decomposeMatrix(components:Vector.<Number>,
											   matrix:Matrix,
											   transformX:Number = 0,
											   transformY:Number = 0):void
		{
			var Ux:Number;
			var Uy:Number;
			var Vx:Number;
			var Vy:Number;
			
			Ux = matrix.a;
			Uy = matrix.b;
			components[3] = Math.sqrt(Ux*Ux + Uy*Uy);
			
			Vx = matrix.c;
			Vy = matrix.d;
			components[4] = Math.sqrt(Vx*Vx + Vy*Vy );
			var determinant:Number = Ux*Vy - Uy*Vx;
			if (determinant < 0) 
			{
				components[4] = -(components[4]);
				Vx = -Vx;
				Vy = -Vy;
			}
			
			components[2] = Math.atan2( Uy, Ux ) / RADIANS_PER_DEGREES;
			
			if (transformX != 0 || transformY != 0)     
			{
				var postTransformCenter:Point = matrix.transformPoint(new Point(transformX,transformY));
				components[0] = postTransformCenter.x - transformX;
				components[1] = postTransformCenter.y - transformY;
			}
			else
			{
				components[0] = matrix.tx;
				components[1] = matrix.ty;
			}
		}
		public static function rectUnion(left:Number, top:Number, right:Number, bottom:Number,
										 rect:Rectangle):Rectangle
		{
			if (!rect)
				return new Rectangle(left, top, right - left, bottom - top);
			
			var minX:Number = Math.min(rect.left,   left);
			var minY:Number = Math.min(rect.top,    top);
			var maxX:Number = Math.max(rect.right,  right);
			var maxY:Number = Math.max(rect.bottom, bottom);
			
			rect.x      = minX;
			rect.y      = minY;
			rect.width  = maxX - minX;
			rect.height = maxY - minY;
			return rect;
		}
		public static function getEllipseBoundingBox(cx:Number, cy:Number,
													 rx:Number, ry:Number,
													 matrix:Matrix,
													 rect:Rectangle = null):Rectangle
		{
			var a:Number = matrix.a;
			var b:Number = matrix.b;
			var c:Number = matrix.c;
			var d:Number = matrix.d;
			if (rx == 0 && ry == 0)
			{
				var pt:Point = new Point(cx, cy);
				pt = matrix.transformPoint(pt);
				return rectUnion(pt.x, pt.y, pt.x, pt.y, rect);
			}
			
			var t:Number;
			var t1:Number;
			
			if (a * rx == 0)
				t = Math.PI / 2;
			else
				t = Math.atan((c * ry) / (a * rx));
			
			if (b * rx == 0)
				t1 = Math.PI / 2;
			else
				t1 = Math.atan((d * ry) / (b * rx));            
			
			var x1:Number = a * Math.cos(t) * rx + c * Math.sin(t) * ry;             
			var x2:Number = -x1;
			x1 += a * cx + c * cy + matrix.tx;
			x2 += a * cx + c * cy + matrix.tx;
			
			var y1:Number = b * Math.cos(t1) * rx + d * Math.sin(t1) * ry;             
			var y2:Number = -y1;
			y1 += b * cx + d * cy + matrix.ty;
			y2 += b * cx + d * cy + matrix.ty;
			
			return rectUnion(Math.min(x1, x2), Math.min(y1, y2), Math.max(x1, x2), Math.max(y1, y2), rect); 
		}
		static public function getQBezierSegmentBBox(x0:Number, y0:Number,
													 x1:Number, y1:Number,
													 x2:Number, y2:Number,
													 sx:Number, sy:Number,
													 matrix:Matrix,
													 rect:Rectangle):Rectangle
		{
			var pt:Point;
			pt = MatrixUtil.transformPoint(x0 * sx, y0 * sy, matrix);
			x0 = pt.x;
			y0 = pt.y;
			
			pt = MatrixUtil.transformPoint(x1 * sx, y1 * sy, matrix);
			x1 = pt.x;
			y1 = pt.y;
			
			pt = MatrixUtil.transformPoint(x2 * sx, y2 * sy, matrix);
			x2 = pt.x;
			y2 = pt.y;
			
			var minX:Number = Math.min(x0, x2);
			var maxX:Number = Math.max(x0, x2);
			
			var minY:Number = Math.min(y0, y2);
			var maxY:Number = Math.max(y0, y2);
			
			var txDiv:Number = x0 - 2 * x1 + x2;
			if (txDiv != 0)
			{
				var tx:Number = (x0 - x1) / txDiv;
				if (0 <= tx && tx <= 1)
				{
					var x:Number = (1 - tx) * (1 - tx) * x0 + 2 * tx * (1 - tx) * x1 + tx * tx * x2;
					minX = Math.min(x, minX);
					maxX = Math.max(x, maxX);
				}  
			}
			
			var tyDiv:Number = y0 - 2 * y1 + y2;
			if (tyDiv != 0)
			{
				var ty:Number = (y0 - y1) / tyDiv;
				if (0 <= ty && ty <= 1)
				{
					var y:Number = (1 - ty) * (1 - ty) * y0 + 2 * ty * (1 - ty) * y1 + ty * ty * y2;
					minY = Math.min(y, minY);
					maxY = Math.max(y, maxY);
				}  
			}
			
			return rectUnion(minX, minY, maxX, maxY, rect);
		}
		public static function transformSize(width:Number, height:Number, matrix:Matrix):Point
		{
			const a:Number = matrix.a;
			const b:Number = matrix.b;
			const c:Number = matrix.c;
			const d:Number = matrix.d;
			var x1:Number = 0;
			var y1:Number = 0;
			var x2:Number = width * a;
			var y2:Number = width * b;
			var x3:Number = height * c;
			var y3:Number = height * d;
			var x4:Number = x2 + x3;
			var y4:Number = y2 + y3;
			
			var minX:Number = Math.min(Math.min(x1, x2), Math.min(x3, x4));
			var maxX:Number = Math.max(Math.max(x1, x2), Math.max(x3, x4));
			var minY:Number = Math.min(Math.min(y1, y2), Math.min(y3, y4));
			var maxY:Number = Math.max(Math.max(y1, y2), Math.max(y3, y4));
			
			staticPoint.x = maxX - minX;
			staticPoint.y = maxY - minY;
			return staticPoint;
		}
		public static function transformBounds(width:Number, height:Number, matrix:Matrix, topLeft:Point = null):Point
		{
			const a:Number = matrix.a;
			const b:Number = matrix.b;
			const c:Number = matrix.c;
			const d:Number = matrix.d;
			var x1:Number = 0;
			var y1:Number = 0;
			var x2:Number = width * a;
			var y2:Number = width * b;
			var x3:Number = height * c;
			var y3:Number = height * d;
			var x4:Number = x2 + x3;
			var y4:Number = y2 + y3;
			
			var minX:Number = Math.min(Math.min(x1, x2), Math.min(x3, x4));
			var maxX:Number = Math.max(Math.max(x1, x2), Math.max(x3, x4));
			var minY:Number = Math.min(Math.min(y1, y2), Math.min(y3, y4));
			var maxY:Number = Math.max(Math.max(y1, y2), Math.max(y3, y4));
			
			staticPoint.x = maxX - minX;
			staticPoint.y = maxY - minY;
			
			if (topLeft)
			{
				const tx:Number = matrix.tx;
				const ty:Number = matrix.ty;
				const x:Number = topLeft.x;
				const y:Number = topLeft.y;
				
				topLeft.x = minX + a * x + b * y + tx;
				topLeft.y = minY + c * x + d * y + ty;
			}
			return staticPoint;
		}
		public static function projectBounds(bounds:Rectangle,
											 matrix:Matrix3D, 
											 projection:PerspectiveProjection):Rectangle
		{
			
			var centerX:Number = projection.projectionCenter.x;
			var centerY:Number = projection.projectionCenter.y;
			matrix.appendTranslation(-centerX, -centerY, projection.focalLength);
			matrix.append(projection.toMatrix3D());
			var pt1:Vector3D = new Vector3D(bounds.left, bounds.top, 0); 
			var pt2:Vector3D = new Vector3D(bounds.right, bounds.top, 0) 
			var pt3:Vector3D = new Vector3D(bounds.left, bounds.bottom, 0);
			var pt4:Vector3D = new Vector3D(bounds.right, bounds.bottom, 0);
			pt1 = Utils3D.projectVector(matrix, pt1);
			pt2 = Utils3D.projectVector(matrix, pt2);
			pt3 = Utils3D.projectVector(matrix, pt3);
			pt4 = Utils3D.projectVector(matrix, pt4);
			var maxX:Number = Math.max(Math.max(pt1.x, pt2.x), Math.max(pt3.x, pt4.x));
			var minX:Number = Math.min(Math.min(pt1.x, pt2.x), Math.min(pt3.x, pt4.x));
			var maxY:Number = Math.max(Math.max(pt1.y, pt2.y), Math.max(pt3.y, pt4.y));
			var minY:Number = Math.min(Math.min(pt1.y, pt2.y), Math.min(pt3.y, pt4.y));
			bounds.x = minX + centerX;
			bounds.y = minY + centerY;
			bounds.width = maxX - minX;
			bounds.height = maxY - minY;
			return bounds;
		}
		public static function isDeltaIdentity(matrix:Matrix):Boolean
		{
			return (matrix.a == 1 && matrix.d == 1 &&
				matrix.b == 0 && matrix.c == 0);
		}
		public static function fitBounds(width:Number, height:Number, matrix:Matrix,
										 explicitWidth:Number, explicitHeight:Number,
										 preferredWidth:Number, preferredHeight:Number,
										 minWidth:Number, minHeight:Number,
										 maxWidth:Number, maxHeight:Number):Point
		{
			if (isNaN(width) && isNaN(height))
				return new Point(preferredWidth, preferredHeight);
			const newMinWidth:Number = (minWidth < MIN_MAX_TOLERANCE) ? 0 : minWidth - MIN_MAX_TOLERANCE;
			const newMinHeight:Number = (minHeight < MIN_MAX_TOLERANCE) ? 0 : minHeight - MIN_MAX_TOLERANCE;
			const newMaxWidth:Number = maxWidth + MIN_MAX_TOLERANCE;
			const newMaxHeight:Number = maxHeight + MIN_MAX_TOLERANCE;
			
			var actualSize:Point;
			
			if (!isNaN(width) && !isNaN(height))
			{
				actualSize = calcUBoundsToFitTBounds(width, height, matrix,
					newMinWidth, newMinHeight, 
					newMaxWidth, newMaxHeight); 
				if (!actualSize)
				{
					var actualSize1:Point;
					actualSize1 = fitTBoundsWidth(width, matrix,
						explicitWidth, explicitHeight,
						preferredWidth, preferredHeight,
						newMinWidth, newMinHeight, 
						newMaxWidth, newMaxHeight);
					if (actualSize1)
					{
						var fitHeight:Number = transformSize(actualSize1.x, actualSize1.y, matrix).y;
						if (fitHeight - SOLUTION_TOLERANCE > height)
							actualSize1 = null;
					}
					
					var actualSize2:Point
					actualSize2 = fitTBoundsHeight(height, matrix,
						explicitWidth, explicitHeight,
						preferredWidth, preferredHeight,
						newMinWidth, newMinHeight, 
						newMaxWidth, newMaxHeight); 
					if (actualSize2)
					{
						var fitWidth:Number = transformSize(actualSize2.x, actualSize2.y, matrix).x;
						if (fitWidth - SOLUTION_TOLERANCE > width)
							actualSize2 = null;
					}
					
					if (actualSize1 && actualSize2)
					{
						
						actualSize = ((actualSize1.x * actualSize1.y) > (actualSize2.x * actualSize2.y)) ? actualSize1 : actualSize2;
					}
					else if (actualSize1)
					{
						actualSize = actualSize1;
					}
					else
					{
						actualSize = actualSize2;
					}
				}
				return actualSize;
			}
			else if (!isNaN(width))
			{
				return fitTBoundsWidth(width, matrix,
					explicitWidth, explicitHeight,
					preferredWidth, preferredHeight,
					newMinWidth, newMinHeight, 
					newMaxWidth, newMaxHeight); 
			}
			else
			{
				return fitTBoundsHeight(height, matrix,
					explicitWidth, explicitHeight,
					preferredWidth, preferredHeight,
					newMinWidth, newMinHeight, 
					newMaxWidth, newMaxHeight); 
			}
		}
		private static function fitTBoundsWidth(width:Number, matrix:Matrix,
												explicitWidth:Number, explicitHeight:Number,
												preferredWidth:Number, preferredHeight:Number,
												minWidth:Number, minHeight:Number,
												maxWidth:Number, maxHeight:Number):Point
		{
			var actualSize:Point;
			if (!isNaN(explicitWidth) && isNaN(explicitHeight))
			{
				actualSize = calcUBoundsToFitTBoundsWidth(width, matrix,
					explicitWidth, preferredHeight, 
					explicitWidth, minHeight, 
					explicitWidth, maxHeight);
				
				if (actualSize)
					return actualSize;
			}
			else if (isNaN(explicitWidth) && !isNaN(explicitHeight))
			{
				actualSize = calcUBoundsToFitTBoundsWidth(width, matrix,
					preferredWidth, explicitHeight, 
					minWidth, explicitHeight, 
					maxWidth, explicitHeight);
				if (actualSize)
					return actualSize;
			}
			actualSize = calcUBoundsToFitTBoundsWidth(width, matrix,
				preferredWidth, preferredHeight, 
				minWidth, minHeight, 
				maxWidth, maxHeight);
			
			return actualSize;
		}
		private static function fitTBoundsHeight(height:Number, matrix:Matrix,
												 explicitWidth:Number, explicitHeight:Number,
												 preferredWidth:Number, preferredHeight:Number,
												 minWidth:Number, minHeight:Number,
												 maxWidth:Number, maxHeight:Number):Point
		{
			var actualSize:Point;
			if (!isNaN(explicitWidth) && isNaN(explicitHeight))
			{
				actualSize = calcUBoundsToFitTBoundsHeight(height, matrix,
					explicitWidth, preferredHeight, 
					explicitWidth, minHeight, 
					explicitWidth, maxHeight);
				
				if (actualSize)
					return actualSize;
			}
			else if (isNaN(explicitWidth) && !isNaN(explicitHeight))
			{
				actualSize = calcUBoundsToFitTBoundsHeight(height, matrix,
					preferredWidth, explicitHeight, 
					minWidth, explicitHeight, 
					maxWidth, explicitHeight);
				if (actualSize)
					return actualSize;
			}
			actualSize = calcUBoundsToFitTBoundsHeight(height, matrix,
				preferredWidth, preferredHeight, 
				minWidth, minHeight, 
				maxWidth, maxHeight);
			
			return actualSize;
		}
		static public function calcUBoundsToFitTBoundsHeight(h:Number,
															 matrix:Matrix,
															 preferredX:Number,
															 preferredY:Number,
															 minX:Number,
															 minY:Number,
															 maxX:Number, 
															 maxY:Number):Point
		{
			var b:Number = matrix.b;
			var d:Number = matrix.d;
			if (-1.0e-9 < b && b < +1.0e-9)
				b = 0;
			if (-1.0e-9 < d && d < +1.0e-9)
				d = 0;
			
			if (b == 0 && d == 0)
				return null; 
			if (b == 0 && d == 0)
				return null; 
			
			if (b == 0)
				return new Point( preferredX, h / Math.abs(d) );               
			else if (d == 0)
				return new Point( h / Math.abs(b), preferredY );    
			
			const d1:Number = (b*d >= 0) ? d : -d;
			var s:Point;
			var x:Number;
			var y:Number;
			
			if (d1 != 0 && preferredX > 0)
			{
				const invD1:Number = 1 / d1;
				preferredX = Math.max(minX, Math.min(maxX, preferredX));
				x = preferredX;
				y = (h - b * x) * invD1;
				if (minY <= y && y <= maxY &&
					b * x + d1 * y >= 0 ) 
				{
					s = new Point(x, y);
				}
				y = (-h - b * x) * invD1;
				if (minY <= y && y <= maxY &&
					b * x + d1 * y < 0 ) 
				{
					
					if (!s || transformSize(s.x, s.y, matrix).x > transformSize(x, y, matrix).x)
						s = new Point(x, y);
				}
			}
			
			if (b != 0 && preferredY > 0)
			{
				const invB:Number = 1 / b;
				preferredY = Math.max(minY, Math.min(maxY, preferredY));
				y = preferredY;
				x = ( h - d1 * y ) * invB;
				if (minX <= x && x <= maxX &&
					b * x + d1 * y >= 0) 
				{
					
					if (!s || transformSize(s.x, s.y, matrix).x > transformSize(x, y, matrix).x)
						s = new Point(x, y);
				}
				x = ( -h - d1 * y ) * invB;
				if (minX <= x && x <= maxX &&
					b * x + d1 * y < 0) 
				{
					
					if (!s || transformSize(s.x, s.y, matrix).x > transformSize(x, y, matrix).x)
						s = new Point(x, y);
				}
			}
			if (s)
				return s;
			const a:Number = matrix.a;
			const c:Number = matrix.c;
			const c1:Number = ( a*c >= 0 ) ? c : -c;
			return solveEquation(b, d1, h, minX, minY, maxX, maxY, a, c1);
		}
		static public function calcUBoundsToFitTBoundsWidth(w:Number,
															matrix:Matrix,
															preferredX:Number,
															preferredY:Number,
															minX:Number,
															minY:Number,
															maxX:Number,
															maxY:Number):Point
		{
			var a:Number = matrix.a;
			var c:Number = matrix.c;
			if (-1.0e-9 < a && a < +1.0e-9)
				a = 0;
			if (-1.0e-9 < c && c < +1.0e-9)
				c = 0;
			if (a == 0 && c == 0)
				return null; 
			
			if (a == 0)
				return new Point( preferredX, w / Math.abs(c) );               
			else if (c == 0)
				return new Point( w / Math.abs(a), preferredY );    
			
			const c1:Number = ( a*c >= 0 ) ? c : -c;
			var s:Point;
			var x:Number;
			var y:Number;
			
			if (c1 != 0 && preferredX > 0)
			{
				const invC1:Number = 1 / c1;
				preferredX = Math.max(minX, Math.min(maxX, preferredX));
				x = preferredX;
				y = (w - a * x) * invC1;
				if (minY <= y && y <= maxY &&
					a * x + c1 * y >= 0 ) 
				{
					s = new Point(x, y);        
				}
				y = (-w - a * x) * invC1;
				if (minY <= y && y <= maxY &&
					a * x + c1 * y < 0 ) 
				{
					
					if (!s || transformSize(s.x, s.y, matrix).y > transformSize(x, y, matrix).y)
						s = new Point(x, y);
				}
			}
			
			if (a != 0 && preferredY > 0)
			{
				const invA:Number = 1 / a;
				preferredY = Math.max(minY, Math.min(maxY, preferredY));
				y = preferredY;
				x = (w - c1 * y ) * invA;
				if (minX <= x && x <= maxX &&
					a * x + c1 * y >= 0) 
				{
					
					if (!s || transformSize(s.x, s.y, matrix).y > transformSize(x, y, matrix).y)
						s = new Point(x, y);
				}
				x = (-w - c1 * y ) * invA;
				if (minX <= x && x <= maxX &&
					a * x + c1 * y < 0) 
				{
					
					if (!s || transformSize(s.x, s.y, matrix).y > transformSize(x, y, matrix).y)
						s = new Point(x, y);
				}
			}
			if (s)
				return s;
			const b:Number = matrix.b;
			const d:Number = matrix.d;
			const d1:Number = (b*d >= 0) ? d : -d;
			return solveEquation(a, c1, w, minX, minY, maxX, maxY, b, d1);
		}
		static private function solveEquation(a:Number,
											  c:Number,
											  w:Number,
											  minX:Number,
											  minY:Number, 
											  maxX:Number, 
											  maxY:Number, 
											  b:Number, 
											  d:Number):Point
		{
			if (a == 0 || c == 0)
				return null; 
			var x:Number;
			var y:Number;
			var s:Point;
			var A:Number = (w - minX * a) / c;              
			var B:Number = (w - maxX * a) / c;              
			var rangeMinY:Number = Math.max(minY, Math.min(A, B));
			var rangeMaxY:Number = Math.min(maxY, Math.max(A, B));
			const det:Number = (b * c - a * d);
			if (rangeMinY <= rangeMaxY)
			{
				if (Math.abs(det) < 1.0e-9)
				{
					
					y = w / ( a + c );
				}
				else
				{
					y = b * w / det;
				}
				y = Math.max(rangeMinY, Math.min(y, rangeMaxY));
				
				x = (w - c * y) / a;
				return new Point(x, y);
			}
			A = -(minX * a + w) / c;
			B = -(maxX * a + w) / c;
			rangeMinY = Math.max(minY, Math.min(A, B));
			rangeMaxY = Math.min(maxY, Math.max(A, B));
			if (rangeMinY <= rangeMaxY)
			{
				if (Math.abs(det) < 1.0e-9)
				{
					
					y = -w / ( a + c );
				}
				else
				{
					y = -b * w / det;
				}
				y = Math.max(rangeMinY, Math.min(y, rangeMaxY));
				x = (-w - c * y) / a;
				return new Point(x, y);
				
			}
			return null; 
		}
		static public function calcUBoundsToFitTBounds(w:Number, 
													   h:Number,
													   matrix:Matrix,
													   minX:Number,
													   minY:Number, 
													   maxX:Number, 
													   maxY:Number):Point
		{
			var a:Number = matrix.a;
			var b:Number = matrix.b;
			var c:Number = matrix.c;
			var d:Number = matrix.d;
			if (-1.0e-9 < a && a < +1.0e-9)
				a = 0;
			if (-1.0e-9 < b && b < +1.0e-9)
				b = 0;
			if (-1.0e-9 < c && c < +1.0e-9)
				c = 0;
			if (-1.0e-9 < d && d < +1.0e-9)
				d = 0;
			if (b == 0 && c == 0)
			{
				if (a == 0 || d == 0)
					return null;
				return new Point(w / Math.abs(a), h / Math.abs(d));
			}
			
			if (a == 0 && d == 0)
			{
				if (b == 0 || c == 0)
					return null;
				return new Point(h / Math.abs(b), w / Math.abs(c));
			}
			const c1:Number = ( a*c >= 0 ) ? c : -c;
			const d1:Number = ( b*d >= 0 ) ? d : -d;
			const det:Number = a * d1 - b * c1;
			if (Math.abs(det) < 1.0e-9)
			{
				if (c1 == 0 || a == 0 || a == -c1)
					return null;
				
				if (Math.abs(a * h - b * w) > 1.0e-9)
					return null; 
				return solveEquation(a, c1, w, minX, minX, maxX, maxY, b, d1);
			}
			const invDet:Number = 1 / det;
			w *= invDet;
			h *= invDet;
			var s:Point;
			s = solveSystem(a, c1, b, d1, w, h);
			if (s &&
				minX <= s.x && s.x <= maxX && minY <= s.y && s.y <= maxY &&
				a * s.x + c1 * s.x >= 0 &&
				b * s.x + d1 * s.y >= 0)
				return s;
			s = solveSystem( a, c1, b, d1, w, -h);
			if (s &&
				minX <= s.x && s.x <= maxX && minY <= s.y && s.y <= maxY &&
				a * s.x + c1 * s.x >= 0 &&
				b * s.x + d1 * s.y < 0)
				return s;
			s = solveSystem( a, c1, b, d1, -w, h);
			if (s &&
				minX <= s.x && s.x <= maxX && minY <= s.y && s.y <= maxY &&
				a * s.x + c1 * s.x < 0 &&
				b * s.x + d1 * s.y >= 0)
				return s;
			s = solveSystem( a, c1, b, d1, -w, -h);
			if (s &&
				minX <= s.x && s.x <= maxX && minY <= s.y && s.y <= maxY &&
				a * s.x + c1 * s.x < 0 &&
				b * s.x + d1 * s.y < 0)
				return s;
			
			return null; 
		}
		public static function isEqual(m1:Matrix, m2:Matrix):Boolean
		{
			return ((m1 && m2 && 
				m1.a == m2.a &&
				m1.b == m2.b &&
				m1.c == m2.c &&
				m1.d == m2.d &&
				m1.tx == m2.tx &&
				m1.ty == m2.ty) || 
				(!m1 && !m2));
		}
		public static function isEqual3D(m1:Matrix3D, m2:Matrix3D):Boolean
		{
			if (m1 && m2 && m1.rawData.length == m2.rawData.length)
			{
				var r1:Vector.<Number> = m1.rawData;
				var r2:Vector.<Number> = m2.rawData;
				
				return (r1[0] == r2[0] &&
					r1[1] == r2[1] &&
					r1[2] == r2[2] &&
					r1[3] == r2[3] &&
					r1[4] == r2[4] &&
					r1[5] == r2[5] &&
					r1[6] == r2[6] &&
					r1[7] == r2[7] &&
					r1[8] == r2[8] &&
					r1[9] == r2[9] &&
					r1[10] == r2[10] &&
					r1[11] == r2[11] &&
					r1[12] == r2[12] &&
					r1[13] == r2[13] &&
					r1[14] == r2[14] &&
					r1[15] == r2[15]);
			}
			
			return (!m1 && !m2);
		}
		static private function solveSystem(a:Number, 
											c:Number, 
											b:Number, 
											d:Number, 
											mOverDet:Number, 
											nOverDet:Number):Point
		{
			return new Point(d * mOverDet - c * nOverDet,
				a * nOverDet - b * mOverDet);
		}
		
	}
	
}
