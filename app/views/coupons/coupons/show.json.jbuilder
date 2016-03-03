json.coupon do
  json.extract! @coupon, :id, :code, :description, :valid_from, :valid_until, :redemption_limit, :coupon_redemptions_count, :amount, :type
end
