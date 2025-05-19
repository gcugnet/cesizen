defmodule Cesizen.Emotions do
  use Ash.Domain, otp_app: :cesizen, extensions: [AshJsonApi.Domain]

  resources do
    resource Cesizen.Emotions.BasicEmotion
  end
end
