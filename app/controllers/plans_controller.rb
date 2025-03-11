class PlansController < ApplicationController
  require "net/http"
  require "uri"
  require "json"
  require "digest"

  before_action :validate_params, only: [ :generate ]

  def generate
    plan_type = params[:plan_type]
    plan_data = params[:plan_data]

    plan = cached_plan(plan_type, plan_data) do
      case plan_type
      when "diet"
        generate_diet_plan(plan_data)
      when "workout"
        generate_workout_plan(plan_data)
      else
        { error: "Invalid plan type" }
      end
    end

    render json: plan, status: :ok
  end

  private

  def validate_params
    plan_type = params[:plan_type]
    plan_data = params[:plan_data]

    unless %w[diet workout].include?(plan_type)
      render json: { error: "Invalid plan type. Must be 'diet' or 'workout'." }, status: :unprocessable_entity
      return
    end

    unless valid_user_input?(plan_type, plan_data)
      render json: { error: "Invalid input format for #{plan_type}. Ensure all required fields are included." }, status: :unprocessable_entity
    end
  end

  def valid_user_input?(plan_type, plan_data)
    return false unless plan_data.is_a?(ActionController::Parameters) || plan_data.is_a?(Hash)

    expected_keys = case plan_type
    when "diet"
      %w[weight height age sex activity_level]
    when "workout"
      %w[goal experience preferred_exercise_type]
    else
      return false
    end

    plan_data = plan_data.to_unsafe_h if plan_data.is_a?(ActionController::Parameters)
    expected_keys.all? { |key| plan_data.key?(key) }
  end

  def cached_plan(plan_type, plan_data)
    cache_key = "plan_#{plan_type}_#{Digest::SHA256.hexdigest(plan_data.to_json)}"
    Rails.cache.fetch(cache_key, expires_in: 12.hours) { yield }
  end

  def generate_diet_plan(diet_data)
    system_instructions = File.read(Rails.root.join("config", "prompts", "system_instructions_diet.txt"))
    request_payload = build_request_payload(system_instructions, diet_data)
    response = make_api_request(request_payload)
    handle_api_response(response, "diet")
  end

  def generate_workout_plan(workout_data)
    system_instructions = File.read(Rails.root.join("config", "prompts", "system_instructions_workout.txt"))
    request_payload = build_request_payload(system_instructions, workout_data)
    response = make_api_request(request_payload)
    handle_api_response(response, "workout")
  end

  def build_request_payload(system_instructions, user_data)
    {
      contents: [
        {
          role: "user",
          parts: [
            { text: user_data.to_json }
          ]
        }
      ],
      systemInstruction: {
        role: "user",
        parts: [
          { text: system_instructions }
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

  def make_api_request(request_payload)
    api_key = ENV["API_KEY"]
    base_url = ENV["BASE_URL"]

    uri = URI("#{base_url}#{api_key}")

    Net::HTTP.post(uri, request_payload, "Content-Type" => "application/json")
  end

  def handle_api_response(response, plan_type)
    begin
      response_data = JSON.parse(response.body)
    rescue JSON::ParserError
      return { error: "Invalid response from AI" }
    end

    if response_data.dig("candidates", 0, "content", "parts", 0, "text").present?
      raw_content = response_data["candidates"].first["content"]["parts"].first["text"]
      cleaned_content = raw_content.gsub(/```json|\n```|\n/, "").strip

      begin
        parsed_response = JSON.parse(cleaned_content)
        return parsed_response if valid_plan_response?(plan_type, parsed_response)

        { error: "AI response does not match expected format" }
      rescue JSON::ParserError
        { error: "Failed to parse AI response" }
      end
    else
      { error: "Unable to generate plan" }
    end
  end

  def valid_plan_response?(plan_type, response_data)
    case plan_type
    when "diet"
      response_data.is_a?(Hash) && response_data.keys.any? { |key| key.start_with?("meal_") }
    when "workout"
      response_data.is_a?(Hash) && response_data.keys.any? { |key| key.start_with?("day_") }
    else
      false
    end
  end
end
