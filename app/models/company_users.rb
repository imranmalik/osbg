class CompanyUsers < ActiveRecord::Base
  attr_accessible :company_id, :user_id
end
