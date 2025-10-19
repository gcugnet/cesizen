defmodule CesizenWeb.GitHubService do
  @moduledoc """
  Service for creating GitHub issues via API
  """

  @github_api_url "https://api.github.com"

  def create_issue(username, email, title, description) do
    with {:ok, config} <- get_github_config(),
         {:ok, formatted_issue} <- format_issue(username, email, title, description),
         {:ok, response} <- send_github_request(config, formatted_issue) do
      {:ok, response}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_github_config do
    token = Application.fetch_env!(:cesizen, :github_token)
    owner = Application.fetch_env!(:cesizen, :github_repo_owner)
    repo = Application.fetch_env!(:cesizen, :github_repo_name)

    # token = System.get_env("GITHUB_TOKEN")
    # owner = System.get_env("GITHUB_REPO_OWNER")
    # repo = System.get_env("GITHUB_REPO_NAME")

    dbg(token)

    case {token, owner, repo} do
      {nil, _, _} -> {:error, "GITHUB_TOKEN not configured"}
      {_, nil, _} -> {:error, "GITHUB_REPO_OWNER not configured"}
      {_, _, nil} -> {:error, "GITHUB_REPO_NAME not configured"}
      {token, owner, repo} -> {:ok, %{token: token, owner: owner, repo: repo}}
    end
  end

  defp format_issue(username, email, title, description) do
    formatted_body = """
    **Créé par :** #{username}
    **Date de création :** #{DateTime.utc_now() |> DateTime.to_iso8601()}
    **Contact :** #{email}

    ---

    #{description}

    ---
    *Ce ticket a été créé depuis l’application et nécessite d’être trié et assigné.*
    """

    issue = %{
      title: """
      Formulaire de ticket : #{title} – (utilisateur "#{username}")
      """,
      body: formatted_body,
      labels: ["S:Support", "Pending-Triage"]
    }

    {:ok, issue}
  end

  defp send_github_request(%{token: token, owner: owner, repo: repo}, issue_data) do
    url = "#{@github_api_url}/repos/#{owner}/#{repo}/issues"

    headers = [
      {"Authorization", "token #{token}"},
      {"Accept", "application/vnd.github.v3+json"},
      {"Content-Type", "application/json"},
      {"User-Agent", "Cesizen-App"}
    ]

    dbg(url)
    dbg(headers)

    body = Jason.encode!(issue_data)

    dbg(body)

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, parsed_response} -> {:ok, parsed_response}
          {:error, _} -> {:error, "Failed to parse GitHub response"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, error_response} ->
            {:error, "GitHub API error (#{status_code}): #{get_error_message(error_response)}"}
          {:error, _} ->
            {:error, "GitHub API error (#{status_code}): #{response_body}"}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  defp get_error_message(%{"message" => message}), do: message
  defp get_error_message(_), do: "Unknown error"

  def create_issue_from_params(params) do
    username = Map.get(params, "username", "")
    email = Map.get(params, "email", "")
    title = Map.get(params, "title", "")
    description = Map.get(params, "description", "")

    cond do
      String.trim(username) == "" ->
        {:error, "Username is required"}

      String.trim(email) == "" ->
        {:error, "Email is required"}

        String.trim(title) == "" ->
        {:error, "Title is required"}

      String.trim(description) == "" ->
        {:error, "Description is required"}

      true ->
        create_issue(username, email, title, description)
    end
  end
end

# Controller module
defmodule CesizenWeb.GitHubController do
  use CesizenWeb, :controller
  alias CesizenWeb.GitHubService

  def create_issue(conn, params) do
    case GitHubService.create_issue_from_params(params) do
      {:ok, github_response} ->
        conn
        |> put_status(:created)
        |> json(%{
          success: true,
          message: "Issue created successfully",
          github_issue_number: github_response["number"],
          github_url: github_response["html_url"]
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          success: false,
          error: reason
        })
    end
  end
end
