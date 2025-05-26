defmodule CesizenWeb.CategoryLive.Index do
  use CesizenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Categories
      <:actions>
        <.link patch={~p"/categories/new"}>
          <.button>New Category</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="categories"
      rows={@streams.categories}
      row_click={fn {_id, category} -> JS.navigate(~p"/categories/#{category}") end}
    >
      <:col :let={{_id, category}} label="Id">{category.id}</:col>

      <:col :let={{_id, category}} label="Name">{category.name}</:col>

      <:col :let={{_id, category}} label="Description">{category.description}</:col>

      <:action :let={{_id, category}}>
        <div class="sr-only">
          <.link navigate={~p"/categories/#{category}"}>Show</.link>
        </div>

        <.link patch={~p"/categories/#{category}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, category}}>
        <.link
          phx-click={JS.push("delete", value: %{id: category.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="category-modal"
      show
      on_cancel={JS.patch(~p"/categories")}
    >
      <.live_component
        module={CesizenWeb.CategoryLive.FormComponent}
        id={(@category && @category.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        category={@category}
        patch={~p"/categories"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :categories,
       Ash.read!(Cesizen.Information.Category,
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
    |> assign(:page_title, "Edit Category")
    |> assign(
      :category,
      Ash.get!(Cesizen.Information.Category, id,
        actor: socket.assigns.current_user
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info(
        {CesizenWeb.CategoryLive.FormComponent, {:saved, category}},
        socket
      ) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category =
      Ash.get!(Cesizen.Information.Category, id,
        actor: socket.assigns.current_user
      )

    Ash.destroy!(category, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :categories, category)}
  end
end
