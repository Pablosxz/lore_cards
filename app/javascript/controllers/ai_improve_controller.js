import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "button", "spinner", "error"]
  static values  = { url: String, mode: { type: String, default: "enhance" } }

  async improve() {
    const text = this.textareaTarget.value.trim()
    if (!text) return

    this.setLoading(true)
    this.clearError()

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ text, mode: this.modeValue })
      })

      const data = await response.json()

      if (!response.ok || data.error) {
        this.showError(data.error || "Erro desconhecido.")
      } else {
        this.textareaTarget.value = data.improved_text
        // Dispara eventos para Stimulus controllers de preview (coleções/campanhas)
        this.textareaTarget.dispatchEvent(new Event("input", { bubbles: true }))
      }
    } catch (e) {
      this.showError("Falha na conexão com a API.")
    } finally {
      this.setLoading(false)
    }
  }

  setLoading(loading) {
    this.buttonTarget.disabled = loading
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.toggle("hidden", !loading)
    }
    this.buttonTarget.querySelector("[data-label]")?.classList.toggle("hidden", loading)
  }

  showError(msg) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = msg
      this.errorTarget.classList.remove("hidden")
    }
  }

  clearError() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ""
      this.errorTarget.classList.add("hidden")
    }
  }
}
