local OffsetOptimizer = {}
function OffsetOptimizer:new(params)
  params = params or {}
  local numFramesOfHistory = params.numFramesOfHistory or 120

  local optimizer = {
    -- Private config vars
    _numFramesOfHistory = numFramesOfHistory,

    -- Private vars
    _records = {},

    -- Public methods
    -- Recorsd an offset, e.g. negative means late, positive means early
    recordOffset = function(self, offset)
      if not self._records[1] or self._records[1] > offset then
        self._records[1] = offset
      end
    end,
    -- Gets the amount the optimizer would recommend adjusting by, negative means slow down, positive means speed up
    getRecommendedAdjustment = function(self)
      local minOffset = nil
      for i = 1, #self._records do
        if self._records[i] and (minOffset == nil or self._records[i] < minOffset) then
          minOffset = self._records[i]
        end
      end
      minOffset = minOffset or 0
      if #self._records >= self._numFramesOfHistory or minOffset < 0 then
        return -minOffset
      else
        return 0
      end
    end,
    applyAdjustment = function(self, adjustment)
      for i = 1, #self._records do
        if self._records[i] then
          self._records[i] = self._records[i] - adjustment
        end
      end
    end,
    reset = function(self)
      self._records = {}
    end,
    -- Only keep track of the last however many frames of frame offsets
    update = function(self, dt, df)
      for i = self._numFramesOfHistory, 1, -1 do
        if i <= df then
          self._records[i] = false
        else
          self._records[i] = self._records[i - df]
        end
      end
    end
  }

  return optimizer
end

return OffsetOptimizer