require_relative "helper"

module Register
  class TestPuts < MiniTest::Test
    include Ticker

    def setup
        @string_input = <<HERE
  class Space
    int main()
      "Hello again".putstring()
    end
  end
HERE
      @input = s(:statements, s(:call, s(:name, :putstring), s(:arguments), s(:receiver, s(:string, "Hello again"))))
      super
    end

    def test_chain
      #show_ticks # get output of what is
      check_chain ["Branch","Label","LoadConstant","SlotToReg","RegToSlot",
       "LoadConstant","RegToSlot","FunctionCall","Label","SlotToReg",
       "LoadConstant","RegToSlot","LoadConstant","RegToSlot","LoadConstant",
       "SlotToReg","SlotToReg","RegToSlot","LoadConstant","RegToSlot",
       "RegisterTransfer","FunctionCall","Label","SlotToReg","SlotToReg",
       "RegisterTransfer","Syscall","RegisterTransfer","RegisterTransfer","RegToSlot",
       "Label","FunctionReturn","RegisterTransfer","SlotToReg","SlotToReg",
       "Label","FunctionReturn","RegisterTransfer","Syscall","NilClass"]
    end

    def test_branch
      was = @interpreter.instruction
      assert_equal Register::Branch , ticks(1).class
      assert was != @interpreter.instruction
      assert @interpreter.instruction , "should have gone to next instruction"
    end
    def test_load
      assert_equal Register::LoadConstant ,  ticks(3).class
      assert_equal Parfait::Space , @interpreter.get_register(:r2).class
      assert_equal :r2,  @interpreter.instruction.array.symbol
    end
    def test_get
      assert_equal Register::SlotToReg , ticks(4).class
      assert @interpreter.get_register( :r1 )
      assert Integer , @interpreter.get_register( :r1 ).class
    end
    def test_call
      assert_equal Register::FunctionCall ,  ticks(8).class
    end

    def test_putstring
      done = ticks(27)
      assert_equal Register::Syscall ,  done.class
      assert_equal "Hello again" , @interpreter.stdout
    end

    def test_return
      done = ticks(32)
      assert_equal Register::FunctionReturn ,  done.class
      assert Register::Label , @interpreter.instruction.class
      assert @interpreter.instruction.is_a?(Register::Instruction) , "not instruction #{@interpreter.instruction}"
    end

    def test_exit
      done = ticks(42)
      assert_equal NilClass ,  done.class
      assert_equal "Hello again" , @interpreter.stdout
    end
  end
end
