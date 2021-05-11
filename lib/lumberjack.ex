defmodule Lumberjack do

  @result_map %{
    "draw" => 0,
    "result" => 0,
    "time_out" => 0,
    "quit" => 0,
    "draw_no_match" => 0
  }

  @distribution_map %{
    "total" => 0,
    "result_map" => @result_map
  }

  def get_distribution(file) do
    %{"total" => total, "result_map" => result_map} =
      file
      |> make_result_distribution()
    result_map
    |> Enum.map(fn {res, count} -> {res, count*100/total} end)
    |> Map.new()
  end

  def make_result_distribution(file) do
    file
    |> read_file()
    |> String.split("\n")
    |> Enum.filter(fn line -> line |> is_t3 end)
    |> Enum.filter(fn line -> line |> is_result end)
    |> Enum.filter(fn line -> line |> not_reconnection end)
    |> Enum.map(fn line -> line |> get_result end)
    |> Enum.reduce(@distribution_map, fn res, acc -> %{
      acc |
      "total" => acc["total"] + 1,
      "result_map" => %{
        acc["result_map"] | res => acc["result_map"][res] + 1
      }
    }
    end
    )
  end
  # def run do
  #   read_file()
  #   |> String.split("\n")
  #   |> Enum.filter(fn line -> line |> is_result end)
  #   |> Enum.map(fn line -> line |> get_battle_ids end)
  #   |> IO.inspect()
  # end

  def read_file(file) do
    with {:ok, content} <- File.read(file) do
      content
    else
      {:error, _} -> ""
    end
  end

  def is_result(line_string) do
    line_string
    |> String.contains?("gameover status:")
  end

  def is_t3(line_string) do
    line_string
    |> String.contains?("match_id=match_id:T3:")
  end

  def not_reconnection(line_string) do
    line_string
    |> String.contains?("reconnection")
    |> (&(!&1)).()
  end

  def get_result(line_string) do
    [_ts, _battle_id_info, _info, _gotxt, _statustxt, reason, _winner, _arrow, _loser] =
      line_string
      |> String.split(" ")
    reason
  end

  def get_battle_ids(line_string) do
    [_ts, battle_id_info| _rest] =
      line_string
      |> String.split(" ")
    "match_id=match_id:T3:"<>battle_id = battle_id_info
    battle_id
  end
end
