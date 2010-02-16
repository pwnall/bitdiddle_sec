require 'test_helper'

class BesTest < Test::Unit::TestCase
  def setup    
    # Identity permutation.
    @i128 = (0...128).to_a
    # Reversed identity permutation.
    @r128 = @i128.reverse
    # Identity permutation.
    @i256 = (0...256).to_a

    # Pseudo-random source.
    @pr_source = (1..16).map { |i| (i ** 2 + 5 * i + 3) % 256 }.pack('C*')
    # Bit-inverted pseudo-random source.
    @i_pr_source = [@pr_source.unpack('B*').first.reverse].pack('B*')
        
    # An S-box implementing XOR 0x56. 
    @xor_s = (0...256).map { |i| i ^ 0x56 }
    # The pseudo-random source through XOR 0x56.
    @xor_source = @pr_source.unpack('C*').map { |c| c ^ 0x56 }.pack('C*')
    # The bit-inverted pseudo-random source through XOR 0x56.
    @xor_i_source = @i_pr_source.unpack('C*').map { |c| c ^ 0x56 }.pack('C*')
    # Bit-inverted pseudo-random source through XOR 0x56.
    @i_xor_source = [@xor_source.unpack('B*').first.reverse].pack('B*')
    # Bit-inverted (bit-inverted pseudo-random source through XOR 0x56).
    @i_xor_i_source = [@xor_i_source.unpack('B*').first.reverse].pack('B*')
  end
  
  def test_identity    
    material = { :p1 => @i128, :p2 => @i128, :s => @i256 }
    assert_equal @pr_source, Bes.new(material).encrypt(@pr_source)
  end
  
  def test_p1
    material = { :p1 => @r128, :p2 => @i128, :s => @i256 }    
    assert_equal @i_pr_source, Bes.new(material).encrypt(@pr_source)
  end

  def test_p2
    material = { :p1 => @i128, :p2 => @r128, :s => @i256 }
    assert_equal @i_pr_source, Bes.new(material).encrypt(@pr_source)
  end
  
  def test_p1_p2
    material = { :p1 => @r128, :p2 => @r128, :s => @i256 }
    assert_equal @pr_source, Bes.new(material).encrypt(@pr_source)    
  end
  
  def test_s
    material = { :p1 => @i128, :p2 => @i128, :s => @xor_s }
    assert_equal @xor_source, Bes.new(material).encrypt(@pr_source)
  end
  
  def test_p1_s
    material = { :p1 => @r128, :p2 => @i128, :s => @xor_s }
    is_source = @i_pr_source.unpack('C*').map { |c| c ^ 0x56 }.pack('C*')
    assert_equal @xor_i_source, Bes.new(material).encrypt(@pr_source)    
  end
  
  def test_s_p2
    material = { :p1 => @i128, :p2 => @r128, :s => @xor_s }
    assert_equal @i_xor_source, Bes.new(material).encrypt(@pr_source)
  end
  
  def test_p1_s_p2
    material = { :p1 => @r128, :p2 => @r128, :s => @xor_s }
    assert_equal @i_xor_i_source, Bes.new(material).encrypt(@pr_source)    
  end
  
  def test_randomness
    iterations = 1000
    p1s = Set.new
    p2s = Set.new
    ss = Set.new
    
    iterations.times do
      material = Bes.new.material
      p1s << material[:p1]
      p2s << material[:p2]
      ss << material[:s]
    end
    assert_equal iterations, p1s.length, 'Insufficient randomness in P1' 
    assert_equal iterations, p2s.length, 'Insufficient randomness in P2' 
    assert_equal iterations, ss.length, 'Insufficient randomness in S' 
  end
end
