a = { "apple", "pear", "orange", "pineapple", "tomato" };
b = { "kiwi", "strawberry", "melon" };

-- Filter table #1.
-- @return A table.
function table:filter(filterFnc)
    local result = {};

    for k, v in ipairs(self) do
        if filterFnc(v, k, self) then
            table.insert(result, v);
        end
    end

    return result;
end

-- Get index of a value at a table.
-- @param any value
-- @return any
function table:find(value)
    for k, v in ipairs(self) do
        if v == value then
            return k;
        end
    end
end



local additions;

-- filter b to check additions
additions = table.filter(b, function(value)
    return not table.find(a, value);
end);