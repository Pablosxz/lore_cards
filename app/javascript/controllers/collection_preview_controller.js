import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["namePreview", "descriptionPreview"]

  updateName(event) {
    const value = event.target.value.trim()
    this.namePreviewTargets.forEach(el => {
      el.textContent = value || "Nome da coleção"
    })
  }

  updateDescription(event) {
    const value = event.target.value.trim()
    this.descriptionPreviewTargets.forEach(el => {
      el.textContent = value || "Descrição da coleção"
    })
  }
}
