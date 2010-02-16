# Model wrapping an encryption key.
class Key < ActiveRecord::Base  
  # The key's unique id.
  validates_length_of :uid, :in => 1..64, :allow_nil => false
  validates_uniqueness_of :uid
  
  # YAML-serialize the key material.
  serialize :material, Hash
  
  # The IP that requested the generation of this key.
  validates_length_of :source_ip, :in => 1..256, :allow_nil => false
  
  # Number of encrypt calls left.
  validates_numericality_of :calls_left, :only_integer => true,
                            :greater_than_or_equal_to => 0, :allow_nil => false
  
  # Generates a random UID for a key.
  def self.random_uid
    OpenSSL::Random.random_bytes(16).unpack('H*').first
  end
  
  # Use the key to encrypt a block, without counting.
  def encrypt!(block)    
    Bes.new(material).encrypt block
  end
  
  # Use the key to encrypt a block.
  def encrypt(block)
    return_value = encrypt! block
    
    self.calls_left -= 1
    if calls_left < 0
      return_value = nil
      destroy
    else
      save!
    end
    return_value
  end
end
