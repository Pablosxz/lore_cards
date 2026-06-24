require "net/http"
require "uri"
require "json"

class PromptSanitizerService
  GEMINI_MODEL = "gemini-1.5-flash".freeze
  GEMINI_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/#{GEMINI_MODEL}:generateContent".freeze
  OPEN_TIMEOUT_SECONDS = 5
  READ_TIMEOUT_SECONDS = 20
  DEFAULT_CONTEXT = :card_item
  VALID_CONTEXTS = %i[card_item card_monster collection].freeze

  ITEM_FALLBACK_PROMPT = "A single high-quality 2D digital illustration of a fantasy RPG item inspired by: %{input}. The object is visually striking, polished, and clearly centered. Isolated on a solid dark background. Dungeons and dragons item asset, RPG concept art, vibrant colors, masterpiece, high detail.".freeze
  MONSTER_FALLBACK_PROMPT = "A single high-quality 2D digital illustration of a fantasy RPG monster inspired by: %{input}. The creature has a dramatic silhouette, distinctive anatomy, and threatening details. Isolated on a solid dark background. Dungeons and dragons monster asset, RPG concept art, vibrant colors, masterpiece, high detail.".freeze
  COLLECTION_FALLBACK_PROMPT = "A high-quality 2D key art illustration for a fantasy RPG collection inspired by: %{input}. A cohesive thematic scene with atmosphere, landmarks, and strong visual identity. Cinematic composition, Dungeons and dragons worldbuilding key art, RPG concept art, vibrant colors, masterpiece, high detail.".freeze

  def initialize(user_input, context: DEFAULT_CONTEXT)
    @user_input = user_input.to_s.strip
    @context = normalize_context(context)
  end

  def call
    return fallback_prompt if @user_input.blank?

    api_key = ENV["GEMINI_API_KEY"]
    return fallback_prompt if api_key.blank?

    uri = URI("#{GEMINI_ENDPOINT}?key=#{api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = OPEN_TIMEOUT_SECONDS
    http.read_timeout = READ_TIMEOUT_SECONDS

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = build_payload.to_json

    response = http.request(request)
    return fallback_prompt unless response.code.to_i.between?(200, 299)

    parsed = JSON.parse(response.body)
    generated = parsed.dig("candidates", 0, "content", "parts", 0, "text").to_s.strip
    return fallback_prompt if generated.blank?

    normalize_output(generated)
  rescue Timeout::Error, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, Net::OpenTimeout, Net::ReadTimeout, JSON::ParserError, StandardError
    fallback_prompt
  end

  private

  def build_payload
    {
      system_instruction: {
        parts: [
          {
            text: system_instruction_for_context
          }
        ]
      },
      contents: [
        {
          role: "user",
          parts: [
            {
              text: "Entrada do usuario em portugues: #{@user_input}"
            }
          ]
        }
      ],
      generation_config: {
        temperature: 0.6,
        top_p: 0.9,
        max_output_tokens: 220
      }
    }
  end

  def fallback_prompt
    fallback_input = @user_input.presence || "a fantasy magical subject"

    template = case @context
    when :collection
      COLLECTION_FALLBACK_PROMPT
    when :card_monster
      MONSTER_FALLBACK_PROMPT
    else
      ITEM_FALLBACK_PROMPT
    end

    format(template, input: fallback_input)
  end

  def system_instruction_for_context
    base_rules = <<~RULES
      The user input is in Portuguese, but you must return output only in English.
      Do not chat, explain, add labels, markdown, or quotes.
      Return only the final single prompt string.
    RULES

    case @context
    when :collection
      <<~INSTRUCTION
        You are an expert RPG worldbuilding art curator for collection key art.
        #{base_rules}
        Follow this exact formula:
        [Collection Key Art Type] + [Detailed Environment and Theme based on user input] + [Cinematic Scene Composition] + [Dungeons and dragons worldbuilding key art, RPG concept art, vibrant colors, masterpiece, high detail].

        Example:
        Input: reino congelado ancestral
        Output: A high-quality 2D fantasy collection key art of an ancient frozen kingdom. Towering ice citadels, ruined stone bridges, and drifting snowstorms surround glowing runic monuments. Cinematic wide composition with layered depth and dramatic lighting. Dungeons and dragons worldbuilding key art, RPG concept art, vibrant colors, masterpiece, high detail.
      INSTRUCTION
    when :card_monster
      <<~INSTRUCTION
        You are an expert RPG card art curator for monster illustrations.
        #{base_rules}
        Follow this exact formula:
        [Type of Creature Asset] + [Detailed Physical Description based on user input] + [Isolated on a solid dark background] + [Dungeons and dragons monster asset, RPG concept art, vibrant colors, masterpiece, high detail].

        Example:
        Input: lobo sombrio com chifres
        Output: A single high-quality 2D digital illustration of a horned shadow wolf. Dense black fur, ember-red eyes, and jagged obsidian horns rise from its skull. Isolated on a solid dark background. Dungeons and dragons monster asset, RPG concept art, vibrant colors, masterpiece, high detail.
      INSTRUCTION
    else
      <<~INSTRUCTION
        You are an expert RPG card art curator for item illustrations.
        #{base_rules}
        Follow this exact formula:
        [Type of Asset] + [Detailed Physical Description based on user input] + [Isolated on a solid dark background] + [Dungeons and dragons item asset, RPG concept art, vibrant colors, masterpiece, high detail].

        Example:
        Input: espada flamejante
        Output: A single high-quality 2D digital illustration of a blazing broadsword. The blade is forged from jagged dark iron, engulfed in roaring magical fire. The hilt is wrapped in charred leather. Isolated on a solid dark background. Dungeons and dragons item asset, RPG concept art, vibrant colors, masterpiece, high detail.
      INSTRUCTION
    end
  end

  def normalize_context(context)
    candidate = context.to_s.downcase.to_sym
    VALID_CONTEXTS.include?(candidate) ? candidate : DEFAULT_CONTEXT
  end

  def normalize_output(text)
    cleaned = text.gsub(/\A["'`\s]+|["'`\s]+\z/, "").squish
    cleaned.ends_with?(".") ? cleaned : "#{cleaned}."
  end
end
