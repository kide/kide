require_relative "logic_helper"

module Arm

  class LogicInstruction < Vm::LogicInstruction
    include Arm::Constants

    def initialize(first , attributes)
      super(first , attributes)
      @attributes[:update_status_flag] = 0 if @attributes[:update_status_flag] == nil
      @attributes[:condition_code] = :al if @attributes[:condition_code] == nil
      @operand = 0

      @left = nil
      @i = 0      
    end
    
    # arm intrucioons are pretty sensible, and always 4 bytes (thumb not supported)
    def length
      4
    end

    # Build representation for source value 
    def build
      @left = @attributes[:left]
      arg = @attributes[:extra]
      
      if arg.is_a?(Vm::StringConstant)
        # do pc relative addressing with the difference to the instuction
        # 8 is for the funny pipeline adjustment (ie oc pointing to fetch and not execute)
        arg = Vm::IntegerConstant.new( arg.position - self.position - 8 )
        @left = :pc
      end
      if( arg.is_a? Fixnum ) #HACK to not have to change the code just now
        arg = Vm::IntegerConstant.new( arg )
      end
      if (arg.is_a?(Vm::IntegerConstant))
        if (arg.integer.fits_u8?)
          # no shifting needed
          @operand = arg.integer
          @i = 1
        elsif (op_with_rot = calculate_u8_with_rr(arg))
          @operand = op_with_rot
          @i = 1
          raise "hmm"
        else
          raise "cannot fit numeric literal argument in operand #{arg.inspect}"
        end
      elsif (arg.is_a?(Symbol) or arg.is_a?(Vm::Integer))
        @operand = arg
        @i = 0
      elsif (arg.is_a?(Arm::Shift))
        rm_ref = arg.argument
        @i = 0
        shift_op = {'lsl' => 0b000, 'lsr' => 0b010, 'asr' => 0b100,
                    'ror' => 0b110, 'rrx' => 0b110}[arg.type]
        if (arg.type == 'ror' and arg.value.nil?)
          # ror #0 == rrx
          raise "cannot rotate by zero #{arg} #{inspect}"
        end
  
        arg1 = arg.value
        if (arg1.is_a?(Vm::IntegerConstant))
          if (arg1.value >= 32)
            raise "cannot shift by more than 31 #{arg1} #{inspect}"
          end
          shift_imm = arg1.value
        elsif (arg1.is_a?(Arm::Register))
          shift_op val |= 0x1;
          shift_imm = arg1.number << 1
        elsif (arg.type == 'rrx')
          shift_imm = 0
        end
        @operand = rm_ref | (shift_op << 4) | (shift_imm << 4+3)
      else
        raise "invalid operand argument #{arg.inspect} , #{inspect}"
      end
    end

    def assemble(io)
      build
      instuction_class = 0b00 # OPC_DATA_PROCESSING
      val = (@operand.is_a?(Symbol) or @operand.is_a?(Vm::Integer)) ? reg_code(@operand) : @operand 
      val = 0 if val == nil
      val = shift(val , 0)
      raise inspect unless reg_code(@first)
      val |= shift(reg_code(@first) ,            12)     
      val |= shift(reg_code(@left) ,            12+4)   
      val |= shift(@attributes[:update_status_flag] , 12+4+4)#20 
      val |= shift(op_bit_code ,        12+4+4  +1)
      val |= shift(@i ,                  12+4+4  +1+4) 
      val |= shift(instuction_class ,   12+4+4  +1+4+1) 
      val |= shift(cond_bit_code ,      12+4+4  +1+4+1+2)
      io.write_uint32 val
    end
    def shift val , by
      raise "Not integer #{val}:#{val.class}" unless val.is_a? Fixnum
      val << by
    end
  end
end