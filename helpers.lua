function get_current_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

function table_column(tbl, idx)
  result = {}
  for k,v in pairs(tbl) do
    table.insert(result, v[idx])
  end
  return result
end
