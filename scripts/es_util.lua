function mergeTables(t1, t2)
-- Add every value of t2 in t1
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
end