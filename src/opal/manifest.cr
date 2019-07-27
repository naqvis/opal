module Opal
  class CLI < Cli::Supercommand
    command "manifest"

    class Manifest < Cli::Command
      command_name "manifest"

      class Options
        arg "image", desc: "Image for which to get manifest", required: true
        help
      end

      class Help
        header "Get the manifest of an image"
        caption "Get the manifest of an image"
      end

      def run
        desc = Opal.get_manifest(args.image)
        puts String.new(desc.manifest)
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
