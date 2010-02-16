# Model wrapping a team's success.
class Victory < ActiveRecord::Base  
  # The name of the team who succeeded in breaking a key.
  validates_length_of :team_name, :in => 1..256, :allow_nil => false
  # The IP that succeeded in breaking a key.
  validates_length_of :source_ip, :in => 1..256, :allow_nil => false
end
