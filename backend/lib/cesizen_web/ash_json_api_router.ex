defmodule CesizenWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Cesizen.Accounts, Cesizen.Emotions],
    open_api: "/open_api"
end
