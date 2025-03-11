class PlansController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  def generate
    plan_type = params[:plan_type]
    user_input = params[:user_input]

    if plan_type == "workout" || plan_type == "diet"
      plan = generate_plan(plan_type, user_input)
      render json: plan, status: :ok
    else
      render json: { error: "Invalid plan type" }, status: :unprocessable_entity
    end
  end

  private

  def generate_plan(plan_type, user_input)
    api_key = ENV["API_KEY"]
    base_url = ENV["BASE_URL"]
    system_instructions = File.read(Rails.root.join("config", "prompts", "system_instructions_#{plan_type}.txt"))

    request_payload = build_request_payload(system_instructions, user_input)
    response = make_api_request(base_url, api_key, request_payload)

    handle_api_response(response)
  end

  def build_request_payload(system_instructions, user_input)
    {
      contents: [
        {
          role: "user",
          parts: [
            {
              text: user_input
            }
          ]
        }
      ],
      systemInstruction: {
        role: "user",
        parts: [
          {
            text: system_instructions
          }
        ]
      },
      generationConfig: {
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: "text/plain"
      }
    }.to_json
  end

  def make_api_request(base_url, api_key, request_payload)
    uri = URI("#{base_url}#{api_key}")
    Net::HTTP.post(uri, request_payload, "Content-Type" => "application/json")
  end

  def handle_api_response(response)
    response_data = JSON.parse(response.body)

    if response_data["candidates"].present? && response_data["candidates"].first["content"].present?
      raw_content = response_data["candidates"].first["content"]["parts"].first["text"]

      cleaned_content = raw_content.gsub(/```json|\n```|\n/, "").strip

      begin
        JSON.parse(cleaned_content)
      rescue JSON::ParserError => e
        { error: "Failed to parse plan: #{e.message}" }
      end
    else
      { error: "Unable to generate plan" }
    end
  end
end
