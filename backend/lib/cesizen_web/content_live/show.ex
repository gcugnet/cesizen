defmodule CesizenWeb.ContentLive.Show do
  use CesizenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Content {@content.id}
      <:subtitle>This is a content record from your database.</:subtitle>

      <:actions>
        <.link
          patch={~p"/contents/#{@content}/show/edit"}
          phx-click={JS.push_focus()}
        >
          <.button>Edit content</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@content.id}</:item>

      <:item title="Title">{@content.title}</:item>

      <:item title="Type">{@content.type}</:item>

      <:item title="Body">{@content.body}</:item>

      <:item title="Category">{@content.category_id}</:item>
    </.list>

    <.back navigate={~p"/contents"}>Back to contents</.back>

    <.modal
      :if={@live_action == :edit}
      id="content-modal"
      show
      on_cancel={JS.patch(~p"/contents/#{@content}")}
    >
      <.live_component
        module={CesizenWeb.ContentLive.FormComponent}
        id={@content.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        content={@content}
        patch={~p"/contents/#{@content}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :content,
       Ash.get!(Cesizen.Information.Content, id,
         actor: socket.assigns.current_user
       )
     )}
  end

  defp page_title(:show), do: "Show Content"
  defp page_title(:edit), do: "Edit Content"
end
