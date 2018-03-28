defmodule TilexWeb.LayoutView do
  use TilexWeb, :view

  def page_title(%{post: post}), do: post.title <> " - "
  def page_title(%{channel: channel}), do: String.capitalize(channel.name) <> " - "
  def page_title(%{developer: developer}), do: developer.username <> " - "
  def page_title(%{page_title: page_title}), do: page_title <> " - "
  def page_title(_), do: ""

  def twitter_image_url(%Tilex.Post{} = post) do
    channel_name = channel_name(post)

    case File.exists?("assets/static/assets/#{channel_name}_twitter_card.png") do
      true -> twitter_image_url(channel_name)
      false -> twitter_image_url(nil)
    end
  end

  def twitter_image_url(name) when is_binary(name) do
    "https://til.alqemist.com" <> "/assets/#{name}_twitter_card.png"
  end

  def twitter_image_url(name) when is_nil(name) do
    "https://til.alqemist.com" <> "/assets/til_twittercard.png"
  end

  defp channel_name(post) do
    case Ecto.assoc_loaded?(post.channel) do
      true -> String.replace(post.channel.name, "-", "_")
      false -> nil
    end
  end

  def twitter_title(%Tilex.Post{} = post) do
    Tilex.Post.twitter_title(post)
  end

  def twitter_title(_post) do
    "Alqemist.com - Today I Learned"
  end

  def twitter_description(%Tilex.Post{} = post) do
    Tilex.Post.twitter_description(post)
  end

  def twitter_description(_post) do
    """
    Alqemist TIL (Today I Learned) that exists to catalogue the sharing & accumulation of knowledge as it happens day-to-day.
    """
  end
end
