require 'io/console'

require

# ╔══════════════════════════════════════════════════════════════╗
# ║                    TerminalLib · Ruby                        ║
# ║   Your terminal doesn't need to be ugly.                     ║
# ╚══════════════════════════════════════════════════════════════╝

# ============================================================
# ORIGINAL API  (kept exactly as written — never deleted)
# ============================================================

#
# CLEAR TERMINAL
#
def clear_all
  print "\e[H\e[2J"
  $stdout.flush
end

#
# WAIT ENTER AND CLEAR
#
def wait_enter_clear(prompt = "\n\nPress Enter...")
  print prompt
  STDIN.gets
  print "\e[F\e[K"
end

#
# COLORS
#
module Colors
  RESET  = "\e[0m"
  BLACK  = "\e[30m"
  RED    = "\e[31m"
  GREEN  = "\e[32m"
  YELLOW = "\e[33m"
  BLUE   = "\e[34m"
  PURPLE = "\e[35m"
  CYAN   = "\e[36m"
  WHITE  = "\e[37m"
end



#
# TYPEWRITE
#
def typewrite(text, speed = 0.03)
  text.each_char do |char|
    print char
    $stdout.flush
    sleep speed
  end
  puts
end

#
# PROGRESS BAR
#
def print_progress_bar(current, total, bar_length = 20)
  progress = current.to_f / total
  filled_length = (bar_length * progress).to_i
  bar = '∎' * filled_length + '.' * (bar_length - filled_length)
  por = progress * 100

  print "\r[#{bar}] #{'%.2f' % por}% #{current}/#{total} :) "
  $stdout.flush

  puts if current == total
end

#
# PRINT CENTRALIZED TEXT
#
def terminal_width
  IO.console.winsize[1]
rescue
  80
end

def strip_ansi_codes(text)
  text.gsub(/\e\[[0-9;]*[A-Za-z]/, '')
end

def print_centralized_text(text)
  term_width = terminal_width
  text.lines.each do |line|
    clean_line = strip_ansi_codes(line.chomp)
    padding = [(term_width - clean_line.length) / 2, 0].max
    puts ' ' * padding + line.chomp
  end
end

# ╔══════════════════════════════════════════════════════════════╗
# ║   ✦ EXTENDED API · v2  (new features, originals untouched)   ║
# ╚══════════════════════════════════════════════════════════════╝

#
# CURSOR CONTROL
#
module Cursor
  HIDE    = "\e[?25l"
  SHOW    = "\e[?25h"
  SAVE    = "\e[s"
  RESTORE = "\e[u"

  module_function

  def up(n = 1);    print "\e[#{n}A"; end
  def down(n = 1);  print "\e[#{n}B"; end
  def right(n = 1); print "\e[#{n}C"; end
  def left(n = 1);  print "\e[#{n}D"; end
  def goto(row, col); print "\e[#{row};#{col}H"; end
  def clear_line; print "\e[2K\r"; end
  def hide; print HIDE; $stdout.flush; end
  def show; print SHOW; $stdout.flush; end
end

#
# TEXT STYLES
#
module Style
  RESET     = "\e[0m"
  BOLD      = "\e[1m"
  DIM       = "\e[2m"
  ITALIC    = "\e[3m"
  UNDERLINE = "\e[4m"
  BLINK     = "\e[5m"
  REVERSE   = "\e[7m"
  HIDDEN    = "\e[8m"
  STRIKE    = "\e[9m"
end

#
# 24-BIT RGB & 256-COLOR SUPPORT
#
module RGB
  module_function

  def fg(r, g, b);  "\e[38;2;#{r};#{g};#{b}m"; end
  def bg(r, g, b);  "\e[48;2;#{r};#{g};#{b}m"; end
  def fg256(n);     "\e[38;5;#{n}m"; end
  def bg256(n);     "\e[48;5;#{n}m"; end

  def hex(hex_str)
    h = hex_str.sub('#', '')
    fg(h[0..1].to_i(16), h[2..3].to_i(16), h[4..5].to_i(16))
  end
end

#
# GRADIENT & RAINBOW TEXT
#
def gradient_text(text, start_rgb = [255, 0, 128], end_rgb = [0, 200, 255])
  out = ''
  n = [text.length - 1, 1].max
  text.each_char.with_index do |ch, i|
    t = i.to_f / n
    r = (start_rgb[0] + (end_rgb[0] - start_rgb[0]) * t).to_i
    g = (start_rgb[1] + (end_rgb[1] - start_rgb[1]) * t).to_i
    b = (start_rgb[2] + (end_rgb[2] - start_rgb[2]) * t).to_i
    out << RGB.fg(r, g, b) << ch
  end
  out + Style::RESET
end

def rainbow_text(text)
  out = ''
  text.each_char.with_index do |ch, i|
    h = (i.to_f / [text.length, 1].max) * 360
    r, g, b = _hsv_to_rgb(h, 1, 1)
    out << RGB.fg(r, g, b) << ch
  end
  out + Style::RESET
end

def _hsv_to_rgb(h, s, v)
  c = v * s
  x = c * (1 - ((h / 60.0) % 2 - 1).abs)
  m = v - c
  r, g, b = case h
            when 0...60   then [c, x, 0]
            when 60...120 then [x, c, 0]
            when 120...180 then [0, c, x]
            when 180...240 then [0, x, c]
            when 240...300 then [x, 0, c]
            else [c, 0, x]
            end
  [((r + m) * 255).to_i, ((g + m) * 255).to_i, ((b + m) * 255).to_i]
end

#
# ADVANCED TEXT EFFECTS
#
def glitch(text, duration: 1.5, intensity: 0.3)
  glitch_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?/~`"
  end_at = Time.now + duration
  Cursor.hide
  while Time.now < end_at
    out = text.each_char.map { |c| rand < intensity ? glitch_chars[rand(glitch_chars.length)] : c }.join
    print "\r#{RGB.fg(0, 255, 120)}#{out}#{Style::RESET}"
    $stdout.flush
    sleep 0.05
  end
  print "\r#{text}    \n"
  Cursor.show
end

def shake(text, duration: 1.0)
  end_at = Time.now + duration
  Cursor.hide
  while Time.now < end_at
    offset = rand(5)
    print "\r#{' ' * offset}#{text}#{' ' * (4 - offset)}"
    $stdout.flush
    sleep 0.04
  end
  print "\r#{text}    \n"
  Cursor.show
end

def wave(text, cycles: 2, speed: 0.05)
  Cursor.hide
  (cycles * 30).to_i.times do |frame|
    out = ''
    text.each_char.with_index do |ch, i|
      phase = (i + frame) * 0.3
      r = (127 + 127 * Math.sin(phase)).to_i
      g = (127 + 127 * Math.sin(phase + 2)).to_i
      b = (127 + 127 * Math.sin(phase + 4)).to_i
      out << RGB.fg(r, g, b) << ch
    end
    print "\r#{out}#{Style::RESET}"
    $stdout.flush
    sleep speed
  end
  puts
  Cursor.show
end

def fade_in(text, speed: 0.04)
  Cursor.hide
  (1..text.length).each do |i|
    print "\r#{text[0...i]}"
    $stdout.flush
    sleep speed
  end
  puts
  Cursor.show
end
#
# SPINNERS
#
SPINNER_FRAMES = {
  dots:     ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
  line:     ["-", "\\", "|", "/"],
  arrows:   ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"],
  moon:     ["🌑","🌒","🌓","🌔","🌕","🌖","🌗","🌘"],
  bouncing: ["[    ]","[=   ]","[==  ]","[=== ]","[ ===]","[  ==]","[   =]","[    ]"],
  pulse:    ["•", "●", "◉", "●", "•"]
}.freeze

class Spinner
  def initialize(message: "Loading", style: :dots, color: nil)
    @frames  = SPINNER_FRAMES[style] || SPINNER_FRAMES[:dots]
    @message = message
    @color   = color || RGB.fg(0, 200, 255)
    @stop    = false
    @thread  = nil
  end

  def start
    Cursor.hide
    @stop = false
    @thread = Thread.new do
      i = 0
      until @stop
        print "\r#{@color}#{@frames[i % @frames.length]}#{Style::RESET} #{@message}"
        $stdout.flush
        sleep 0.08
        i += 1
      end
      Cursor.clear_line
      Cursor.show
    end
    self
  end

  def stop(final_message = nil)
    @stop = true
    @thread&.join
    puts final_message if final_message
  end

  def self.run(message: "Loading", style: :dots)
    s = new(message: message, style: style).start
    yield
  ensure
    s&.stop
  end
end

#
# BOXES & BORDERS
#
BOX_STYLES = {
  single:  "┌─┐│└─┘│",
  double:  "╔═╗║╚═╝║",
  rounded: "╭─╮│╰─╯│",
  heavy:   "┏━┓┃┗━┛┃",
  ascii:   "+-+|+-+|"
}.freeze

def box(text, style: :rounded, padding: 1, color: nil)
  s  = BOX_STYLES[style] || BOX_STYLES[:rounded]
  tl, h, tr, r, bl, _, br, l = s.chars
  lines = text.split("\n")
  width = lines.map { |ln| strip_ansi_codes(ln).length }.max
  pad   = ' ' * padding
  color ||= ''
  rst   = color.empty? ? '' : Style::RESET

  top    = "#{color}#{tl}#{h * (width + padding * 2)}#{tr}#{rst}"
  bottom = "#{color}#{bl}#{h * (width + padding * 2)}#{br}#{rst}"
  body   = lines.map do |ln|
    clean_len = strip_ansi_codes(ln).length
    "#{color}#{l}#{rst}#{pad}#{ln}#{' ' * (width - clean_len)}#{pad}#{color}#{r}#{rst}"
  end
  ([top] + body + [bottom]).join("\n")
end

def hr(char = '─', color: nil)
  line = char * terminal_width
  color ? "#{color}#{line}#{Style::RESET}" : line
end

#
# TABLE
#
def table(headers, rows, color_header: nil)
  cols   = headers.length
  widths = headers.map { |h| h.to_s.length }
  rows.each do |row|
    cols.times { |i| widths[i] = [widths[i], row[i].to_s.length].max }
  end

  fmt = ->(row) { "│ " + (0...cols).map { |i| row[i].to_s.ljust(widths[i]) }.join(" │ ") + " │" }
  top = "┌─" + widths.map { |w| '─' * w }.join("─┬─") + "─┐"
  mid = "├─" + widths.map { |w| '─' * w }.join("─┼─") + "─┤"
  bot = "└─" + widths.map { |w| '─' * w }.join("─┴─") + "─┘"

  header_line = fmt.call(headers)
  header_line = "#{color_header}#{header_line}#{Style::RESET}" if color_header

  ([top, header_line, mid] + rows.map(&fmt) + [bot]).join("\n")
end

#
# INTERACTIVE MENU (arrow-key navigation)
#
def menu(title, options, color: nil)
  color ||= RGB.fg(0, 220, 255)
  selected = 0
  Cursor.hide
  begin
    loop do
      puts "#{Style::BOLD}#{color}#{title}#{Style::RESET}"
      options.each_with_index do |opt, i|
        marker = i == selected ? '❯' : ' '
        line = " #{marker} #{opt}"
        line = "#{color}#{Style::BOLD}#{line}#{Style::RESET}" if i == selected
        puts line
      end

      key = STDIN.getch
      key += STDIN.getch + STDIN.getch if key == "\e"

      case key
      when "\e[A" then selected = (selected - 1) % options.length
      when "\e[B" then selected = (selected + 1) % options.length
      when "\r", "\n" then return selected
      end

      (options.length + 1).times do
        Cursor.up
        Cursor.clear_line
      end
    end
  ensure
    Cursor.show
  end
end

#
# BEEP
#
def beep
  print "\a"
  $stdout.flush
end

#
# DEMO
#
if __FILE__ == $PROGRAM_NAME
  clear_all
  puts rainbow_text("✦ TerminalLib · Ruby · v2 ✦")
  puts hr('─', color: RGB.fg(80, 80, 80))
  puts box("Your terminal\ndoesn't need to be ugly.", style: :rounded, color: RGB.fg(0, 220, 255))
  typewrite(gradient_text("Loading awesome features..."))
  Spinner.run(message: "Crunching numbers", style: :dots) { sleep 1.5 }
  glitch("SYSTEM ONLINE", duration: 1.2)
  wave("~ have fun ~", cycles: 2)
end
