require "net/http"
require "uri"
require "json"

class LeonardoImageGenerationService
  GENERATIONS_ENDPOINT = "https://cloud.leonardo.ai/api/rest/v1/generations".freeze
  MODEL_ID = "b2614463-296c-462a-9586-aafdb8f00e36".freeze
  DEFAULT_WIDTH = 512
  DEFAULT_HEIGHT = 512
  DEFAULT_NUM_IMAGES = 1
  DEFAULT_POLL_ATTEMPTS = 10
  DEFAULT_POLL_INTERVAL_SECONDS = 2

  def initialize(api_key: ENV["LEONARDO_API_KEY"])
    @api_key = api_key
  end

  def call(prompt:, width: DEFAULT_WIDTH, height: DEFAULT_HEIGHT, num_images: DEFAULT_NUM_IMAGES)
    prompt_text = prompt.to_s.strip
    return failure("Chave da API do Leonardo.ai não configurada.", :internal_server_error) if @api_key.blank?
    return failure("A descrição para gerar a imagem é obrigatória.", :bad_request) if prompt_text.blank?

    uri = URI(GENERATIONS_ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request.body = {
      prompt: prompt_text,
      modelId: MODEL_ID,
      width: width,
      height: height,
      num_images: num_images
    }.to_json

    response = http.request(request)
    parsed_response = JSON.parse(response.body)

    unless response.code == "200"
      error = parsed_response["error"] || response.message
      return failure("Erro na API do Leonardo: #{error}", :bad_request)
    end

    generation_id = parsed_response.dig("sdGenerationJob", "generationId")
    return failure("Não foi possível iniciar a geração no Leonardo.ai.", :bad_request) if generation_id.blank?

    image_url = poll_generated_image(http: http, generation_id: generation_id)
    return success(image_url) if image_url.present?

    failure("A geração da imagem expirou ou falhou.", :request_timeout)
  rescue StandardError => e
    failure("Erro inesperado: #{e.message}", :internal_server_error)
  end

  private

  def poll_generated_image(http:, generation_id:)
    DEFAULT_POLL_ATTEMPTS.times do
      sleep DEFAULT_POLL_INTERVAL_SECONDS

      status_uri = URI("https://cloud.leonardo.ai/api/rest/v1/generations/#{generation_id}")
      status_request = Net::HTTP::Get.new(status_uri)
      status_request["Authorization"] = "Bearer #{@api_key}"
      status_request["Accept"] = "application/json"

      status_response = http.request(status_request)
      status_payload = JSON.parse(status_response.body)
      images = status_payload.dig("generations_by_pk", "generated_images")

      next if images.blank?

      first_url = images.first["url"].to_s
      return first_url if first_url.present?
    end

    nil
  end

  def success(image_url)
    { success: true, image_url: image_url }
  end

  def failure(error_message, status)
    { success: false, error: error_message, status: status }
  end
end
