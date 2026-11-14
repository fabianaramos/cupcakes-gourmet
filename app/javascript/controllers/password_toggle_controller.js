import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button"]

  toggle() {
    const showing = this.inputTarget.type === "text"
    this.inputTarget.type = showing ? "password" : "text"
    this.buttonTarget.setAttribute("aria-pressed", String(!showing))
    this.buttonTarget.setAttribute("aria-label", showing ? "Mostrar senha" : "Ocultar senha")
    this.inputTarget.focus()
  }
}
