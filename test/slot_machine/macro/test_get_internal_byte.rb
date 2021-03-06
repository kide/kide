require_relative "helper"

module SlotMachine
  module Builtin
    class TestGetInternalByte < BootTest
      def setup
        super
        @method = get_compiler("Word",:get_byte)
      end
      def test_slot_length
        assert_equal :get_internal_byte , @method.callable.name
        assert_equal 7 , @method.slot_instructions.length
      end
      def test_compile
        assert_equal Risc::MethodCompiler , @method.to_risc.class
      end
      def test_risc_length
        assert_equal 39 , @method.to_risc.risc_instructions.length
      end
      def test_allocate
        assert_allocate
      end
      def test_all
        assert_slot_to_reg 22 ,:message , 2 , "message.receiver"
        assert_slot_to_reg 23 ,:message , 9 , "message.arg1"
        assert_slot_to_reg 24 ,"message.arg1" , 2 , "message.arg1.data_1"

        assert_equal Risc::ByteToReg , risc(25).class
        assert_equal :"message.receiver" , risc(25).array.symbol
        assert_equal :"integer_1" , risc(25).register.symbol
        assert_equal :"message.arg1.data_1" , risc(25).index.symbol


        assert_reg_to_slot 26 , "integer_1" , "id_factory_.next_object" , 2
        assert_reg_to_slot 27 , "id_factory_.next_object" , :message , 5
        assert_slot_to_reg 28 ,:message , 5 , "message.return_value"
        assert_reg_to_slot 29 , "message.return_value" , :message , 5

        assert_branch 30 , "return_label"
        assert_label 31 , "return_label"
      end
      def test_return
        assert_return(31)
      end
    end
  end
end
