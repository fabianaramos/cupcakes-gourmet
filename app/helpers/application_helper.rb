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
      content_tag(:div, product.name.first, class: "#{css} placeholder", style: "--hue: #{hue}", role: "img", aria: { label: product.name })
    end
  end

  def password_toggle(&block)
    eye = '<svg class="eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/></svg>' \
          '<svg class="eye-closed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 3l18 18"/><path d="M10.6 5.1A10.7 10.7 0 0 1 12 5c6.5 0 10 7 10 7a17 17 0 0 1-3.2 4.1M6.6 6.6A17.4 17.4 0 0 0 2 12s3.5 7 10 7a9.8 9.8 0 0 0 5.4-1.6"/><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"/></svg>'
    button = content_tag(:button, eye.html_safe, type: "button", class: "password-eye",
      aria: { label: "Mostrar senha", pressed: "false" },
      data: { password_toggle_target: "button", action: "password-toggle#toggle" })
    content_tag(:div, capture(&block) + button, class: "password-field", data: { controller: "password-toggle" })
  end

  def status_badge(order)
    content_tag(:span, order.status_label, class: "badge status-#{order.status}")
  end

  def error_summary(*records)
    messages = records.compact.flat_map { |r| r.errors.full_messages }
    return if messages.empty?
    content_tag(:div, class: "error-box", role: "alert") do
      content_tag(:strong, "Corrija os campos abaixo:") +
        content_tag(:ul) { safe_join(messages.map { |m| content_tag(:li, m) }) }
    end
  end
end
