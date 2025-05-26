defmodule CesizenWeb.ContentLive.Index do
  use CesizenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Contents
      <:actions>
        <.link patch={~p"/contents/new"}>
          <.button>New Content</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="contents"
      rows={@streams.contents}
      row_click={fn {_id, content} -> JS.navigate(~p"/contents/#{content}") end}
    >
      <:col :let={{_id, content}} label="Id">{content.id}</:col>

      <:col :let={{_id, content}} label="Title">{content.title}</:col>

      <:col :let={{_id, content}} label="Type">{content.type}</:col>

      <:col :let={{_id, content}} label="Body">{content.body}</:col>

      <:col :let={{_id, content}} label="Category">{content.category_id}</:col>

      <:action :let={{_id, content}}>
        <div class="sr-only">
          <.link navigate={~p"/contents/#{content}"}>Show</.link>
        </div>

        <.link patch={~p"/contents/#{content}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, content}}>
        <.link
          phx-click={JS.push("delete", value: %{id: content.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="content-modal"
      show
      on_cancel={JS.patch(~p"/contents")}
    >
      <.live_component
        module={CesizenWeb.ContentLive.FormComponent}
        id={(@content && @content.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        content={@content}
        patch={~p"/contents"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :contents,
       Ash.read!(Cesizen.Information.Content,
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
    |> assign(:page_title, "Edit Content")
    |> assign(
      :content,
      Ash.get!(Cesizen.Information.Content, id,
        actor: socket.assigns.current_user
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Content")
    |> assign(:content, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Contents")
    |> assign(:content, nil)
  end

  @impl true
  def handle_info(
        {CesizenWeb.ContentLive.FormComponent, {:saved, content}},
        socket
      ) do
    {:noreply, stream_insert(socket, :contents, content)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    content =
      Ash.get!(Cesizen.Information.Content, id,
        actor: socket.assigns.current_user
      )

    Ash.destroy!(content, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :contents, content)}
  end
end
