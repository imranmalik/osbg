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
  module Dashboard

    # get the recent activity - 10 most recent items
    def self.get_recent_activity
      # columns returned: activity type, client, amount, activity date
      # fetch last 10 invoices and payments
      invoices = Invoice.select("id, client_id, invoice_total, created_at").order("created_at DESC").limit(5)
      payments = Payment.select("payments.id, clients.organization_name, payments.payment_amount, payments.created_at").includes(:invoice => :client).joins(:invoice => :client).order("payments.created_at DESC").limit((10 - invoices.length))

      # merge invoices and payments in activity array
      recent_activity = []
      invoices.each { |inv| recent_activity << {:activity_type => "invoice", :activity_action => "sent to", :client => "#{inv.client.organization_name}", :amount => inv.invoice_total, :activity_date => inv.created_at, :activity_path => "/invoices/#{inv.id}/edit"} }
      payments.each { |pay| recent_activity << {:activity_type => "payment", :activity_action => "received from", :client => pay.invoice.client.organization_name, :amount => pay.payment_amount, :activity_date => pay.created_at, :activity_path => "/payments/#{pay.id}/edit"} }

      # sort them by created_at in descending order
      recent_activity.sort { |a, b| b[:created_at] <=> a[:created_at] }
    end

    # get chart data
    def self.get_chart_data
      # month, invoices amount, payments amount
      number_of_months = 6
      chart_months = {}
      start_date = (number_of_months * -1).months.from_now.to_date.at_beginning_of_month
      end_date = Date.today.at_end_of_month
      # build a hash of months with nil amounts
      number_of_months.times { |i| chart_months[(start_date + (i+1).month).month] = nil }

      # invoices amount group by month for last *number_of_months* months
      invoices = Invoice.group("month(invoice_date)").where(:invoice_date => start_date..end_date).sum("invoice_total")
      # TODO: credit amount handling
      payments = Payment.group("month(payment_date)").where(:payment_date => start_date..end_date).sum("payment_amount")

      chart_data = {}
      chart_data[:invoices] = chart_months.merge(invoices).map { |month, amount| amount.to_f }
      chart_data[:payments] = chart_months.merge(payments).map { |month, amount| amount.to_f }
      chart_data[:ticks] = chart_months.map { |month, amount| Date::ABBR_MONTHNAMES[month] }
      chart_data
    end

    # get outstanding invoices
    def self.get_outstanding_invoices
      Invoice.total_invoices_amount - Payment.total_payments_amount
    end

    def self.get_aging_data
      aged_invoices = Invoice.find_by_sql(<<-eos
          SELECT zero_to_thirty, thirty_one_to_sixty, sixty_one_to_ninety, ninety_one_and_above
          FROM (
            SELECT
              SUM(CASE WHEN aged.age BETWEEN 0 AND 30 THEN aged.invoice_total - aged.payment_received ELSE 0 END) AS zero_to_thirty,
              SUM(CASE WHEN aged.age BETWEEN 31 AND 60 THEN aged.invoice_total - aged.payment_received ELSE 0 END) AS thirty_one_to_sixty,
              SUM(CASE WHEN aged.age BETWEEN 61 AND 90 THEN aged.invoice_total - aged.payment_received ELSE 0 END) AS sixty_one_to_ninety,
              SUM(CASE WHEN aged.age > 90 THEN aged.invoice_total - aged.payment_received ELSE 0 END) AS ninety_one_and_above,
              0 AS client_total
            FROM (
              SELECT
                clients.organization_name AS client_name,
                invoices.invoice_total,
                IFNULL(SUM(payments.payment_amount), 0) payment_received,
                DATEDIFF('#{Date.today}', DATE(IFNULL(invoices.due_date, invoices.invoice_date))) age,
                invoices.`status`
              FROM `invoices`
                INNER JOIN `clients` ON `clients`.`id` = `invoices`.`client_id`
                LEFT JOIN `payments` ON `invoices`.`id` = `payments`.`invoice_id` AND (payments.payment_date <= '#{Date.today}') AND (`payments`.`deleted_at` IS NULL)
              WHERE
                (`invoices`.`deleted_at` IS NULL)
                AND (DATE(IFNULL(invoices.due_date, invoices.invoice_date)) <= '#{Date.today}')
                AND (invoices.`status` != "paid")
              GROUP BY clients.organization_name,  invoices.invoice_total, invoices.`status`, invoices.invoice_number
            ) AS aged
          ) total_aged
      eos
      ).first
    end
    # get outstanding invoices by period
    def self.get_invoices_by_period1 period
      start_date, end_date = 0, 0
      case period
        when '0-30' then
          start_date = Date.today - 30.days
          end_date = Date.today
        when '30-60' then
          start_date = Date.today - 60.days
          end_date = Date.today - 31.days
        when '60-90' then
          start_date = Date.today - 90.days
          end_date = Date.today - 61.days
        when 'over-90' then
          end_date = Date.today - 90.days
          invoices = Invoice.where("invoice_date < '#{end_date}'").sum("invoice_total")
          payments = Payment.where("payment_date < '#{end_date}'", :payment_type => "is null or payment_type != 'credit'").sum("payment_amount")
      end
      unless period == "over-90"
        invoices = Invoice.where(:invoice_date => start_date..end_date).sum("invoice_total")
        payments = Payment.where(:payment_date => start_date..end_date, :payment_type => "is null or payment_type != 'credit'").sum("payment_amount")
      end
      invoices - payments
    end
  end
end