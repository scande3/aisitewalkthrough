class RecordingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index

  end

  def home

  end

  def handle_upload
    # filename = SecureRandom.uuid + ".wav"

    @audio_data = params[:audio_data].path
    data = File.read(@audio_data)
    filename = params[:audio_filename]
    full_path = Rails.root.join('public', 'uploads', filename).to_s
    directory = Rails.root.join('public', 'uploads').to_s
    FileUtils.mkpath directory
    File.open(full_path, 'wb' ) do |output|
        output.write data
    end
    @audio_path = full_path

    # full_path='/home/bluewolf/Downloads/gettysburg.wav'
    region = ENV['TRANSCRIPT_REGION']
    key = ENV['TRANSCRIPT_KEY']
    transcription_service_result = `audio_file=@'#{full_path}'; curl --location --request POST "https://#{region}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US&format=detailed" --header "Ocp-Apim-Subscription-Key: #{key}" --header "Content-Type: audio/wav" --data-binary $audio_file`
    puts transcription_service_result
    transcription_json = JSON.parse(transcription_service_result)
    transcription_result = transcription_json["DisplayText"].to_s

    # payload = {}
    # payload["messages"] = []
    #
    # system_message = {}
    # system_message["role"] = "system"
    # system_message["content"] = []
    # content = {}
    # content["type"] = "text"
    # content["text"] = "# For the bathroom that is stalls only (also known as bathroom one):\n1. Are all bathroom stalls cleaned?\n2. Is toilet paper stocked?\n3. Are paper towels stocked?\n4. Is the soap dispenser full?\n5. Are trashes emptied?\n6. Is the mirror clean?\n7. Does any other part of the bathroom require repair or follow-up?\n# For the bathroom that has urinals (also known as bathroom two):\n1. Are all bathroom stalls cleaned?\n2. Is toilet paper stocked?\n3. Are paper towels stocked?\n4. Is the soap dispenser full?\n5. Are trashes emptied?\n6. Is the mirror clean?\n7. Does any other part of the bathroom require repair or follow-up?\n\nPlease go through each question before this section and use the information in the following paragraph to determine the answers. Keep the questions in the same order as the above. For each question, please reply with the question, the answer, and the text below that you used to determine the answer. For any question where there is not enough information to answer the question, please state \"no answer provided\"."
    # system_message["content"] << content
    #
    # user_message = {}
    # user_message["role"] = "user"
    # user_message["content"] = []
    # user_content = {}
    # user_content["type"] = "text"
    # user_content["text"] = transcription_result
    # user_message["content"] << user_content
    #
    # payload["messages"] << system_message
    # payload["messages"] << user_message
    #
    # payload["temperature"] = 0.7
    # payload["top_p"] =  0.95
    # payload["max_tokens"] = 2000
    #
    # api_result = RestClient::Request.execute(method: :post,
    #                                          url: "#{ENV['OPEN_AI_ENDPOINT']}/openai/deployments/walthrough_model_try1/chat/completions?api-version=2024-02-15-preview",
    #                                          headers: {params: {"api-key" => ENV['OPEN_AI_KEY'],
    #                                                             "Content-Type" => "application/json"
    #                                          }},
    #                                          payload: payload,
    #                                          timeout: 30)


    azure_ai_response = `payload="{\\"messages\\":[{\\"role\\":\\"system\\",\\"content\\":[{\\"type\\":\\"text\\",\\"text\\":\\"# For the the bathroom that is stalls only (also known as bathroom one or women's bathroom):\\\\n1. Are all bathroom stalls cleaned?\\\\n2. Is toilet paper stocked?\\\\n3. Are paper towels stocked?\\\\n4. Is the soap dispenser full?\\\\n5. Are trashes emptied?\\\\n6. Is the mirror clean?\\\\n7. Does any other part of the bathroom require repair or follow-up?\\\\n# For the bathroom that has urinals (also known as bathroom two or men's bathroom):\\\\n1. Are all bathroom stalls cleaned?\\\\n2. Is toilet paper stocked?\\\\n3. Are paper towels stocked?\\\\n4. Is the soap dispenser full?\\\\n5. Are trashes emptied?\\\\n6. Is the mirror clean?\\\\n7. Does any other part of the bathroom require repair or follow-up?\\\\n\\\\nPlease go through each question before this section and use the information in the following paragraph to determine the answers. Keep the questions in the same order as the above. For each question, please reply with the question, the answer, and the text below that you used to determine the answer. For any question where there is not enough information to answer the question, please state \\\\\\"no answer provided\\\\\\".\\"}]},{\\"role\\":\\"user\\",\\"content\\":[{\\"type\\":\\"text\\",\\"text\\":\\"#{transcription_result}\\"}]}],\\"temperature\\":0.7,\\"top_p\\":0.95,\\"max_tokens\\":1200}"; curl "#{ENV['OPEN_AI_ENDPOINT']}/openai/deployments/walthrough_model_try1/chat/completions?api-version=2024-02-15-preview" -H "Content-Type: application/json" -H "api-key: #{ENV['OPEN_AI_KEY']}" -d "$payload"`
    puts azure_ai_response
    azure_ai_response_json = JSON.parse(azure_ai_response)
    report_markdown = azure_ai_response_json["choices"].first["message"]["content"].to_s

    respond_to do |format|
      format.html { render :plain => report_markdown }
      format.json { render :plain => report_markdown }
    end
  end
end