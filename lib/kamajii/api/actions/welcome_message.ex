defmodule Kamajii.API.Actions.WelcomeMessage do
  use Raxx.SimpleServer
  alias Kamajii.API

  @impl Raxx.SimpleServer
  def handle_request(_request = %{method: :GET}, _state) do
    data = %{message: "Hello, Raxx!"}

    response(:ok)
    |> set_body(Jason.encode!(%{data: data}))
  end

  def handle_request(request = %{method: :POST}, _state) do
    case Jason.decode(request.body) do
      {:ok, %{"push" => _contents}} ->
        #message = Kamajii.welcome_message(contents)
        #data = %{message: message}

        response(:created)
        #|> API.set_json_payload(%{data: data})

      {:ok, _} ->
        error = %{title: "Missing required data parameter 'name'"}

        response(:bad_request)
        |> API.set_json_payload(%{errors: [error]})

      {:error, _} ->
        error = %{title: "Could not decode request data"}

        response(:unsupported_media_type)
        |> API.set_json_payload(%{errors: [error]})
    end
  end
end