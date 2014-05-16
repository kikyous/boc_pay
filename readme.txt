#  获取支付form
    @boc_form = Boc::Pay.new do |pay|
      pay.orderNo = params[:orderId]
      pay.orderAmount = params[:orderAmount].to_i / 100
      pay.orderNote = '租车费'
    end.get_form

#  验证中行支付通知
    # pay controller
    # TYPE POST
    def boc_notify
      notify_params = params.except(*request.path_parameters.keys)

      verify = Boc::Notify.new(notify_params).verify
      if verify
        case params[:orderStatus]
        when Boc::OrderStatus::Paid
          # 支付成功，改变订单状态
        else
          # do nothing
        end
      end
    end
