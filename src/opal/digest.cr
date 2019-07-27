module Opal
  class CLI < Cli::Supercommand
    command "digest"

    class Digest < Cli::Command
      command_name "digest"

      class Options
        arg "image", desc: "Image for which to get digest", required: true
        help
      end

      class Help
        header "Get the digest of an image"
        caption "Get the digest of an image"
      end

      def run
        desc = Opal.get_manifest(args.image)
        puts desc.digest.to_s
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
