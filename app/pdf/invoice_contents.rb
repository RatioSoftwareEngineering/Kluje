class InvoiceContents
  def initialize(invoice, current_account)
    @invoice = invoice
    @account = current_account
  end

  def img
    "#{Rails.root}/app/assets/images/logos/kluje_pdf.png"
  end

  def invoice_no
    "Invoice No: #{@invoice.id}"
  end

  def date
    "Date: #{@invoice.updated_at.strftime("%d-%b-%Y")}"
  end

  def from
    "From:\n Kluje Pte Ltd,\n 73 Loewen Road, #01-21 Singapore\n 248843"
  end

  def billto
    if @account.agent?
      "Bill to:
      #{@account.bill_to}"
    else
      "Bill to:
      #{@account.bill_to}
      #{@account.contractor.company_address}
      #{@account.contractor.company_postal_code}"
    end
  end

  def paid?
    @invoice.paid
  end

  def list_data
    currency = @invoice.currency.upcase + ' '
    if @account.agent?
      commission = format('%.2f', @invoice.amount * Fee::PARTNER_COMMISSION_RATE)
    else
      commission = format('%.2f', @invoice.amount * @invoice.job.commission_rate / 100)
    end

    data = [['Description', 'Job Invoice Amount', 'Commission Total'],
     ["Commision to be paid for completed job # #{@invoice.job.id}", currency + format('%.2f', @invoice.amount), currency + commission ],
     ['','Total including VAT:', currency + commission ]]

    data[2][0] = 'PAID' if @invoice.paid?
    data
  end

  def subscription_list_data
    price = @invoice.currency.upcase + ' ' + format('%.2f', @invoice.price)
    period = '(' + (@invoice.expired_at-1.month+1.day).strftime("%d/%m/%Y")\
      + ' - ' + @invoice.expired_at.strftime("%d/%m/%Y") + ')'

    [['Description', 'Monthly Subscription Amount'],
     ["Subscription " + period, price],
     ['Total including VAT:', price]]
  end

  def payment_data
    return nil if self.paid?
    [["Payment details:"],
      ["Cheques should be crossed and made payable to KLUJE PTE LTD or monies transfered to:
      Account Name: KLUJE PTE LTD.
      Account Number: 626029227001
      BIC Code: OCBCSGSGXXX
      BIC Name: OVERSEA - CHINESE BANKING CORPORATION
      Reference number: #{@account.contractor.id}"],
      ["Please supply Reference number #{@account.contractor.id} as a reference when making a payment. This is so that we can track your payment.
    "]]
  end

  def tc_data
    data = [["Terms and Conditions"],
            ["The amount invoiced indicates the commission amount owed by the Contractor to Kluje arising from the invoiced Project and pursuant to the Kluje Terms and Conditions
The Contractor shall pay the amount under this invoice without any counterclaims, set offs or deductions, within thirty (30) days of the date of the invoice. The Contractor shall be liable to pay interest on all invoiced sums which remain unpaid after their due date at the rate of 1.5% for each month of delay till payment.
All transactions under this invoice and these terms shall be governed by and constructed according to the laws of Singapore and the parties submit to the non-exclusive jurisdiction of the courts in Singapore.
Nothing herein confers or purports to confer on any third party any bene t or any right to enforce any of the rights accruing from these Terms pursuant to the Contracts (Rights of Third Parties) Act, Cap. 53B. This is for the commission paid to the Partner, the 2% from the invoice amount."]]

    if @invoice.paid?
      data[1][0] = "The invoice amount represents the commission amount due from the Contractor to the Partner (as de ned in the *Terms and Conditions for Referral Program) Upon receipt of the amount indicated in this invoice, the Contractor’s obligation in respect of the Partner’s commission arising from the invoiced Project is discharged and Kluje shall make the requisite payment to the relevant Partner forthwith.
The Contractor shall pay the amount indicated in the invoice without any counterclaims, set offs or deductions, within thirty (30) days of the date of the invoice. The Contractor shall be liable to pay interest on all invoiced sums which remain unpaid after their due date at the rate of 1.5% for each month of delay till payment.
All transactions under this invoice and these terms shall be governed by and constructed according to the laws of Singapore and the parties submit to the non-exclusive jurisdiction of the courts in Singapore. Noth- ing herein confers or purports to confer on any third party any bene t or any right to enforce any of the rights accruing from these Terms pursuant to the Contracts (Rights of Third Parties) Act, Cap. 53B"
    end
    data
  end

  def footer_data
    [["Kluje Pte Ltd 73 Loewen Road, #01-21 Singapore 248843
    Registration No.: 201313800W"]]
  end
end
