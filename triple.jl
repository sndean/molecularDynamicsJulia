function triple(x)
  index0 = cell(1, size(x,2)*3)
    for i=1:3
      index0[i:3:end] = 3.*(x-1) + i
    end
    return index0
end