module Opal
  class CLI < Cli::Supercommand
    command "append"

    class Config < Cli::Command
      command_name "config"

      class Options
        arg "image", desc: "Image for which to get config for", required: true
        help
      end

      class Help
        header "Get the config of an image"
        caption "Get the config of an image"
      end

      def run
        i = Opal.get_image(args.image)
        config = i.raw_config_file
        puts String.new(config)
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
