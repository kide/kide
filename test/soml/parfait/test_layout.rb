require_relative 'helper'

class TestLayoutRT < MiniTest::Test
  include ParfaitTests

  def test_main
    @main =  "return 1"
    check 1
  end

  def check_return_class val
  end

  def test_get_layout
    @main =  "return get_layout()"
    interpreter = check
    assert_equal  Parfait::Layout , interpreter.get_register(:r0).return_value.class
  end

  def test_get_class
    @main =  "return get_class()"
    interpreter = check
    assert_equal  Parfait::Class , interpreter.get_register(:r0).return_value.class
  end

  def test_puts_class
    @main = <<HERE
Word w = get_class_name()
w.putstring()
HERE
    @stdout = "Space"
    check
  end

  def test_puts_layout_space
    @main = <<HERE
Layout l = get_layout()
Word w = l.get_class_name()
w.putstring()
HERE
    @stdout = "Layout"
    check
  end

  # copy of register parfait tests, in order
  def test_message_layout
    @main = <<HERE
Message m = self.first_message
m = m.next_message
Word w = m.get_class_name()
w.putstring()
HERE
    @stdout = "Message"
    check
  end


end
