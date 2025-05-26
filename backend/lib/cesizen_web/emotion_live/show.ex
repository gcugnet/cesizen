defmodule CesizenWeb.EmotionLive.Show do
  use CesizenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Emotion {@emotion.id}
      <:subtitle>This is a emotion record from your database.</:subtitle>

      <:actions>
        <.link
          patch={~p"/emotions/#{@emotion}/show/edit"}
          phx-click={JS.push_focus()}
        >
          <.button>Edit emotion</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@emotion.id}</:item>

      <:item title="Name">{@emotion.name}</:item>

      <:item title="Basic emotion">{@emotion.basic_emotion_id}</:item>
    </.list>

    <.back navigate={~p"/emotions"}>Back to emotions</.back>

    <.modal
      :if={@live_action == :edit}
      id="emotion-modal"
      show
      on_cancel={JS.patch(~p"/emotions/#{@emotion}")}
    >
      <.live_component
        module={CesizenWeb.EmotionLive.FormComponent}
        id={@emotion.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        emotion={@emotion}
        patch={~p"/emotions/#{@emotion}"}
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
       :emotion,
       Ash.get!(Cesizen.Emotions.Emotion, id,
         actor: socket.assigns.current_user
       )
     )}
  end

  defp page_title(:show), do: "Show Emotion"
  defp page_title(:edit), do: "Edit Emotion"
end
