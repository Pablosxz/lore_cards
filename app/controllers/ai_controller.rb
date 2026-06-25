class AiController < ApplicationController
  before_action :authenticate_user!

  def improve_text
    text = params[:text].to_s.strip
    mode = params[:mode].to_s

    return render json: { error: "Texto vazio." }, status: :unprocessable_entity if text.blank?

    api_key = Rails.application.credentials.dig(:gemini, :api_key) ||
              ENV["GEMINI_API_KEY"]

    if api_key.blank?
      return render json: { error: "Chave da API não configurada." }, status: :service_unavailable
    end

    prompt = if mode == "fix"
      <<~PROMPT
        Corrija a ortografia, pontuação e semântica do texto abaixo sem alterar
        seu conteúdo ou tom. Mantenha o idioma original (português) e o tamanho
        aproximado do texto original. Retorne apenas o texto corrigido, sem
        explicações adicionais.

        Texto original:
        #{text}
      PROMPT
    else
      <<~PROMPT
        Você é um assistente criativo especializado em RPG de mesa e worldbuilding.
        Melhore o texto abaixo tornando-o mais descritivo, imersivo e adequado para
        um jogo de fantasia. Mantenha o idioma original (português) e um tamanho
        próximo ao original — enriqueça o conteúdo, não expanda indefinidamente.
        Retorne apenas o texto melhorado, sem explicações adicionais.

        Texto original:
        #{text}
      PROMPT
    end

    temperature = mode == "fix" ? 0.1 : 0.8
    response = call_gemini(api_key, prompt, temperature)

    if response[:error]
      render json: { error: response[:error] }, status: :bad_gateway
    else
      render json: { improved_text: response[:text] }
    end
  end

  private

  def call_gemini(api_key, prompt, temperature = 0.8)
    require "net/http"
    require "json"

    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{api_key}")

    body = {
      contents: [
        {
          parts: [ { text: prompt } ]
        }
      ],
      generationConfig: {
        temperature: temperature
      }
    }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30
    http.open_timeout = 10

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = body

    response = http.request(request)
    parsed = JSON.parse(response.body)

    if response.is_a?(Net::HTTPSuccess)
      text = parsed.dig("candidates", 0, "content", "parts", 0, "text").to_s.strip
      { text: text }
    else
      error_msg = parsed.dig("error", "message") || "Erro na API Gemini (#{response.code})"
      { error: error_msg }
    end
  rescue => e
    { error: "Erro de conexão: #{e.message}" }
  end
end
