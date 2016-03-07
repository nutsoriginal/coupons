class Coupons::ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  include Coupons::Models
  helper Coupons::ApplicationHelper

  include PageMeta::Helpers
  helper_method :page_meta

  before_action :authorize

  private

  def authorize
    Coupons.configuration.authorizer.call(self)
  end
end
