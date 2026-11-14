import { Controller } from "@hotwired/stimulus"

// Mostra a prévia da imagem do cupcake enquanto o admin escolhe a foto ou cola o link.
export default class extends Controller {
  static targets = ["input", "frame", "img", "status"]
  static values = { photos: Object }

  connect() {
    this.imgTarget.addEventListener("load", () => { this.imgTarget.hidden = false; this.statusTarget.textContent = "" })
    this.imgTarget.addEventListener("error", () => { this.imgTarget.hidden = true; this.statusTarget.textContent = "Não foi possível carregar a imagem desse endereço." })
    this.update()
  }

  update() {
    const value = this.inputTarget.value.trim()
    const src = this.photosValue[value] || (/^https?:\/\/\S+$/.test(value) ? value : null)
    this.frameTarget.hidden = !src
    if (src && this.imgTarget.getAttribute("src") !== src) {
      this.statusTarget.textContent = "Carregando prévia..."
      this.imgTarget.src = src
    }
  }
}
