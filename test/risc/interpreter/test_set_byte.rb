require_relative "helper"

module Risc
  class InterpretSetByte < MiniTest::Test
    include Ticker

    def setup
      @string_input = as_main("return 'Hello'.set_internal_byte(1,75)")
      super
    end

    def test_chain
      #show_main_ticks # get output of what is
      check_main_chain [Label, LoadConstant, SlotToReg, SlotToReg, RegToSlot,
             LoadConstant, SlotToReg, SlotToReg, SlotToReg, SlotToReg,
             RegToSlot, LoadConstant, SlotToReg, SlotToReg, SlotToReg,
             SlotToReg, RegToSlot, LoadConstant, SlotToReg, RegToSlot,
             LoadConstant, SlotToReg, SlotToReg, RegToSlot, LoadConstant,
             SlotToReg, SlotToReg, RegToSlot, LoadConstant, SlotToReg,
             RegToSlot, SlotToReg, LoadConstant, FunctionCall, Label,
             SlotToReg, SlotToReg, SlotToReg, SlotToReg, SlotToReg,
             SlotToReg, SlotToReg, RegToByte, RegToSlot, SlotToReg,
             SlotToReg, RegToSlot, SlotToReg, SlotToReg, FunctionReturn,
             SlotToReg, SlotToReg, RegToSlot, SlotToReg, SlotToReg,
             RegToSlot, SlotToReg, SlotToReg, RegToSlot, SlotToReg,
             SlotToReg, FunctionReturn, Transfer, Syscall, NilClass]
       assert_equal Parfait::Word , get_return.class
       assert_equal "Kello" , get_return.to_string
    end
    def test_reg_to_byte
      done = main_ticks(43)
      assert_equal RegToByte ,  done.class
      assert_equal "K".ord ,  @interpreter.get_register(done.register)
    end
    def test_exit
      done = main_ticks(64)
      assert_equal Syscall ,  done.class
    end

  end
end
