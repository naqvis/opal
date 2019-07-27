require "logger"
require "cli"
require "containerregistry"
require "./opal/*"

module Opal
  VERSION = "0.1.0"

  module Logger
    @@log = ::Logger.new(STDOUT, progname: "opal")
    @@log.level = ::Logger::INFO
    @@log.formatter = ::Logger::Formatter.new do |severity, datetime, progname, message, io|
      label = severity.unknown? ? "ANY" : severity.to_s
      io << "[" << datetime << " #" << Process.pid << "] "
      io << label.rjust(5) << " -- " << progname << ": " << message
    end

    def self.info(msg)
      @@log.info(msg)
    end

    def self.debug(msg)
      @@log.debug(msg)
    end

    def self.warn(msg)
      @@log.warn(msg)
    end

    def self.fatal(msg)
      @@log.fatal(msg)
    end

    def self.error(msg)
      @@log.error(msg)
    end
  end

  class CLI < Cli::Supercommand
    command_name "Opal"
    version "Opal CLI - v#{VERSION}"
    command "help", default: true

    class Help
      title "Opal"
      header "Opal is a tool for managing container images"
      footer "(C) 2019 Ali Naqvi"
    end

    class Options
      version desc: "prints Opal version"
      help desc: "describe available commands and usages"
      help
      version
    end
  end

  V1::Remote::Transport.verbose_http = false
  CLI.run(ARGV)
end
