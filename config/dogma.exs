use Mix.Config
alias Dogma.Rule

config :dogma,

  # Select a set of rules as a base
  rule_set: Dogma.RuleSet.All,

  # Pick paths not to lint
  exclude: [
    ~r(\Alib/vendor/),
    ~r(\Atest/support/)
  ],

  # Override an existing rule configuration
  override: [
    %Rule.LineLength{ max_length: 100 },
    %Rule.HardTabs{ enabled: false },
    %Rule.ModuleDoc{ enabled: false }
  ]
