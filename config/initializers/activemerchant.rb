require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'

ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
ActiveMerchant::Billing::Base.integration_mode = Rails.env.production? ? :production : :test # :production for production