class InvoicePDF < Prawn::Document

  def initialize(invoice, current_account)
    super(page_size: 'A4', page_layout: :portrait)
    @contents = InvoiceContents.new(invoice, current_account)
    header
    addresss
    list
    payment
    tc
    footer
  end

  private

  def header
    table [['INVOICE']], cell_style: { size: 30, width: bounds.width, align: :right } do
      cells.padding = 10
      cells.border_width = 0
      cells.background_color = "f8a747"
      cells.text_color = "ffffff"
    end

    image @contents.img, width: 140, padding: 10

    bounding_box([0, 710], width: bounds.width, height: 50, align: :right) do
      font_size 10.5
      text @contents.invoice_no, align: :right
      move_down 2
      text @contents.date, align: :right
    end
  end

  def addresss
    table [[@contents.from, @contents.billto]] , cell_style: { height: 80, leading: 2 } do
      self.column_widths = [260, 260]
    end
  end

  def list
    move_down 18
    paid = @contents.paid?

    table @contents.list_data do
      cells.borders = [:bottom]
      cells.border_width = 0.5
      cells.border_colors = "999999"
      cells.padding = 8
      row(0).background_color = "f8a747"
      row(0).borders = []
      row(-1).font_style = :bold
      self.column_widths = [260, 130, 130]
      if paid
        style(row(2).column(0), background_color: "17a754", align: :center, text_color: "ffffff", size: 16)
      end
    end
  end

  def payment
    move_down 10
    if @contents.payment_data.present?
      table @contents.payment_data, cell_style: { leading: 4 } do
        cells.borders = []
        row(0).font_style = :bold
        row(-1).font_style = :bold
        row(-1).borders = [:bottom]
        row(-1).border_width = 0.5
        row(-1).border_colors = "f8a747"
      end
    end
  end

  def tc
    move_down 30

    table @contents.tc_data do
      cells.borders = []
      row(0).font_style = :bold
    end

    if @contents.paid?
      text "* <link href='https://kluje.com/en/legal/terms-and-conditions-for-referral-program'>Terms and Conditions for Referral Program</link>", :inline_format => true
    end
  end

  def footer
    bounding_box([0, 30], width: bounds.width, height: 50, align: :center) do
      table @contents.footer_data, cell_style: { size: 10, width: bounds.width, align: :center } do
        row(0).background_color = "f8a747"
        row(0).borders = []
        row(0).font_style = :bold
        row(0).text_color = "ffffff"
      end
    end
  end
end
