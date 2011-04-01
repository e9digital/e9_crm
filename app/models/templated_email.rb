class EmailTemplate < Email
  def clone
    super.tap do |klone|
      klone.name = "#{klone.name} - #{DateTime.now.to_i}"
    end
  end
end
