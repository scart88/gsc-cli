# frozen_string_literal: true

module GSC
  module Color
    RESET     = "\e[0m"
    BOLD      = "\e[1m"
    DIM       = "\e[2m"
    UNDERLINE = "\e[4m"
    RED       = "\e[31m"
    GREEN     = "\e[32m"
    YELLOW    = "\e[33m"
    BLUE      = "\e[34m"
    MAGENTA   = "\e[35m"
    CYAN      = "\e[36m"
    WHITE     = "\e[37m"
    GRAY      = "\e[90m"

    def self.c(text, *styles)
      "#{styles.join}#{text}#{RESET}"
    end
  end
end
