local M = {}

M.defaults = {
  standard = "ada-2022",
}

M.standards = {
  ["ada-2022"]  = { label = "Ada 2022",           iso = "ISO/IEC 8652:2023" },
  ["ada-2012"]  = { label = "Ada 2012",           iso = "ISO/IEC 8652:2012" },
  ["ada-2005"]  = { label = "Ada 2005",           iso = "ISO/IEC 8652:2007" },
  ["spark"]     = { label = "SPARK",              iso = "ISO/IEC 8652:2023 with SPARK" },
  ["spark-2014"]= { label = "SPARK 2014",         iso = "ISO/IEC 8652:2012 with SPARK 2014" },
  ["jorvik"]    = { label = "Jorvik",             iso = "ISO/IEC 24718:2025" },
  ["ravenscar"] = { label = "Ravenscar",          iso = "ISO/IEC TS 24718:2025" },
}

function M.validate(standard)
  if not M.standards[standard] then
    local keys = vim.tbl_keys(M.standards)
    table.sort(keys)
    vim.notify(
      "ada_snippets: unknown standard '" .. standard .. "'. Valid: " .. table.concat(keys, ", "),
      vim.log.levels.WARN
    )
    return M.defaults.standard
  end
  return standard
end

function M.get_info(standard)
  return M.standards[standard] or M.standards[M.defaults.standard]
end

return M
