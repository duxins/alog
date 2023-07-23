task :l10n do
  cmd = "scripts/l10n Localizable.csv --swift Sources/Localization/LocalizedKeys.swift --root Sources/Localization"
  system(cmd)
  system("xcodegen")
end
