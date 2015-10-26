require_relative 'menu'
require 'twilio-ruby'

class Takeaway
  attr_reader :menu, :basket, :total

  def initialize(menu_klass = Menu.new)
    @menu = menu_klass
    @basket = Hash.new(0)
  end

  def open_menu
    menu.open
  end

  def order(item, quantity = 1)
    basket[item] += quantity
    "#{quantity}x #{item}(s) added to your basket."
  end

  def basket_summary
    basket.map { |item, quantity| "#{item} x#{quantity} = #{'£%.2f' % (menu.dishes[item] * quantity)}" }.join(', ')
  end

  def total
    @total = basket.map { |item, quantity| menu.dishes[item] * quantity }.inject(:+) unless basket.empty?
    "Total: #{'£%.2f' % @total}"
  end

  def checkout(amount = 0)
    fail "Total cost does not match the sum of the dishes in your order!" if amount != total
    send_text
  end

  def send_text
    account_sid = "PN2ba53d6e4525039c3c3c17ebb2bc2a15"
    auth_token = "d8bfb8790ec316cd64d6d254a4bcc6c6"

    @client = Twilio::REST::Client.new account_sid, auth_token
    @time = (Time.now + (60*60)).strftime("%H:%M")
    @message = @client.messages.create(
      to: "+375293069300",
      from: "+43676800505017",
      body: "Thank you! Your order was placed and will be delivered before #{@time}")
  end
end