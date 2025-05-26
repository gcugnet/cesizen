defmodule CesizenWeb.EmotionLive.Index do
  use CesizenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Emotions
      <:actions>
        <.link patch={~p"/emotions/new"}>
          <.button>New Emotion</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="emotions"
      rows={@streams.emotions}
      row_click={fn {_id, emotion} -> JS.navigate(~p"/emotions/#{emotion}") end}
    >
      <:col :let={{_id, emotion}} label="Id">{emotion.id}</:col>

      <:col :let={{_id, emotion}} label="Name">{emotion.name}</:col>

      <:col :let={{_id, emotion}} label="Basic emotion">
        {emotion.basic_emotion_id}
      </:col>

      <:action :let={{_id, emotion}}>
        <div class="sr-only">
          <.link navigate={~p"/emotions/#{emotion}"}>Show</.link>
        </div>

        <.link patch={~p"/emotions/#{emotion}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, emotion}}>
        <.link
          phx-click={JS.push("delete", value: %{id: emotion.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="emotion-modal"
      show
      on_cancel={JS.patch(~p"/emotions")}
    >
      <.live_component
        module={CesizenWeb.EmotionLive.FormComponent}
        id={(@emotion && @emotion.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        emotion={@emotion}
        patch={~p"/emotions"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :emotions,
       Ash.read!(Cesizen.Emotions.Emotion, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Emotion")
    |> assign(
      :emotion,
      Ash.get!(Cesizen.Emotions.Emotion, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Emotion")
    |> assign(:emotion, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Emotions")
    |> assign(:emotion, nil)
  end

  @impl true
  def handle_info(
        {CesizenWeb.EmotionLive.FormComponent, {:saved, emotion}},
        socket
      ) do
    {:noreply, stream_insert(socket, :emotions, emotion)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    emotion =
      Ash.get!(Cesizen.Emotions.Emotion, id, actor: socket.assigns.current_user)

    Ash.destroy!(emotion, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :emotions, emotion)}
  end
end
