require 'date'
module Boc
  class Pay
    @@actionUrl = 'http://180.168.146.75:81/PGWPortal/RecvOrder.do'
    @@merchantNo = '104110059475555'
    @@payType = '1'
    @@curCode = '001'
    @@orderUrl = 'http://www.tld.com.cn/'

    attr_accessor :orderNo, :orderAmount, :orderTime, :orderNote, :orderTimeoutDate

    def initialize
      yield self if block_given?
    end

    def sign
      input = params.values.join('|')
      require 'open3'
      i,o = Open3.popen3('java -cp pkcs7.jar com.bocnet.common.security.P7Sign taobao.jks 11111111', chdir: __dir__ )
      i.write(input)
      i.close
      o.read
    end

    def get_form(submit_button= '<INPUT TYPE="submit" VALUE="中行支付">')
      post_params = params
      post_params[:signData] = sign
      form = ["<FORM METHOD='POST' ACTION='#{@@actionUrl}'>"]
      post_params.each do |k, v|
        form << "<INPUT TYPE='HIDDEN' NAME='#{k}' VALUE='#{v}'>"
      end
      form << submit_button
      form << '</FORM>'
      form.join
    end
    private
    def orderTime
      @orderTime || Time.now.strftime('%Y%m%d%H%M%S')
    end

    def orderTimeoutDate
      (DateTime.strptime(orderTime, '%Y%m%d%H%M%S') + 1.days).strftime('%Y%m%d%H%M%S')
    end

    def params
      {
        merchantNo: @@merchantNo,
        payType: @@payType,
        curCode: @@curCode,
        orderUrl: @@orderUrl,
        orderNo: orderNo,
        orderAmount: orderAmount,
        orderTime: orderTime,
        orderNote: orderNote,
        orderTimeoutDate: orderTimeoutDate
      }
    end
  end

  module OrderStatus
    Unpaid = '0'
    Paid = '1'
    Revocation = '2'
    Refund = '3'
    Unknown = '4'
    Failed = '5'
  end

  class Notify
    def initialize(params)
      @params = params
    end
    def verify
      sign_data = @params.delete :signData
      input = @params.values.join('|')
      require 'open3'
      stdin, stdout, stderr, wait_thr = Open3.popen3("java -cp pkcs7.jar com.bocnet.common.security.P7Verify BOCCA.cer '#{sign_data}'", chdir: __dir__ )
      stdin.write(input)
      stdin.close
      wait_thr.value == 0
    end
  end
end
