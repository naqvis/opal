module Opal
  class CLI < Cli::Supercommand
    command "rm", aliased: "delete"

    class Delete < Cli::Command
      command_name "delete"

      class Options
        arg "image", desc: "Image to delete", required: true
        help
      end

      class Help
        header "Delete an image reference from its registry"
        caption "Delete an image reference from its registry"
      end

      def run
        ref = Name::Reference.parse_reference args.image
        V1::Remote.delete(ref, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new))
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
