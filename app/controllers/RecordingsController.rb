class RecordingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index

  end

  def home

  end

  def handle_upload
    # filename = SecureRandom.uuid + ".wav"

    @audio_data = params[:audio_data].path
    #ata = File.read(@audio_data)
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
    transcription_result = transcription_json["DisplayText"]


    respond_to do |format|
      format.html { render :plain => transcription_result }
      format.json { render :plain => transcription_result }
    end
  end
end