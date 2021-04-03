ANSI = {
  fg_red: "\e[38;5;1m",
  fg_blue: "\e[38;5;4m",
  fg_green: "\e[38;5;2m",
  bold: "\e[1m",
  reset: "\e[0m"
}

def ansi(str, *elements)
  elements.map(&ANSI).join("").concat(str, ANSI[:reset])
end
