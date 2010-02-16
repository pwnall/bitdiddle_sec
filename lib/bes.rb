require 'openssl'

# The Bitdiddle Encrypion Standard.
class Bes
  # Creates a random permutation of a given size.
  def self.random_permutation(size)
    p = (0...size).to_a
    0.upto(size - 2) do |i|
      j = i + rand(size - i)
      p[i], p[j] = p[j], p[i]
    end
    p
  end
  
  # Permutes the bits in a string.
  #
  # Args:
  #   perm:: the permutation (e.g. [5, 3, 1, 7, 0, 4, 2, 6]
  #   source:: the string whose bits are permuted
  #
  # Returns the result of applying perm to the bits of the source string.
  def self.permute_bits(perm, source)
    source_bits = source.unpack('B*').first
    target_bits = ''
    perm.each { |i| target_bits << source_bits[i] }
    
    [target_bits].pack 'B*'
  end
  
  # Creates a new cipher with the given key material.
  #
  # If no key material is given, the cipher gets a randomly generated key.
  def initialize(material = nil)
    material ||= { :p1 => Bes.random_permutation(128),
                   :p2 => Bes.random_permutation(128),
                   :s => Bes.random_permutation(256) }
    
    @material = material
    @p1, @p2, @s = @material[:p1], @material[:p2], @material[:s]
    @block_length = 16
  end
  
  # The key material used by the cipher.
  attr_reader :material
  
  # The number of bytes in a BES data block.
  attr_reader :block_length

  # Encrypts a block (16-bytes) using Bitdiddle's Encryption Standard.
  def encrypt(block)
    unless block.length == @block_length
      raise "Invalid block length: #{block.length}, #{@block_length} expected"
    end

    pre_s = Bes.permute_bits @p1, block
    post_s = pre_s.unpack('C*').map { |i| @s[i] }.pack('C*')
    Bes.permute_bits @p2, post_s
  end
  
  # True if the other key is equivalent to this key.
  def equivalent?(other)
    10000.times do
      block = OpenSSL::Random.random_bytes 16
      return false unless encrypt(block) == other.encrypt(block)
    end
    true
  end
end
