module ApiExceptions
  class ApiException < StandardError; end
  class BadRequest < ApiException;  end
  class Unauthorized < ApiException;  end
  class NotFound < ApiException;  end
  class Forbidden < ApiException;  end
  class UnprocessableEntity < ApiException;  end
  class PaymentRequired < ApiException; end
end
