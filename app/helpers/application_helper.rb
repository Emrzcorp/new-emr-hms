module ApplicationHelper

  def appointment_status_class(status)
    case status
    when "completed"
      "bg-success-subtle border-start border-4 border-success"
    when "confirmed"
      "bg-primary-subtle border-start border-4 border-primary"
    when "pending"
      "bg-light border-start border-4 border-secondary"
    else
      "bg-light"
    end
  end

  def status_badge_class(status)
    case status
    when "completed"
      "bg-success"
    when "confirmed"
      "bg-primary"
    when "pending"
      "bg-secondary"
    else
      "bg-light text-dark"
    end
  end

  def activity_color(type)
    case type
    when "lab" then "bg-success-subtle"
    when "treatment" then "bg-warning-subtle"
    else "bg-light"
    end
  end

  def activity_icon(type)
    case type
    when "lab" then "fa-vial"
    when "treatment" then "bi bi-activity"
    else "fa-info-circle"
    end
  end

end