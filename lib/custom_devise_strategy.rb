# -*- encoding : utf-8 -*-
require 'devise/strategies/base'

module SignInAs
  module Concerns
    module RememberAdmin
      extend ActiveSupport::Concern

      protected

      def remember_admin_id
        request.env['rack.session']['devise.remember_admin_user_id']
      end

      def remember_admin_id=(id)
        request.env['rack.session']['devise.remember_admin_user_id'] = id
      end

      def remember_admin_id?
        request.env['rack.session'] && request.env['rack.session']['devise.remember_admin_user_id'].present?
      end

      def clear_remembered_admin_id
        request.env['rack.session']['devise.remember_admin_user_id'] = nil
      end
    end
  end
end

module SignInAs
  module Devise
    module Strategies
      class FromAdmin < ::Devise::Strategies::Base
        include SignInAs::Concerns::RememberAdmin

        def valid?
          remember_admin_id?
        end

        def authenticate!
          resource = User.find(remember_admin_id)
          if resource
            clear_remembered_admin_id
            success!(resource)
          else
            pass
          end
        end
      end
    end
  end
end
