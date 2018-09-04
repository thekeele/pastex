defmodule PastexWeb.Schema do
  use Absinthe.Schema

  query do
    field :health, :string do
      resolve fn _, _, _ ->
        IO.puts "executing health"
        {:ok, "up"}
      end
    end

    field :pastes, list_of(non_null(:paste)) do
      resolve &list_pastes/3
    end
  end

  @desc "Blobs of Pasted code"
  object :paste do
    field :name, non_null(:string) do
      # default resolver used when one isn't supplied
      resolve fn paste, _, _ ->
        {:ok, Map.get(paste, :name)}
      end
    end

    field :excited_name, :string do
      resolve &get_excited_name/3
    end

    field :description, :string
    @desc "A paste can contain multiple files"
    field :files, non_null(list_of(:file)) do
      resolve &get_files/3
    end
  end

  object :file do
    field :name, :string
    field :body, :string
    field :paste, non_null(:paste) do
      resolve &get_paste_for_file/3
    end
  end

  @pastes [
    %{
      id: 1,
      name: "Hello World",
    },
    %{
      id: 2,
      name: "Help!",
      description: "I don't know what I'm doing!!!",
    }
  ]

  @files [
    %{
      paste_id: 1,
      body: ~s[IO.puts("Hello World")]
    },
    %{
      paste_id: 2,
      name: "foo.ex",
      body: """
      defmodule Foo do
        def foo, do: Bar.bar()
      end
      """
    },
    %{
      paste_id: 2,
      name: "bar.ex",
      body: """
      defmodule Bar do
        def bar, do: Foo.foo()
      end
      """
    }
  ]

  defp get_paste_for_file(file, _, _) do
    IO.puts "executing get get_paste_for_file"
    IO.inspect(file, label: "file related to paste")
    {:ok, Enum.find(@pastes, &(&1.id == file.paste_id))}
  end

  defp get_excited_name(paste, _, _) do
    IO.puts "executing get_excited_name"
    IO.inspect(paste, label: "paste to excited_name")
    {:ok, String.upcase(paste.name)}
  end

  defp get_files(paste, _, _) do
    IO.puts "executing get_files"
    IO.inspect(paste, label: "paste for get_files")
    files = Enum.filter(@files, &(&1.paste_id == paste.id))

    {:ok, files}
  end

  defp list_pastes(root_value, _, _) do
    IO.puts "executing list_pastes"
    IO.inspect(root_value, label: "list_pastes root_value")

    {:ok, @pastes}
  end
end
