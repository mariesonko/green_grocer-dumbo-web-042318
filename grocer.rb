def consolidate_cart(cart)
  final_cart = {}
  cart.each do |item|
    item.each do |item_name, item_hash|
        if final_cart.key?(item_name) == false
          final_cart[item_name] = item_hash
          final_cart[item_name][:count] = 1
        else
          final_cart[item_name][:count] += 1
        end
    end
  end
  final_cart
end

def apply_coupons(cart, coupon_array)

  if cart.size == 0
    return cart
  elsif coupon_array.size == 0
    return cart
  else
    final_coupons = {}
    coupon_array.each do |coupon|
      item_name = coupon[:item]
      if final_coupons.key?(item_name) == false
        coupon = coupon.merge({coupon_count: 1})
        final_coupons[item_name] = coupon
      else
          final_coupons[item_name][:num] += coupon[:num]
          final_coupons[item_name][:coupon_count] += 1
      end
    end
    final_coupons.each do |new_key, value|
      if cart.key?(new_key)
        new_coupon_number = final_coupons[new_key][:num]
        cart_item_count = cart[new_key][:count]
        coupon_item_price = final_coupons[new_key][:cost]
        coupon_count = final_coupons[new_key][:coupon_count]
        cart_item_count_after_coupon = cart_item_count - new_coupon_number
        cart_item_clearance = cart[new_key][:clearance]

        cart[new_key][:count] = cart_item_count_after_coupon
        cart["#{new_key} W/COUPON"] = {price: coupon_item_price, clearance: cart_item_clearance, count: coupon_count}


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
    if !item.include?('W/COUPON')
      if clearance_applied[item][:count] < clearance_applied["#{item} W/COUPON"][:count]
        clearance_applied["#{item} W/COUPON"][:count] = clearance_applied[item][:count]
      end
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
