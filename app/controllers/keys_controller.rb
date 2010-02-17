class KeysController < ApplicationController
  # GET /keys
  def index
    @victories = Victory.all
  end
  
  # POST /keys
  def create
    @key = Key.create :source_ip => request.remote_ip,
                      :uid => Key.random_uid,
                      :material => Bes.new.material,
                      :calls_left => 1000
  end

  # GET /keys/1234abc
  def show
    @key = Key.find_by_uid params[:id]
    unless @key
      render :text => "No such key\n", :status => 404
      return      
    end
  end
  
  # PUT /keys/1234abc&block=0000000000000000
  def update
    @key = Key.find_by_uid params[:id]
    @encrypted = @key && @key.encrypt([params[:block]].pack('H*'))
    unless @encrypted
      render :text => "No such key\n", :status => 404
      return      
    end    
  end

  # DELETE /keys/1234abc?team=1&p1=0,1,2,...&p2=4,5,6,...&s=0,255,1,254,...
  def destroy
    @key = Key.find_by_uid params[:id]
    unless @key
      render :text => "No such key\n", :status => 404
      return      
    end
    
    p1 = params[:p].split(',').map(&:to_i)[0, 128]
    p2 = params[:q].split(',').map(&:to_i)[0, 128]
    s = params[:s].split(',').map(&:to_i)[0, 256]
    @candidate_key = Bes.new :p1 => p1, :p2 => p2, :s => s
    
    if @candidate_key.equivalent? Bes.new(@key.material)
      @success = true
      Victory.create :team_name => params[:team],
                     :source_ip => request.remote_ip
    else
      @success = false
    end    
    @key.destroy
  end
end
