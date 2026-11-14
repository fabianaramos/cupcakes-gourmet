import { Controller } from "@hotwired/stimulus"

const PATTERNS = {
  cpf: (d) => d.slice(0, 11).replace(/(\d{3})(\d)/, "$1.$2").replace(/(\d{3})(\d)/, "$1.$2").replace(/(\d{3})(\d{1,2})$/, "$1-$2"),
  cep: (d) => d.slice(0, 8).replace(/(\d{5})(\d)/, "$1-$2"),
  phone: (d) => {
    d = d.slice(0, 11)
    if (d.length <= 2) return d.replace(/(\d{1,2})/, "($1")
    if (d.length <= 6) return d.replace(/(\d{2})(\d+)/, "($1) $2")
    if (d.length <= 10) return d.replace(/(\d{2})(\d{4})(\d+)/, "($1) $2-$3")
    return d.replace(/(\d{2})(\d{5})(\d+)/, "($1) $2-$3")
  }
}

export default class extends Controller {
  static values = { pattern: String }

  connect() { this.format() }

  format() {
    const fn = PATTERNS[this.patternValue]
    if (!fn) return
    const digits = this.element.value.replace(/\D/g, "")
    this.element.value = digits ? fn(digits) : ""
  }
}
