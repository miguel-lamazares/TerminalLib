
def numbersBetween(min_value:, max_value:)
  loop do
    user_input = STDIN.gets.chomp

    unless user_input.match?(/\A\d+\z/)
      print "\e[F\e[K"
      next
    end

    choice = user_input.to_i

    if choice < min_value || choice > max_value
      print "\e[F\e[K"
      next
    end

    return choice
  end
end

def onlyNumbers(min_value:, max_value:)
  loop do
    user_input = STDIN.gets.chomp

    unless user_input.match?(/\A\d+\z/)
      print "\e[F\e[K"
      next
    end

    choice = user_input.to_i

    return choice
  end
end