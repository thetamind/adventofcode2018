ExUnit.start(exclude: [bench: true])

defmodule FProf do
  defmacro profile(do: block) do
    content =
      quote do
        Mix.Tasks.Profile.Fprof.profile(fn -> unquote(block) end,
          warmup: false,
          sort: "acc",
          callers: true
        )
      end

    Code.compile_quoted(content)
  end
end

defmodule JunkDrawer do
  def permute([]), do: [[]]

  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end

  def comb(0, _), do: [[]]
  def comb(_, []), do: []

  def comb(m, [h | t]) do
    for(l <- comb(m - 1, t), do: [h | l]) ++ comb(m, t)
  end

  @spec selections(Enum.t(), integer) :: Enum.t()
  def selections(_, 0), do: [[]]

  def selections(enum, n) do
    list = Enum.to_list(enum)

    list
    |> Enum.flat_map(fn el -> Enum.map(selections(list, n - 1), &[el | &1]) end)
  end
end
