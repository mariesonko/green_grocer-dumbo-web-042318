def consolidate_cart(cart)
  consolidated_hash = {}
  cart.each do |item|
    item.each do |item_name, item_hash|
        if consolidated_hash.key?(item_name) == false
          consolidated_hash[item_name] = item_hash
          consolidated_hash[item_name][:count] = 1
        else
          consolidated_hash[item_name][:count] += 1
        end
    end
  end
  consolidated_hash
end

def apply_coupons(cart, coupon_array)

  if cart.size == 0
    return cart
  elsif coupon_array.size == 0
    return cart
  else
    consolidated_coupons_hash = {}
    coupon_array.each do |coupon|
      item_name = coupon[:item]
      if consolidated_coupons_hash.key?(item_name) == false
        coupon = coupon.merge({coupon_count: 1})
        consolidated_coupons_hash[item_name] = coupon
      else
          consolidated_coupons_hash[item_name][:num] += coupon[:num]
          consolidated_coupons_hash[item_name][:coupon_count] += 1
      end
    end
    consolidated_coupons_hash.each do |consolidated_key, value|
      if cart.key?(consolidated_key)
        consolidated_coupon_number = consolidated_coupons_hash[consolidated_key][:num]
        cart_item_count = cart[consolidated_key][:count]
        coupon_item_price = consolidated_coupons_hash[consolidated_key][:cost]
        coupon_count = consolidated_coupons_hash[consolidated_key][:coupon_count]
        cart_item_count_after_coupon = cart_item_count - consolidated_coupon_number
        cart_item_clearance = cart[consolidated_key][:clearance]

        cart[consolidated_key][:count] = cart_item_count_after_coupon
        cart["#{consolidated_key} W/COUPON"] = {price: coupon_item_price, clearance: cart_item_clearance, count: coupon_count}


      end
    end
  end
  cart
end

def apply_clearance(cart)
  cart.each do |item_name, item_hash|
    if item_hash[:clearance] == true

      clearance_price = item_hash[:price] - (item_hash[:price] * 0.2)
      item_hash[:price] = clearance_price
    end
  end
  cart
end

def checkout(cart, coupons)
  total = 0
  cart = consolidate_cart(cart)
  coupons_applied = apply_coupons(cart, coupons)

  clearance_applied = apply_clearance(coupons_applied)

  clearance_applied.each do |item, item_hash|
    if item_hash[:count] < 0
      item_hash[:count] = -(item_hash[:count])
    end
    if !item.include?('W/COUPON')
      if clearance_applied[item][:count] < clearance_applied["#{item} W/COUPON"][:count]
        clearance_applied["#{item} W/COUPON"][:count] = clearance_applied[item][:count]
      end
    end

    total += (item_hash[:price] * item_hash[:count])
    puts total
  end
  if total >= 100
    total = total - (total *0.10)
  else
    total
  end
end
