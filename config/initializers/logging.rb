SemanticLogger.sync!
SemanticLogger.default_level = :trace # Prefab will take over the filtering
SemanticLogger.add_appender(
  file_name: "log/#{Rails.env}.log",
  formatter: :color,
  filter: Prefab.log_filter,
)
