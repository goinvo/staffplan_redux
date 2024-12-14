SemanticLogger.sync!
SemanticLogger.default_level = :trace # Prefab will take over the filtering

appender_args = {
  formatter: :color,
  filter: Prefab.log_filter,
}
appender_args.merge!(io: $stdout) if Rails.env.production?
appender_args.merge!(file_name: "log/#{Rails.env}.log") if Rails.env.development?

SemanticLogger.add_appender(**appender_args)
