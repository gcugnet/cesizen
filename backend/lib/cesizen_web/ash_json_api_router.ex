defmodule CesizenWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Cesizen.Accounts],
    open_api: "/open_api"
end
