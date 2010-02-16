require 'test_helper'

class KeysControllerTest < ActionController::TestCase
  def setup
    @block = (32...48).to_a.pack('C*')
    @r_block = Bes.new(keys(:reverse).material).encrypt(@block)
    @hexblock = @block.unpack('H*').first
    @r_hexblock = @r_block.unpack('H*').first
  end
  
  test "should show index" do
    get :index
    assert_response :success
  end
  
  test "should create key" do
    assert_difference('Key.count') do
      post :create
    end
    assert_response :success
    assert_equal Key.last.uid, @response.body.strip
  end

  test "should show key calls left" do
    get :show, :id => keys(:identity).uid
    assert_response :success
    assert_equal keys(:identity).calls_left.to_s, @response.body.strip
  end

  test "should encrypt with reverse key" do    
    put :update, :id => keys(:reverse).uid, :block => @hexblock    
    assert_equal 499, keys(:reverse).reload.calls_left,
                 'calls_left not decremented'
    assert_response :success
    assert_equal @r_hexblock, @response.body.strip
  end
  
  test "should fail to encrypt with blow-up key" do
    put :update, :id => keys(:blow_up).uid, :block => @hexblock
    assert_response :not_found
    assert_equal 'No such key', @response.body.strip
  end

  test "should accept equivalent key" do
    key = keys(:identity)
    assert_difference('Key.count', -1) do
      delete :destroy, :id => key.uid, :p1 => key.material[:p1].join(','),
                       :p2 => key.material[:p2].join(','),
                       :s => key.material[:s].join(','),
                       :team => 'Team Awesome'
    end
    assert_response :success
    assert_equal 'OK', @response.body.strip
    
    victory = Victory.last
    assert victory, 'no Victory created'
    assert_equal 'Team Awesome', victory.team_name, 'incorrect team name'
  end
  
  test "should reject non-equivalent key" do
    rkey = keys(:reverse)
    key = keys(:identity)
    assert_difference('Key.count', -1) do
      delete :destroy, :id => rkey.uid, :p1 => key.material[:p1].join(','),
                       :p2 => key.material[:p2].join(','),
                       :s => key.material[:s].join(','),
                       :team => 'Team Awesome'
    end
    assert_response :success
    assert_equal 'Nope', @response.body.strip
    
    assert_equal 1, Victory.count, 'Victory created erroneously'
  end
end
