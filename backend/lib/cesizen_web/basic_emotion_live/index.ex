defmodule CesizenWeb.BasicEmotionLive.Index do
  use CesizenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Basic emotions
      <:actions>
        <.link patch={~p"/basic_emotions/new"}>
          <.button>New Basic emotion</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="basic_emotions"
      rows={@streams.basic_emotions}
      row_click={
        fn {_id, basic_emotion} ->
          JS.navigate(~p"/basic_emotions/#{basic_emotion}")
        end
      }
    >
      <:col :let={{_id, basic_emotion}} label="Id">{basic_emotion.id}</:col>

      <:col :let={{_id, basic_emotion}} label="Name">{basic_emotion.name}</:col>

      <:action :let={{_id, basic_emotion}}>
        <div class="sr-only">
          <.link navigate={~p"/basic_emotions/#{basic_emotion}"}>Show</.link>
        </div>

        <.link patch={~p"/basic_emotions/#{basic_emotion}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, basic_emotion}}>
        <.link
          phx-click={
            JS.push("delete", value: %{id: basic_emotion.id}) |> hide("##{id}")
          }
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="basic_emotion-modal"
      show
      on_cancel={JS.patch(~p"/basic_emotions")}
    >
      <.live_component
        module={CesizenWeb.BasicEmotionLive.FormComponent}
        id={(@basic_emotion && @basic_emotion.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        basic_emotion={@basic_emotion}
        patch={~p"/basic_emotions"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :basic_emotions,
       Ash.read!(Cesizen.Emotions.BasicEmotion,
         actor: socket.assigns[:current_user]
       )
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Basic emotion")
    |> assign(
      :basic_emotion,
      Ash.get!(Cesizen.Emotions.BasicEmotion, id,
        actor: socket.assigns.current_user
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Basic emotion")
    |> assign(:basic_emotion, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Basic emotions")
    |> assign(:basic_emotion, nil)
  end

  @impl true
  def handle_info(
        {CesizenWeb.BasicEmotionLive.FormComponent, {:saved, basic_emotion}},
        socket
      ) do
    {:noreply, stream_insert(socket, :basic_emotions, basic_emotion)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    basic_emotion =
      Ash.get!(Cesizen.Emotions.BasicEmotion, id,
        actor: socket.assigns.current_user
      )

    Ash.destroy!(basic_emotion, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :basic_emotions, basic_emotion)}
  end
end
