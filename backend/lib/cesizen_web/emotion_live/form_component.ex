defmodule CesizenWeb.EmotionLive.FormComponent do
  use CesizenWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          Use this form to manage emotion records in your database.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="emotion-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:basic_emotion]} type="text" label="Basic emotion" /><.input
            field={@form[:name]}
            type="text"
            label="Name"
          />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input field={@form[:name]} type="text" label="Name" />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Emotion</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"emotion" => emotion_params}, socket) do
    {:noreply,
     assign(socket,
       form: AshPhoenix.Form.validate(socket.assigns.form, emotion_params)
     )}
  end

  def handle_event("save", %{"emotion" => emotion_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: emotion_params) do
      {:ok, emotion} ->
        notify_parent({:saved, emotion})

        socket =
          socket
          |> put_flash(
            :info,
            "Emotion #{socket.assigns.form.source.type}d successfully"
          )
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{emotion: emotion}} = socket) do
    form =
      if emotion do
        AshPhoenix.Form.for_update(emotion, :update,
          as: "emotion",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Cesizen.Emotions.Emotion, :create,
          as: "emotion",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
