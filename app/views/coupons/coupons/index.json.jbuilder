json.coupons do
  json.array! @coupons, :id, :code, :description, :valid_from, :valid_until, :redemption_limit, :coupon_redemptions_count, :amount, :type
end
