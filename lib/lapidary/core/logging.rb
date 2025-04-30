module Lapidary::Misc::Logging

  def setup_logging
    setup_logger_colors
    setup_logger_appenders
    set_logger_name
  end

  def setup_logger_colors
    Logging.color_scheme( 'bright',
                          levels: {
                            info: :green,
                            warn: :yellow,
                            error: :red,
                            fatal: %i[white on_red]
                          },
                          date: :white,
                          logger: :white,
                          message: :white
    )
  end

  def setup_logger_appenders(app_name = 'lapidary')
    Logging.logger.root.add_appenders(
      Logging.appenders.stdout(
        'stdout',
        layout: Logging.layouts.pattern(
          pattern: '[%d] %-5l %c: %m\n',
          color_scheme: 'bright'
        )
      ),
      Logging.appenders.file(
        "data/logs/#{app_name}-development-#{Time.now.strftime('%Y-%m-%d')}.log",
        layout: Logging.layouts.pattern(pattern: '[%d] %-5l %c: %m\n')
      )
    )
  end

  def set_logger_name
    Logging.logger[self.class.name.to_s]
  end
end