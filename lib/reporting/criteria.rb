#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
module Reporting
  class Criteria

    # criteria attributes for *Payments Collected* report
    attr_accessor :from_date, :to_date, :client_id, :payment_method

    # attributes for *Revenue by Clients* report
    attr_accessor :year

    def initialize(options={})
      Rails.logger.debug "--> Criteria init... #{options.to_yaml}"
      options ||= {} # if explicitly nil is passed then convert it to empty hash
      @from_date = (options[:from_date] || 1.month.ago).to_date # default for one month back from today
      @to_date = (options[:to_date] || Date.today).to_date # default to today
      @client_id = (options[:client_id] || 0).to_i # default to all i.e. 0
      @payment_method = (options[:payment_method] || "") # default to all i.e. ""

      @year = (options[:year] || Date.today.year).to_i # default to current year
      Rails.logger.debug "--> Criteria init... #{self.to_yaml}"
    end
  end
end