module Ansi
  CODES = {
    fg_red: "\e[38;5;1m",
    fg_blue: "\e[38;5;4m",
    fg_green: "\e[38;5;2m",
    bold: "\e[1m",
    reset: "\e[0m"
  }

  def self.[](str, *elements)
    elements.map(&CODES).join("").concat(str, CODES[:reset])
  end
end
