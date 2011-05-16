class DealObserver < ActiveRecord::Observer
  def before_revert(record)
  end

  def before_close(record)
  end

  def before_convert(record)
    if email = record.offer && record.offer.conversion_alert_email.presence
      Rails.logger.debug("Sending Offer Conversion Alert to [#{email}]")
      Offer.conversion_email.try(:send!, email)
    end
  end
end
