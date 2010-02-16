require 'test_helper'

class KeyTest < ActiveSupport::TestCase
  def setup
    @block = (32...48).to_a.pack('C*')
  end
  test "encrypt! with identity key" do
    assert_equal @block, keys(:identity).encrypt!(@block)
  end
  test "encrypt with normal key" do
    assert_equal @block, keys(:identity).encrypt(@block),
                 'Bad encryption result'
    assert_equal 499, keys(:identity).reload.calls_left,
                 'calls_left not reduced'
  end
  test "encrypt with dead key" do
    assert_difference("Key.count", -1) do
      assert_equal nil, keys(:blow_up).encrypt(@block),
                   'Blow-up key should not encrypt'
    end
  end
end
