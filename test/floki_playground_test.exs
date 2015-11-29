defmodule Post do
  defstruct [:avatar, :title, :meta, :body]

  defmodule Meta do
    defstruct [:date, :author]
  end
end

defmodule ElixirStatus.Parser do
  def posts(html) do
    html
    |> Floki.find("div.post")
    |> Enum.map(&ElixirStatus.Parser.post/1)
  end

  def post(post) do
    %Post{
      title: title(post),
      avatar: avatar(post),
      body: body(post),
      meta: meta(post)
    }
  end

  def meta(post) do
    %Post.Meta{
      date: date(post),
      author: author(post)
    }
  end

  def title(post) do
    post
    |> Floki.find(".post-title")
    |> Floki.text
  end

  def avatar(post) do
    post
    |> Floki.find(".post-avatar .image")
    |> Floki.attribute("style")
    |> (fn
         ([style]) ->
           Regex.replace(~r/background-image: url\((.*)\)/, style, "\\1")
         (x) ->
           ""
       end).()
  end

  def body(post) do
    post
    |> Floki.find(".post-body")
    |> Floki.text
  end

  def date(post) do
    post
    |> Floki.find(".post-date")
    |> Floki.text
  end

  def author(post) do
    post
    |> Floki.find(".post-author a")
    |> Floki.text
    |> String.strip
  end
end

defmodule FlokiPlaygroundTest do
  use ExUnit.Case
  doctest FlokiPlayground
  @html File.read!("elixirstatusindex.html")

  test "finding posts on elixirstatus" do
    posts = ElixirStatus.Parser.posts(@html)

    assert length(posts) == 22

    [_|posts] = posts
    [first_post|_] = posts
    IO.inspect first_post

    assert first_post.title =~ ~r/RethinkDB/
    assert first_post.avatar == "/images/github/ryanswapp.jpg"
    assert first_post.body =~ ~r/RethinkDB/
    assert first_post.meta.date == "28 Nov"
    assert first_post.meta.author =~ ~r/ryanswapp/
  end
end
