module CertificationStatusHelper
  def certification_status_badge(certification)
    status = certification.status
    days = certification.days_until_expiry

    case status
    when :expired
      content_tag(:span, 'Просрочен',
                  class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800')
    when :critical
      content_tag(:span, "#{days} дн.",
                  class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800')
    when :attention
      content_tag(:span, "#{days} дн.",
                  class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800')
    when :valid
      content_tag(:span, 'Действует',
                  class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800')
    else
      content_tag(:span, 'Неизвестно',
                  class: 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800')
    end
  end

  def certification_status_text(certification)
    case certification.status
    when :expired
      'Просрочен'
    when :critical
      "Критично (#{certification.days_until_expiry} дн.)"
    when :attention
      "Внимание (#{certification.days_until_expiry} дн.)"
    when :valid
      'Действует'
    else
      'Неизвестно'
    end
  end
end
