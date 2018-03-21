require_relative "helper"

module Risc
  class TestCallSimple < MiniTest::Test
    include Statements

    def setup
      super
      @input = "5.mod4"
      @expect = [LoadConstant, SlotToReg, RegToSlot, LoadConstant, SlotToReg, SlotToReg ,
                 RegToSlot, LoadConstant, SlotToReg, SlotToReg, RegToSlot, LoadConstant ,
                 SlotToReg, RegToSlot, LoadConstant, SlotToReg, RegToSlot, SlotToReg ,
                 LoadConstant, FunctionCall, Label]
    end

    def test_send_instructions
      assert_nil msg = check_nil , msg
    end
    def test_function_call
      produced = produce_body
      assert_equal FunctionCall , produced.next(19).class
      assert_equal :mod4 , produced.next(19).method.name
    end
    def test_load_label
      produced = produce_body
      assert_equal Label , produced.next(14).constant.known_object.class
    end
    def test_load_5
      produced = produce_body
      assert_equal 5 , produced.next(11).constant.known_object.value
    end
    def test_call_reg_setup
      produced = produce_body
      assert_equal produced.next(18).register , produced.next(19).register
    end
    #TODO check the message setup, type and frame moves
  end
end