defmodule LumberjackCli do

  def main(args \\ []) do
    args
    |> parse_args()
    |> response
    |> IO.inspect()
  end

  defp parse_args(args) do
    {opts,_,_} = args
    |> OptionParser.parse(switches: [file: :string, battle_id: :string, gzp_id: :string], aliases: [f: :file, battle: :battle_id, gzp: :gzp_id])
    opts
  end

  defp response(opts) do
    Lumberjack.battle_result(opts[:f], opts[:battle], opts[:gzp])
  end
end
