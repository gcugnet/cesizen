defmodule CesizenWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Cesizen.Users, Cesizen.Emotions],
    open_api: "/open_api"
end
