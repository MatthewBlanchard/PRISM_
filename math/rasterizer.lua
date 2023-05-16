--[[
 * Bresenham Curve Rasterizing Algorithms
 * @author alois zingl
 * @version V20.20 mai 2020
 * @copyright MIT open-source license software
 * @url https://github.com/zingl/Bresenham
 * @author  Zingl Alois
--]]

local Rasterizer = {}

function Rasterizer:plot(control_points, settings, callback)
   -- settings: bool aa, float width, float weight

   if #control_points == 2 then
      local p = control_points

      if settings.width then
         if settings.weight then
            error()
         else
            error()
         end
      elseif settings.aa then
         if settings.weight then
            error()
         else
            self.lineAA(p[1].x, p[1].y, p[2].x, p[2].y, callback)
         end
      elseif settings.weight then
         error()
      else
         self.line(p[1].x, p[1].y, p[2].x, p[2].y, callback)
      end
   end

   if #control_points == 3 then
      local p = control_points

      if settings.width then
         if settings.weight then
            error()
         else
            error()
         end
      elseif settings.aa then
         if settings.weight then
            error()
         else
            error()
         end
      elseif settings.weight then
         self:QuadR(p[1].x, p[1].y, p[2].x, p[2].y, p[3].x, p[3].y, settings.weight, callback)
      else
         error()
      end
   end
end

function Rasterizer.line(x0, y0, x1, y1, callback)
   local dx = math.abs(x1-x0)
   local dy = -math.abs(y1-y0)
   local sx = x0 < x1 and 1 or -1
   local sy = y0 < y1 and 1 or -1
   local err = dx + dy
   local e2

   while true do
      callback(x0, y0)
      e2 = 2*err
      if (e2 >= dy) then
         if (x0 == x1) then break end
         err = err + dy;
         x0 = x0 + sx
      end
      if (e2 <= dx) then
         if (y0 == y1) then break end
         err = err + dx;
         y0 = y0 + sy
      end
   end
end

function Rasterizer.lineAA(x0, y0, x1, y1, callback)
      local dx = math.abs(x1-x0); local sx = x0 < x1 and 1 or -1;
      local dy = math.abs(y1-y0); local sy = y0 < y1 and 1 or -1;
      local err = dx-dy; local e2, x2;
      local ed = dx+dy == 0 and 1 or math.sqrt(dx*dx+dy*dy);
   
      while true do
         callback(x0,y0, 255*math.abs(err-dx+dy)/ed);
         e2 = err; x2 = x0;
         if (2*e2 >= -dx) then
            if (x0 == x1) then break end
            if (e2+dy < ed) then callback(x0,y0+sy, 255*(e2+dy)/ed) end
            err = err - dy; x0 = x0 + sx;
         end
         if (2*e2 <= dy) then
            if (y0 == y1) then break end
            if (dx-e2 < ed) then callback(x2+sx,y0, 255*(dx-e2)/ed) end
            err = err + dx; y0 = y0 + sy;
         end
      end
end

function Rasterizer:QuadRSeg(x0, y0, x1, y1, x2, y2, w, callback)
   -- plot a limited rational Bezier segment, squared weight
   local sx = x2-x1; local sy = y2-y1; -- relative values for checks
   local dx = x0-x2; local dy = y0-y2; local xx = x0-x1; local yy = y0-y1;
   local xy = xx*sy+yy*sx; local cur = xx*sy-yy*sx; local err; -- curvature
   
   assert(xx*sx <= 0.0 and yy*sy <= 0.0); -- sign of gradient must not change
   
   if (cur ~= 0.0 and w > 0.0) then -- no straight line
      if (sx*sx+sy*sy > xx*xx+yy*yy) then -- begin with shorter part
         x2 = x0; x0 = x0 - dx; y2 = y0; y0 = y0 - dy; cur = -cur; -- swap P0 P2
      end
      xx = 2.0*(4.0*w*sx*xx+dx*dx); -- differences 2nd degree
      yy = 2.0*(4.0*w*sy*yy+dy*dy);
      sx = x0 < x2 and 1 or -1; -- x step direction
      sy = y0 < y2 and 1 or -1; -- y step direction
      xy = -2.0*sx*sy*(2.0*w*xy+dx*dy);
   
      if (cur*sx*sy < 0.0) then -- negated curvature?
         xx = -xx; yy = -yy; xy = -xy; cur = -cur;
      end
      dx = 4.0*w*(x1-x0)*sy*cur+xx/2.0+xy; -- differences 1st degree
      dy = 4.0*w*(y0-y1)*sx*cur+yy/2.0+xy;
   
      if (w < 0.5 and (dy > xy or dx < xy)) then -- flat ellipse, algorithm fails
         cur = (w+1.0)/2.0; w = math.sqrt(w); xy = 1.0/(w+1.0);
         sx = math.floor((x0+2.0*w*x1+x2)*xy/2.0+0.5); --subdivide curve in half
         sy = math.floor((y0+2.0*w*y1+y2)*xy/2.0+0.5);
         dx = math.floor((w*x1+x0)*xy+0.5); dy = math.floor((y1*w+y0)*xy+0.5);
         self:QuadRSeg(x0,y0, dx,dy, sx,sy, cur, callback);-- plot separately
         dx = math.floor((w*x1+x2)*xy+0.5); dy = math.floor((y1*w+y2)*xy+0.5);
         self:QuadRSeg(sx,sy, dx,dy, x2,y2, cur, callback);
         return;
      end
      err = dx+dy-xy; -- error 1.step
      repeat
         callback(x0,y0);                                          -- plot curve
         if (x0 == x2 and y0 == y2) then return end       -- last pixel -> curve finished
         x1 = 2*err > dy; y1 = 2*(err+yy) < -dy; -- save value for test of x step
         if (2*err < dx or y1) then y0 = y0 + sy; dy = dy + xy; dx = dx + xx; err = err + dx end -- y step
         if (2*err > dx or x1) then x0 = x0 + sx; dx = dx + xy; dy = dy + yy; err = err + dy end -- x step
      until not (dy <= xy and dx >= xy); -- gradient negates -> algorithm fails
   end
   self.line(x0,y0, x2,y2, callback); -- plot remaining needle to end
end

function Rasterizer:QuadR(x0, y0, x1, y1, x2, y2, w, callback)
   -- plot any quadratic rational Bezier curve
   local x = x0-2*x1+x2; local y = y0-2*y1+y2;
   local xx = x0-x1; local yy = y0-y1; local ww, t, q;
   
   assert(w >= 0.0);
   
   if (xx*(x2-x1) > 0) then -- horizontal cut at P4?
      if (yy*(y2-y1) > 0) then -- vertical cut at P6 too?
         if (math.abs(xx*y) > math.abs(yy*x)) then -- which first?
            x0 = x2; x2 = xx+x1; y0 = y2; y2 = yy+y1; -- swap points
         end -- now horizontal cut at P4 comes first
      end
      if (x0 == x2 or w == 1.0) then t = (x0-x1)/x;
      else -- non-rational or rational case
         q = math.sqrt(4.0*w*w*(x0-x1)*(x2-x1)+(x2-x0)*(x2-x0));
         if (x1 < x0) then q = -q end;
         t = (2.0*w*(x0-x1)-x0+x2+q)/(2.0*(1.0-w)*(x2-x0)); -- t at P4
      end
      q = 1.0/(2.0*t*(1.0-t)*(w-1.0)+1.0); -- sub-divide at t
      xx = (t*t*(x0-2.0*w*x1+x2)+2.0*t*(w*x1-x0)+x0)*q; -- = P4
      yy = (t*t*(y0-2.0*w*y1+y2)+2.0*t*(w*y1-y0)+y0)*q;
      ww = t*(w-1.0)+1.0; ww = ww*ww*q; -- squared weight P3
      w = ((1.0-t)*(w-1.0)+1.0)*math.sqrt(q); -- weight P8
      x = math.floor(xx+0.5); y = math.floor(yy+0.5); -- P4
      yy = (xx-x0)*(y1-y0)/(x1-x0)+y0; -- intersect P3 | P0 P1
      self:QuadRSeg(x0,y0, x,math.floor(yy+0.5), x,y, ww, callback);
      yy = (xx-x2)*(y1-y2)/(x1-x2)+y2; -- intersect P4 | P1 P2
      y1 = math.floor(yy+0.5); x1 = x; x0 = x1; y0 = y; -- P0 = P4, P1 = P8
   end
   if ((y0-y1)*(y2-y1) > 0) then -- vertical cut at P6?
      if (y0 == y2 or w == 1.0) then t = (y0-y1)/(y0-2.0*y1+y2);
      else -- non-rational or rational case
         q = math.sqrt(4.0*w*w*(y0-y1)*(y2-y1)+(y2-y0)*(y2-y0));
         if (y1 < y0) then q = -q end
         t = (2.0*w*(y0-y1)-y0+y2+q)/(2.0*(1.0-w)*(y2-y0)); -- t at P6
      end
      q = 1.0/(2.0*t*(1.0-t)*(w-1.0)+1.0); -- sub-divide at t
      xx = (t*t*(x0-2.0*w*x1+x2)+2.0*t*(w*x1-x0)+x0)*q; -- = P6
      yy = (t*t*(y0-2.0*w*y1+y2)+2.0*t*(w*y1-y0)+y0)*q;
      ww = t*(w-1.0)+1.0; ww = ww*ww*q; -- squared weight P5
      w = ((1.0-t)*(w-1.0)+1.0)*math.sqrt(q); -- weight P7
      x = math.floor(xx+0.5); y = math.floor(yy+0.5); -- P6
      xx = (x1-x0)*(yy-y0)/(y1-y0)+x0; -- intersect P6 | P0 P1
      self:QuadRSeg(x0,y0, math.floor(xx+0.5),y, x,y, ww, callback);
      xx = (x1-x2)*(yy-y2)/(y1-y2)+x2; -- intersect P7 | P1 P2
      x1 = math.floor(xx+0.5); x0 = x; y1 = y; y0 = y1; -- P0 = P6, P1 = P7
   end
   self:QuadRSeg(x0,y0, x1,y1, x2,y2, w*w, callback); -- remaining
end

return Rasterizer