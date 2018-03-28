defmodule TilexWeb.ChannelController do
  use TilexWeb, :controller

  alias Guardian.Plug
  alias Tilex.{Channel, Posts}

  plug(
    Plug.EnsureAuthenticated,
    [handler: __MODULE__]
    when action in ~w(new create edit update)a
  )

  def new(conn, _params) do
    current_user = Plug.current_resource(conn)
    changeset = Channel.changeset(%Channel{})

    conn
    |> assign(:changeset, changeset)
    |> assign(:current_user, current_user)
    |> render("new.html")
  end

  def create(conn, %{"channel" => channel_params}) do
    developer = Plug.current_resource(conn)

    changeset =
      %Channel{}
      |> Channel.changeset(channel_params)

    case Repo.insert(changeset) do
      {:ok, _channel} ->
        conn
        |> put_flash(:info, "Channel created")
        |> redirect(to: post_path(conn, :new))

      {:error, changeset} ->
        conn
        |> assign(:current_user, developer)
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end

  def show(conn, %{"name" => channel_name} = params) do
    page =
      params
      |> Map.get("page", "1")
      |> String.to_integer()

    {posts, posts_count, channel} = Posts.by_channel(channel_name, page)

    render(
      conn,
      "show.html",
      posts: posts,
      posts_count: posts_count,
      channel: channel,
      page: page
    )
  end
end
