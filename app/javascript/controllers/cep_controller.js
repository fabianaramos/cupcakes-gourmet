import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cep", "street", "neighborhood", "city", "state", "number", "status"]

  async lookup() {
    const cep = this.cepTarget.value.replace(/\D/g, "")
    if (cep.length !== 8 || cep === this.lastCep) return
    this.lastCep = cep
    this.say("Buscando endereço...")
    try {
      const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
      const data = await response.json()
      if (data.erro) return this.say("CEP não encontrado. Preencha o endereço manualmente.")
      this.fill(this.streetTarget, data.logradouro)
      this.fill(this.neighborhoodTarget, data.bairro)
      this.fill(this.cityTarget, data.localidade)
      this.fill(this.stateTarget, data.uf)
      this.say("Endereço preenchido pelo CEP. Confira e informe o número.")
      this.numberTarget.focus()
    } catch {
      this.say("Não foi possível buscar o CEP agora. Preencha o endereço manualmente.")
    }
  }

  fill(field, value) {
    if (value) field.value = value
  }

  say(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message
  }
}
