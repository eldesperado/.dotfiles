
-- Misc utils
-----------------------------------------------

local misc = {}


-- Return true if the two value are within a certain range of each other.

-- The default tolerance is set to 20 units. Here, a unit corresponds to a
-- pixel.
function misc.isApprox(value1, value2, tolerance)
  tolerance = tolerance or 20
  return math.max(value1, value2) - math.min(value1, value2) < tolerance;
end

-- Returns true if the given rect objects are approximate matches.
--
-- Please refer to the `isApprox` match for implementation details about how
-- we determine whether two rects are approximate matches.
function misc.isRectsApproxMatch(rect1, rect2)
  return (misc.isApprox(rect1.x, rect2.x) and
          misc.isApprox(rect1.x + rect1.w, rect2.x + rect2.w) and
          misc.isApprox(rect1.y, rect2.y) and
          misc.isApprox(rect1.y + rect1.h, rect1.y + rect2.h))
end


----------------------------------------------------------------------------
return misc
