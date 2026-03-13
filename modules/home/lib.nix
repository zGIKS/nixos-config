{ }:

{
  mkConfigLinks = entries:
    builtins.listToAttrs (map (entry: {
      name = entry.target;
      value.source = entry.source;
    }) entries);
}
