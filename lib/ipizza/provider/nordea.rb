module Ipizza::Provider
  
  # TODO: configure whether use sha-1 or md5 for signing and verification
  class Nordea
    
    require 'ipizza/provider/nordea/payment_request'
    require 'ipizza/provider/nordea/payment_response'
        
    class << self
      attr_accessor :service_url, :return_url, :reject_url, :cancel_url, :key, :rcv_id, :rcv_account, :rcv_name, :language, :confirm, :keyvers
    end
    
    def payment_request(payment, service = 1002)
      req = Ipizza::Provider::Nordea::PaymentRequest.new
      req.service_url = self.service_url
      req.params = {
        'VERSION' => '0003',
        'STAMP' => payment.stamp,
        'RCV_ID' => self.class.rcv_id,
        # 'RCV_ACCOUNT' => self.rcv_account,
        # 'RCV_NAME' => self.rcv_name,
        'LANGUAGE' => self.language,
        'AMOUNT' => sprintf('%.2f', payment.amount),
        'REF' => Ipizza::Util.sign_731(payment.refnum),
        'DATE' => 'EXPRESS',
        'MSG' => payment.message,
        'CONFIRM' => self.class.confirm,
        'CUR' => payment.currency,
        'KEYVERS' => self.class.keyvers,
        'REJECT' => self.class.reject_url,
        'RETURN' => self.class.return_url,
        'CANCEL' => self.class.cancel_url
      }
      
      req.sign(self.class.key)
      req
    end
    
    def payment_response(params)
      response = Ipizza::Provider::Nordea::PaymentResponse.new(params)
      response.provider = Ipizza::Util::NORDEA
      response.verify(self.class.key)
      
      return response
    end
  end
end
