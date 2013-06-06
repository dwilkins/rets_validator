class RetsServer < ActiveRecord::Base
  attr_accessible :contact_info, :counties, :login_url, :name, :password, :state, :username
end
