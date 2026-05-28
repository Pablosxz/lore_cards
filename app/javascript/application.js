// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
  // Seleciona os elementos que possuem o role='alert'
  const flashMessages = document.querySelectorAll("[role='alert']");
  
  flashMessages.forEach((msg) => {
    // Espera 4 segundos (4000ms) antes de iniciar o sumiço
    setTimeout(() => {
      msg.style.transition = "opacity 0.5s ease-out";
      msg.style.opacity = "0"; // Faz a transição de fade out
      
      // Remove completamente o elemento do HTML após terminar a animação
      setTimeout(() => msg.remove(), 500);
    }, 4000);
  });
});

// Substitui o alerta padrão (window.confirm) pelo modal customizado
Turbo.setConfirmMethod((message, element) => {
  let dialog = document.getElementById("turbo-confirm-dialog");
  
  // Injeta a mensagem que está no data-turbo-confirm="Sua mensagem aqui"
  dialog.querySelector("#turbo-confirm-message").textContent = message;
  dialog.classList.remove("hidden"); // Mostra o modal

  // Retorna uma Promise que o Turbo vai aguardar
  return new Promise((resolve, reject) => {
    dialog.querySelector("#turbo-confirm-accept").addEventListener("click", () => {
      dialog.classList.add("hidden");
      resolve(true); // Se clicou em confirmar, deixa a requisição DELETE seguir
    }, { once: true });

    dialog.querySelector("#turbo-confirm-cancel").addEventListener("click", () => {
      dialog.classList.add("hidden");
      resolve(false); // Se cancelou, bloqueia a requisição
    }, { once: true });
  });
});

// Escuta as submissões de formulário feitas pelo Turbo
document.addEventListener("turbo:submit-end", (event) => {
  // Se o formulário do modal retornou sucesso (sem erros de validação)
  if (event.detail.success && event.target.id === "modal-form") {
    // Recarrega a página atual de forma rápida e assíncrona
    Turbo.visit(window.location.href);
  }
});
