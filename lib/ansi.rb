module Ansi
  CODES = {
    bold: "\e[1m",
    bg_blue: "\e[48;5;4m",
    bg_green: "\e[48;5;2m",
    bg_purple: "\e[48;5;5m",
    bg_red: "\e[48;5;1m",
    bg_teal: "\e[48;5;6m",
    bg_yellow: "\e[48;5;3m",
    fg_blue: "\e[38;5;4m",
    fg_green: "\e[38;5;2m",
    fg_purple: "\e[38;5;5m",
    fg_red: "\e[38;5;1m",
    fg_teal: "\e[38;5;6m",
    fg_yellow: "\e[38;5;3m",
    reset: "\e[0m",
  }

  # ESC[ 38;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB foreground color
  # ESC[ 48;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB background color
  # fg:ff0000 -> \e[38;2;255;0;0;
  # bg:ff0000 -> \e[48;2;255;0;0;

  def self.[](str, *elements)
    elements.map(&CODES).join("").concat(str, CODES[:reset])
  end
end
