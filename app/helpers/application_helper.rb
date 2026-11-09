module ApplicationHelper
  def money(value) = number_to_currency(value || 0)

  def stars(rating)
    return "" if rating.nil?
    full = rating.round
    content_tag(:span, ("★" * full) + ("☆" * (5 - full)), class: "stars", title: "#{rating} de 5", aria: { label: "#{rating} de 5 estrelas" })
  end

  def product_image(product, css = "thumb")
    if product.image_url.present?
      image_tag(product.image_url, alt: product.name, class: css, loading: "lazy")
    else
      hue = (product.id.to_i * 47) % 360
      content_tag(:div, "🧁", class: "#{css} placeholder", style: "--hue: #{hue}", role: "img", aria: { label: product.name })
    end
  end

  def status_badge(order)
    content_tag(:span, order.status_label, class: "badge status-#{order.status}")
  end

  def error_summary(record)
    return unless record&.errors&.any?
    content_tag(:div, class: "error-box", role: "alert") do
      content_tag(:strong, "Corrija os campos abaixo:") +
        content_tag(:ul) { safe_join(record.errors.full_messages.map { |m| content_tag(:li, m) }) }
    end
  end
end
