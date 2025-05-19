defmodule Cesizen.Emotions do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  resources do
    resource Cesizen.Emotions.BasicEmotion
    resource Cesizen.Emotions.Emotion
  end
end
