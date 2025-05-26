defmodule CesizenWeb.BasicEmotionLive.Show do
  use CesizenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Basic emotion {@basic_emotion.id}
      <:subtitle>This is a basic_emotion record from your database.</:subtitle>

      <:actions>
        <.link
          patch={~p"/basic_emotions/#{@basic_emotion}/show/edit"}
          phx-click={JS.push_focus()}
        >
          <.button>Edit basic_emotion</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@basic_emotion.id}</:item>

      <:item title="Name">{@basic_emotion.name}</:item>
    </.list>

    <.back navigate={~p"/basic_emotions"}>Back to basic_emotions</.back>

    <.modal
      :if={@live_action == :edit}
      id="basic_emotion-modal"
      show
      on_cancel={JS.patch(~p"/basic_emotions/#{@basic_emotion}")}
    >
      <.live_component
        module={CesizenWeb.BasicEmotionLive.FormComponent}
        id={@basic_emotion.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        basic_emotion={@basic_emotion}
        patch={~p"/basic_emotions/#{@basic_emotion}"}
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
       :basic_emotion,
       Ash.get!(Cesizen.Emotions.BasicEmotion, id,
         actor: socket.assigns.current_user
       )
     )}
  end

  defp page_title(:show), do: "Show Basic emotion"
  defp page_title(:edit), do: "Edit Basic emotion"
end
