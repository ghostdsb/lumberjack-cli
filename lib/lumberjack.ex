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
    |> Enum.map(fn {res, count} -> {res, {count*100/total, "#{to_string(count)}/#{to_string(total)}"}} end)
    |> Map.new()
  end

  defp make_result_distribution(file) do
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

  def battle_result(file, battle_id, complaint) do
    battle_log_list =
      file
      |> read_file()
      |> String.split("\n")
      |> Enum.filter(fn line -> line |> is_t3 end)
      |> Enum.filter(fn line -> line |> battle_logs(battle_id) end)

    game_state =
      battle_log_list
      |> Enum.filter(fn log -> not is_result(log) end)
      |> Enum.map(fn log -> log |> get_player_id_move(complaint) end)
      |> Map.new()

    game_state
    |> draw_board()

    result =
      battle_log_list
      |> Enum.filter(fn log -> log |> is_result end)
      result
  end

  defp draw_board(game_state) do
    board = 0..8
    |> Enum.map(fn pos -> game_state[pos |> to_string] || " - " end )
    |> Enum.chunk_every(3)
    |> Enum.reduce("\n|---|---|---|\n" , fn line_list,acc -> acc<>Enum.reduce(line_list, "", fn id,acc -> acc<>"|"<>id end)<>"|\n|---|---|---|\n" end)

    board
    |> IO.puts()
  end

  defp get_player_id_move(log_string, complaint) do
    [_ts, _battle_id_info, _info, player_id, _arrow, move] =
      log_string
      |> String.split(" ")
    cond do
      complaint === player_id -> {move, " X "}
      true -> {move, " O "}
    end

  end

  defp read_file(file) do
    with {:ok, content} <- File.read(file) do
      content
    else
      {:error, _} -> ""
    end
  end

  defp is_result(line_string) do
    line_string
    |> String.contains?("gameover status:")
  end

  defp is_t3(line_string) do
    line_string
    |> String.contains?("match_id=match_id:T3:")
  end

  defp not_reconnection(line_string) do
    line_string
    |> String.contains?("reconnection")
    |> (&(!&1)).()
  end

  defp get_result(line_string) do
    [_ts, _battle_id_info, _info, _gotxt, _statustxt, reason, _winner, _arrow, _loser] =
      line_string
      |> String.split(" ")
    reason
  end

  defp battle_logs(log_lines, battle_id) do
    log_lines
    |> String.contains?(battle_id)
  end

  defp get_battle_ids(line_string) do
    [_ts, battle_id_info| _rest] =
      line_string
      |> String.split(" ")
    "match_id=match_id:T3:"<>battle_id = battle_id_info
    battle_id
  end
end
